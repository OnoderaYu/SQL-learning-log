/*
Title: 570. Managers with at Least 5 Direct Reports
Level: Medium

Table: Employee
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| name        | varchar |
| department  | varchar |
| managerId   | int     |
+-------------+---------+
id is the primary key (column with unique values) for this table.
Each row of this table indicates the name of an employee, their department, and the id of their manager.
If managerId is null, then the employee does not have a manager.
No employee will be the manager of themself.
 

Write a solution to find managers with at least five direct reports.

Return the result table in any order.

The result format is in the following example.

 

Example 1:

Input: 
Employee table:
+-----+-------+------------+-----------+
| id  | name  | department | managerId |
+-----+-------+------------+-----------+
| 101 | John  | A          | null      |
| 102 | Dan   | A          | 101       |
| 103 | James | A          | 101       |
| 104 | Amy   | A          | 101       |
| 105 | Anne  | A          | 101       |
| 106 | Ron   | B          | 101       |
+-----+-------+------------+-----------+
Output: 
+------+
| name |
+------+
| John |
+------+
*/

WITH count_table AS (  --cteで先に直属の部下を数えておく
    SELECT
        managerId
        , COUNT(*) AS count_direct_reports  --直属の部下をカウント
    FROM 
        Employee
    WHERE
        managerId IS NOT NULL  --NULLは含めない
    GROUP BY
        managerId
)

SELECT
    e.name
FROM
    count_table ct
JOIN 
    Employee e ON e.id = ct.managerId  --managerIdに対応するid（マネージャー本人）と結合して名前を取得
WHERE
    ct.count_direct_reports >= 5;  
