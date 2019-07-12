-- [Problem 1]
DELIMITER !
-- function takes in a sub_id from fileset and computes the
-- smallest interval between submission times
-- uses cursor to go through values and calculate difference
CREATE FUNCTION min_submit_interval(sub_id_input INT) RETURNS INT
BEGIN 
DECLARE done INT DEFAULT 0;
DECLARE minimum INT;
DECLARE sub_date1 INT DEFAULT 0;
DECLARE sub_date2 INT DEFAULT 0;

DECLARE cur CURSOR FOR
    SELECT UNIX_TIMESTAMP(sub_date)
    FROM fileset
    WHERE sub_id = sub_id_input;
    
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;

OPEN cur;
FETCH cur INTO sub_date1;
FETCH cur INTO sub_date2;
IF sub_date2 = 0 OR sub_date1 = 0 THEN
    RETURN NULL;
END IF;
SET minimum = sub_date2 - sub_date1;
SET sub_date1 = sub_date2;
WHILE NOT done DO
    FETCH cur INTO sub_date2;
    IF NOT done THEN
        IF sub_date2 - sub_date1 < minimum THEN
            SET minimum = sub_date2 - sub_date1;
        END IF;
        SET sub_date1 = sub_date2;
    END IF;
END WHILE;
CLOSE cur;

RETURN minimum;
    
END!

DELIMITER ;

-- [Problem 2]
DELIMITER !
-- function takes in a sub_id from fileset and computes the
-- largest interval between submission times
-- uses cursor to go through values and calculate difference
CREATE FUNCTION max_submit_interval(sub_id_input INT) RETURNS INT
BEGIN 
DECLARE done INT DEFAULT 0;
DECLARE maximum INT;
DECLARE sub_date1 INT DEFAULT 0;
DECLARE sub_date2 INT DEFAULT 0;

DECLARE cur CURSOR FOR
    SELECT UNIX_TIMESTAMP(sub_date)
    FROM fileset
    WHERE sub_id = sub_id_input;
    
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;

OPEN cur;
FETCH cur INTO sub_date1;
FETCH cur INTO sub_date2;
IF sub_date2 = 0 OR sub_date1 = 0 THEN
    RETURN NULL;
END IF;
SET maximum = sub_date2 - sub_date1;
SET sub_date1 = sub_date2;
WHILE NOT done DO
    FETCH cur INTO sub_date2;
    IF NOT done THEN
        IF sub_date2 - sub_date1 > maximum THEN
            SET maximum = sub_date2 - sub_date1;
        END IF;
        SET sub_date1 = sub_date2;
    END IF;
END WHILE;
CLOSE cur;

RETURN maximum;
    
END!

DELIMITER ;

-- [Problem 3]
DELIMITER !
-- function takes in a sub_id from fileset and computes the
-- interval between the end submission times and number of intervals
-- divides these values to get average
CREATE FUNCTION avg_submit_interval(sub_id_input INT) RETURNS DOUBLE
BEGIN 

RETURN (SELECT UNIX_TIMESTAMP(MAX(sub_date)) - UNIX_TIMESTAMP(MIN(sub_date)) 
AS difference FROM fileset WHERE sub_id = sub_id_input) / ((SELECT COUNT(*) 
FROM fileset WHERE sub_id = sub_id_input) - 1);

END !
DELIMITER ;

-- [Problem 4]
-- creates an index that narrows the search through
-- fileset that speeds up the query (2 seconds to 0.3 seconds)
CREATE INDEX idx_fileset ON fileset(sub_id, sub_date);
