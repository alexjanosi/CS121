-- [Problem 1]
-- drop just in case
DROP FUNCTION IF EXISTS total_salaries_adjlist;

DELIMITER !
-- function takes in an employee ID and returns a sum of all
-- salaries of the employee and the employees underneath
CREATE FUNCTION total_salaries_adjlist(emp_id INT) RETURNS FLOAT
BEGIN
    DECLARE rowcount INT;
    DECLARE summ FLOAT;
    -- creates table to store all the subtree
    DROP TEMPORARY TABLE IF EXISTS emps;
    CREATE TEMPORARY TABLE emps(
        emp_id INT NOT NULL );
    INSERT INTO emps VALUES (emp_id);
    SET rowcount = 1;
    -- keeps adding lower nodes to table
    WHILE rowcount > 0 DO
        INSERT INTO emps SELECT emp_id FROM employee_adjlist
        WHERE manager_id IN (SELECT * FROM emps) AND
        employee_adjlist.emp_id NOT IN (SELECT * FROM emps);
        SET rowcount = ROW_COUNT();
    END WHILE;
    -- sums all the salaries in table
    SET summ = (SELECT SUM(salary) FROM employee_adjlist WHERE
    employee_adjlist.emp_id IN (SELECT * FROM emps));
    RETURN summ;
   
END !
DELIMITER ;

-- [Problem 2]
-- drop just in case
DROP FUNCTION IF EXISTS total_salaries_nestset;

DELIMITER !
-- function takes in an employee ID and returns a sum of all
-- salaries of the employee and the employees underneath
CREATE FUNCTION total_salaries_nestset(emp_id INT) RETURNS FLOAT
BEGIN
   DECLARE summ FLOAT;
   DECLARE low2 INT;
   DECLARE high2 INT;
   
   SET low2 = (SELECT low FROM employee_nestset
   WHERE employee_nestset.emp_id = emp_id);
   
   SET high2 = (SELECT high FROM employee_nestset
   WHERE employee_nestset.emp_id = emp_id);
   
   -- sums where the high value is equal or less and low value
   -- is equal or greater
   SET summ = (SELECT SUM(salary) FROM employee_nestset WHERE
   low >= low2 AND high <= high2);
   RETURN summ;
END !
DELIMITER ;


-- [Problem 3]
-- selects where the emp_id is not a manager_id, so no nodes underneath
-- the only manager_id that is NULL is the very top of tree
-- which is obviously not a leaf
SELECT emp_id, name, salary FROM employee_adjlist WHERE emp_id NOT IN
(SELECT DISTINCT(manager_id) FROM employee_adjlist 
WHERE manager_id IS NOT NULL);

-- [Problem 4]
-- selects where low and high ranges are not larger than other ranges
SELECT emp_id, name, salary FROM employee_nestset 
WHERE emp_id NOT IN (SELECT e1.emp_id FROM employee_nestset AS e1,
employee_nestset AS e2 WHERE (e2.low < e1.high AND e2.low > e1.low)
OR (e2.high < e1.high AND e2.high > e1.low));

-- [Problem 5]
-- drop just in case
DROP FUNCTION IF EXISTS tree_depth;

DELIMITER !
-- finds maximum depth of the tree
-- I use the adjlist because of the use of manager_id and
-- employee_id creates an easy relationship 
CREATE FUNCTION tree_depth() RETURNS INT
BEGIN
    DECLARE i INT;
    DECLARE dep INT;
    DECLARE rowcount INT;
    SET rowcount = 1;
    SET i = 1;
    -- creates a table and marks depth
    DROP TEMPORARY TABLE IF EXISTS manages;
    CREATE TEMPORARY TABLE manages(
        emp_id INT NOT NULL,
        depth INT NOT NULL
    );
	
    -- inserts top node
    INSERT INTO manages VALUES ((SELECT emp_id FROM employee_adjlist 
    WHERE manager_id IS NULL), 1);

    -- inserts emp_id where the table values are manager
    WHILE rowcount > 0 DO
        INSERT INTO manages SELECT emp_id, i + 1 FROM employee_adjlist
        WHERE manager_id IN (SELECT * FROM manages WHERE depth = i);
        SET rowcount = ROW_COUNT();
        SET i = i + 1;
	END WHILE;
	-- largest depth is outputted
    SET dep = (SELECT MAX(depth) FROM manages);
    RETURN dep;

END !
DELIMITER ;
SELECT tree_depth();

-- [Problem 6]
-- drop just in case
DROP FUNCTION IF EXISTS emp_reports;

DELIMITER !
CREATE FUNCTION emp_reports(emp_id INT) RETURNS INT
BEGIN
    DECLARE high1 INT;
    DECLARE high2 INT;
    DECLARE curr_id INT;
    DECLARE counter INT;
    SET counter = 0;
    
	SET high2 = (SELECT high from employee_nestset 
    WHERE employee_nestset.emp_id = emp_id);
   
    SET high1 = (SELECT low from employee_nestset 
    WHERE employee_nestset.emp_id = emp_id);
   
    SET curr_id = (SELECT emp_id FROM employee_nestset
    WHERE low - high1 = (SELECT MIN(low - high1) FROM employee_nestset
    WHERE low - high1 > 0));
	
    WHILE (SELECT high from employee_nestset WHERE employee_nestset.emp_id = curr_id) < high2 DO
        SET counter = counter + 1;
        SET high1 = (SELECT high FROM employee_nestset WHERE employee_nestset.emp_id = curr_id);
        SET curr_id = (SELECT emp_id FROM employee_nestset WHERE low - high1 = 
        (SELECT MIN(low - high1) FROM employee_nestset WHERE low - high1 > 0));
	END WHILE;
    
    RETURN counter;
END !
DELIMITER ;
