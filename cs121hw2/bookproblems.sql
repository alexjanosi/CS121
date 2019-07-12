-- [Problem 1a]
-- selects distinct names where taken courses has comp. sci
SELECT DISTINCT name 
   FROM student, takes, course
   WHERE course.dept_name = 'Comp. Sci.' AND student.ID = takes.ID
   AND takes.course_id = course.course_id;

-- [Problem 1b]
-- takes max salary by department from instructor
SELECT dept_name, MAX(salary)
   FROM instructor
   GROUP BY dept_name;

-- [Problem 1c]
-- returns the minumum salary of the maximum in each department
SELECT MIN(max_salary) FROM 
   (SELECT dept_name, MAX(salary) AS max_salary 
   FROM instructor 
   GROUP BY dept_name) AS t;

-- [Problem 1d]
-- same as before expect using a WITH clause
WITH t AS 
   (SELECT dept_name, MAX(salary) AS max_salary 
   FROM instructor 
   GROUP BY dept_name)
   SELECT MIN(max_salary) FROM t;
   
-- [Problem 2a]
-- insert a new tuple into course
INSERT INTO course 
    VALUES ('CS-001', 'Weekly Seminar', 'Comp. Sci.', 3);

-- [Problem 2b]
-- add to the specific attributes
INSERT INTO section(course_id, sec_id, semester, year) 
    VALUES ('CS-001', '1', 'Fall', '2009');

-- [Problem 2c]
-- selects ID from students in Comp. Sci. and inserts tuples into takes
INSERT INTO takes(ID, course_id, sec_id, semester, year)
    SELECT ID, 'CS-001', '1', 'Fall', '2009'
    FROM student
    WHERE dept_name = 'Comp. Sci.';

-- [Problem 2d]
-- deletes tuples from 2c where the ID is 'Chavez'
DELETE FROM takes
    WHERE course_id = 'CS-001' AND sec_id = '1' AND semester = 'Fall' 
    AND year = '2009' 
    AND (ID IN (SELECT ID FROM student WHERE name = 'Chavez'));

-- [Problem 2e]
-- section is reliant on course for course_id so when courses with a certain 
-- course_id are deleted, sections with the same course_id are deleted too
DELETE FROM course WHERE course_id = 'CS-001';

-- [Problem 2f]
-- deletes from takes when database appears somewhere in course_id
DELETE FROM takes
    WHERE LOWER((SELECT course.title FROM course
    WHERE takes.course_id = course.course_id)) LIKE '%database%';

-- [Problem 3a]
-- selects distinct names where borrowed and member match memb_no
-- and book and borrowed match ibsn
SELECT DISTINCT name
    FROM member, borrowed, book
    WHERE book.publisher = 'McGraw-Hill' 
    AND member.memb_no = borrowed.memb_no
    AND borrowed.isbn = book.isbn;
    
-- [Problem 3b]
-- similar to before except condition where borrowed amount
-- is equal to total amount of books
SELECT DISTINCT name
    FROM (member JOIN borrowed ON member.memb_no = borrowed.memb_no) JOIN 
    (SELECT isbn FROM book WHERE publisher = 'McGraw-Hill') 
    AS book2 ON borrowed.isbn = book2.isbn
    GROUP BY member.name 
    HAVING COUNT(*) = (SELECT COUNT(*) FROM book 
    WHERE publisher = 'McGraw-Hill');
    
-- [Problem 3c]
-- choose the condition where the values match up and then count
-- the number of books
SELECT book.publisher, member.name
    FROM member, borrowed, book
    WHERE member.memb_no = borrowed.memb_no AND book.isbn = borrowed.isbn
    GROUP BY publisher, name 
    HAVING COUNT(borrowed.isbn) > 5;


-- [Problem 3d]
-- Count the number of borrowed items and divide by number of total members
-- have to multiply by 1.0 for float purposes
SELECT COUNT(*) * 1.0 / (SELECT COUNT(*) FROM member)
    FROM borrowed;

-- [Problem 3e]
-- same as before except with a WITH clause
WITH c AS (SELECT COUNT(*) * 1.0 AS num FROM borrowed)
    SELECT (SELECT num FROM c) / (SELECT COUNT(*) FROM member);
