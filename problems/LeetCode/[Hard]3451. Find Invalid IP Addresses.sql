/*
Table:  logs

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| log_id      | int     |
| ip          | varchar |
| status_code | int     |
+-------------+---------+
log_id is the unique key for this table.
Each row contains server access log information including IP address and HTTP status code.
Write a solution to find invalid IP addresses. An IPv4 address is invalid if it meets any of these conditions:

Contains numbers greater than 255 in any octet
Has leading zeros in any octet (like 01.02.03.04)
Has less or more than 4 octets
Return the result table ordered by invalid_count, ip in descending order respectively. 

The result format is in the following example.

 

Example:

Input:

logs table:

+--------+---------------+-------------+
| log_id | ip            | status_code | 
+--------+---------------+-------------+
| 1      | 192.168.1.1   | 200         | 
| 2      | 256.1.2.3     | 404         | 
| 3      | 192.168.001.1 | 200         | 
| 4      | 192.168.1.1   | 200         | 
| 5      | 192.168.1     | 500         | 
| 6      | 256.1.2.3     | 404         | 
| 7      | 192.168.001.1 | 200         | 
+--------+---------------+-------------+
Output:

+---------------+--------------+
| ip            | invalid_count|
+---------------+--------------+
| 256.1.2.3     | 2            |
| 192.168.001.1 | 2            |
| 192.168.1     | 1            |
+---------------+--------------+
Explanation:

256.1.2.3 is invalid because 256 > 255
192.168.001.1 is invalid because of leading zeros
192.168.1 is invalid because it has only 3 octets
The output table is ordered by invalid_count, ip in descending order respectively.
*/

/*
memo

 文字列（ipアドレス）を分割して判定する必要がある

REGEXP_SUBSTR(文字列, 正規表現, 開始位置, 順序) 正規表現に一致する部分を抽出
  文字列　：対象となる文字列
　正規表現：切り出す文字列と合致させる正規表現
　開始位置：検索対象の開始位置（１は先頭） 省略可
　順序　　：正規表現が合致した順番 → 一致したものの中で何番目か？　省略可

[^.]+ で分割（[^.] → 「ピリオド以外の1文字」にマッチ  /  + → 「1回以上繰り返す」）
正規表現の意味は「.以外文字の１文字以上の連続」
参考: https://qiita.com/fusafusa/items/67b1b187d6e7ddb5e344 

REGEXP_COUNT:正規表現パターンが文字列に現れる回数を返す
REGEXP_COUNT(ip, '\.')	.はワイルドカードだから\でエスケープ

REGEXP_LIKE: TRUE/FALSEを返す
*/

WITH split_ip AS ( --ipをオクテット単位で分割＋オクテット数をカウント
    SELECT
        log_id
        , ip
        , REGEXP_SUBSTR(ip, '[^.]+', 1, 1) AS octet1
        , REGEXP_SUBSTR(ip, '[^.]+', 1, 2) AS octet2
        , REGEXP_SUBSTR(ip, '[^.]+', 1, 3) AS octet3
        , REGEXP_SUBSTR(ip, '[^.]+', 1, 4) AS octet4
        , REGEXP_COUNT(ip, '\.') + 1 AS octet_count
    FROM
        logs;
)

SELECT
    ip
    , COUNT(*) AS invalid_count
FROM
    split_ip
WHERE  --無効となるipを抽出
    octet_count != 4 --オクテット数４以外は無効
    OR TO_NUMBER(octet1) > 255 OR REGEXP_LIKE(octet1, '^0\d+') --　0\d ← 0単体のオクテットは有効 ← ipv4の仕様から、問題には明示されていない?
    OR TO_NUMBER(octet2) > 255 OR REGEXP_LIKE(octet2, '^0\d+') -- TO_NUMBERはなくても自動で数値に変換してくれる
    OR TO_NUMBER(octet3) > 255 OR REGEXP_LIKE(octet3, '^0\d+')
    OR TO_NUMBER(octet4) > 255 OR REGEXP_LIKE(octet4, '^0\d+')
GROUP BY
    ip
ORDER BY
    invalid_count DESC
    , ip DESC;
