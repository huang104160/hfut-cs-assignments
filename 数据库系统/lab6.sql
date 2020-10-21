--1
SELECT sno, sname FROM student, class
	WHERE student.clsNO = class.clsNO AND class.Specialty = '�����Ӧ��';

--2
-- �ⷨ1
SELECT sno FROM student
	WHERE sno IN (
		SELECT sno FROM sc);
-- �ⷨ2
SELECT sno FROM student
	WHERE EXISTS
		(SELECT * FROM sc WHERE student.sno = sc.sno);

--3
SELECT sno, grade*0.75 FROM sc
	WHERE cno = '0001' AND grade BETWEEN 80 AND 90;

--4
SELECT student.* FROM student, class
	WHERE student.clsNO = class.clsNO
		AND (Specialty = '�����Ӧ��' OR Specialty = '��ѧ')
		AND sname LIKE '��%';

--5
SELECT sno, grade FROM sc
	WHERE cno = '0001'
		AND grade > ANY
			(SELECT grade FROM sc, student
				WHERE sc.sno = student.sno
					AND sc.cno = '0001'
					AND student.sname = 'Ǯ��');

--6
-- �ⷨ1
SELECT sname FROM student
	WHERE NOT EXISTS
		(SELECT * FROM sc 
			WHERE cno='0002' AND student.sno = sc.sno);
-- �ⷨ2
SELECT sname FROM student
	WHERE sno NOT IN
		(SELECT sno FROM sc
			WHERE cno = '0002');
