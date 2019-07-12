-- [Problem 1]
SELECT SUM(visits) FROM (SELECT COUNT(DISTINCT ip_addr) AS visits FROM weblog 
    UNION SELECT COUNT(diff) AS visits FROM (SELECT DISTINCT a.logtime, 
    TIME_TO_SEC(TIMEDIFF((SELECT DISTINCT b.logtime FROM weblog AS b 
    WHERE b.logtime > a.logtime AND a.ip_addr = b.ip_addr ORDER BY b.logtime 
    LIMIT 1), a.logtime)) AS diff FROM weblog AS a ORDER BY a.logtime) 
    AS t WHERE diff >= 1800) AS t2;

-- [Problem 2]
-- This query runs very slowly because it has to deal with the entire
-- weblog table, even the information that is not needed. Since the table
-- is huge, this slows down the query a lot. I also have a lot of nested 
-- subqueries. To improve the query, we can create an index on the weblog 
-- table. This would help focus on only the important information. We can 
-- also decorrelate the subqueries, since I call weblog multiple times within 
-- the subqueries. We can reduce that number to reduce the times we have to go 
-- through all the data. Other solutions include using WHERE clauses and 
-- minimizing use of functions like TIME_TO_SEC (although this function 
-- doesn't add much time)
CREATE INDEX ind_address ON weblog(ip_addr, logtime);
-- adding an index on the important information cuts the time down immensely as
-- weblog is called many times throughout my query (This cuts it down to 
-- 0.516 seconds on my laptop)

-- [Problem 3]
-- Similar to the above query, first adds the unique address to
-- the total. Then, uses a cursor to go through all the times and
-- checks if the address is the same before seeing if the difference
-- in time is equal or greater to 30 minutes
DELIMITER !
CREATE FUNCTION num_visits() RETURNS INTEGER
BEGIN
DECLARE done INT DEFAULT 0;
DECLARE visits INT DEFAULT 0;
DECLARE logtime1 INT DEFAULT 0;
DECLARE logtime2 INT DEFAULT 0;
DECLARE address1 VARCHAR(100);
DECLARE address2 VARCHAR(100);

DECLARE cur CURSOR FOR
    SELECT ip_addr, TIME_TO_SEC(logtime)
    FROM weblog;
    
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;

OPEN cur;
FETCH cur INTO address1, logtime1;
FETCH cur INTO address2, logtime2;
IF logtime2 = 0 OR logtime1 = 0 THEN
    RETURN 0;
END IF;
IF logtime2 - logtime1 >= 1800 AND address1 = address2 THEN
    SET visits = visits + 1;
END IF;
SET logtime1 = logtime2;
SET address1 = address2;
WHILE NOT done DO
    FETCH cur INTO address2, logtime2;
    IF NOT done THEN
        IF logtime2 - logtime1 >= 1800 AND address1 = address2 THEN
            SET visits = visits + 1;
        END IF;
        SET logtime1 = logtime2;
        SET address1 = address2;
    END IF;
END WHILE;
CLOSE cur;

SET visits = visits + (SELECT COUNT(DISTINCT ip_addr) AS visits FROM weblog);

RETURN visits;

END !
DELIMITER ;
