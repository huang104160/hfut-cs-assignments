/* log in with yzj
SELECT * FROM student;
*/

/*
CREATE ROLE ��ƽ;
CREATE ROLE ��Сƽ;
GRANT UPDATE(sno), SELECT ON student to ��ƽ;
DROP ROLE ��Сƽ;
*/

/*
EXEC sp_addrolemember @rolename='��ƽ',@membername='yzj'
*/

/* log in with yzj
SELECT * FROM student;
*/
