-- [Problem 1a]
-- Sums the max score of each assignment
SELECT SUM(maxscore) AS perfect_total
    FROM assignment;

-- [Problem 1b]
-- Counts the username of students in each section name
SELECT sec_name, COUNT(username) AS num_students
    FROM section NATURAL JOIN student
    GROUP by sec_name;

-- [Problem 1c]
-- Creates view that sums the scores with graded = TRUE
CREATE VIEW totalscores AS
    SELECT username, SUM(score) AS total_score
    FROM student NATURAL JOIN submission
    WHERE graded = TRUE
    GROUP BY username
    ORDER BY total_score DESC;

-- [Problem 1d]
-- takes all from totalscores where
-- score is 40 or higher
CREATE VIEW passing AS
    SELECT * FROM totalscores
    WHERE total_score >= 40
    ORDER BY username;

-- [Problem 1e]
-- takes all from totalscores where score 
-- is less than 40
CREATE VIEW failing AS
    SELECT * FROM totalscores
    WHERE total_score < 40;

-- [Problem 1f] ----
-- takes names from passing and sees if fewer than all labs are submitted
SELECT DISTINCT username
    FROM submission NATURAL JOIN assignment
    WHERE shortname LIKE 'lab%' AND username IN (SELECT username from passing)
    AND sub_id NOT IN (SELECT sub_id FROM fileset)
    ORDER BY username;
    
-- Coleman, Edwards, Flores, Gibson, Harris, Miller, Murphy, Ross, Simmons,
-- Tucker, and Turner for a total of 11 usernames
    
-- [Problem 1g] ---
-- same as before except with midterm or final
SELECT DISTINCT username
    FROM submission NATURAL JOIN assignment
    WHERE (shortname LIKE 'midterm' OR shortname LIKE 'final')
    AND username IN (SELECT username from passing)
    AND sub_id NOT IN (SELECT sub_id FROM fileset)
    ORDER BY username;
    
-- Collins is the only username

-- [Problem 2a]
-- select usernames where the submission date is after the due
-- date for the midterm
SELECT DISTINCT username
    FROM assignment NATURAL JOIN submission NATURAL JOIN fileset
    WHERE due < sub_date
    AND shortname LIKE 'midterm';

-- [Problem 2b]
-- counts the number of sub_ids per hours
SELECT HOUR(sub_date) as hour, COUNT(sub_id) as num_submits
    FROM assignment NATURAL JOIN submission NATURAL JOIN fileset
    WHERE shortname LIKE 'lab%'
    GROUP BY hour;

-- [Problem 2c]
-- similar to 2a except with final and the 30 minute constraint
SELECT COUNT(username) AS submissions
    FROM assignment NATURAL JOIN submission NATURAL JOIN fileset
    WHERE (sub_date BETWEEN due - INTERVAL 30 MINUTE AND due)
    AND shortname LIKE 'final';

-- [Problem 3a]
-- adds the column to students
-- updates with the concat function
-- alters column to NOT NULL
ALTER TABLE student
    ADD COLUMN email VARCHAR(200);

UPDATE student 
    SET email = CONCAT(username, '@school.edu');
    
ALTER TABLE student
    CHANGE COLUMN email email VARCHAR(200) NOT NULL;

-- [Problem 3b]
-- creates the column with default true
-- updates table to false where dq
ALTER TABLE assignment
    ADD COLUMN submit_files BOOLEAN DEFAULT TRUE;

UPDATE assignment
    SET submit_files = FALSE
    WHERE shortname LIKE 'dq%';
    
-- [Problem 3c]
-- creates table and inserts rows
-- changes the column name in assignment
-- adds foreign key
CREATE TABLE gradescheme (
    scheme_id INT    PRIMARY KEY,
    scheme_desc VARCHAR(100) NOT NULL
);

INSERT INTO gradescheme VALUES
    (0, 'Lab assignment with min-grading.'),
    (1, 'Daily quiz.'),
    (2, 'Midterm or final exam.');
    
ALTER TABLE assignment
    CHANGE COLUMN gradescheme scheme_id INT NOT NULL;
    
ALTER TABLE assignment
    ADD FOREIGN KEY (scheme_id) REFERENCES gradescheme(scheme_id);
    
-- [Problem 4a]
DELIMITER !
-- Given a date value, returns TRUE if it is a weekend
CREATE FUNCTION is_weekend(d DATE) RETURNS BOOLEAN
BEGIN

IF DAYOFWEEK(d) = 1 OR DAYOFWEEK(d) = 7
    THEN RETURN TRUE;
END IF;

RETURN FALSE;

END !
DELIMITER ;

-- [Problem 4b]
DELIMITER !
-- Given a date value, returns the holiday if exists
-- I do not like create local variables
CREATE FUNCTION is_holiday(d DATE) RETURNS VARCHAR(20)
BEGIN

-- New Year's Day
IF DAY(d) = 1 AND MONTH(d) = 1
    THEN RETURN 'New Year\'s Day';
END IF;

-- Independence Day
IF DAY(d) = 4 AND MONTH(d) = 7
    THEN RETURN 'Independence Day';
END IF;

-- Memorial Day
IF DAYOFWEEK(d) = 2 AND MONTH(d) = 5 AND DAY(d) BETWEEN 25 AND 31
    THEN RETURN 'Memorial Day';
END IF;

-- Labor Day
IF DAYOFWEEK(d) = 2 and MONTH(d) = 9 AND DAY(d) BETWEEN 1 AND 7
    THEN RETURN 'Labor Day';
END IF;

-- Thanksgiving
IF DAYOFWEEK(d) = 5 AND MONTH(d) = 11 AND DAY(d) BETWEEN 21 AND 27
    THEN RETURN 'Thanksgiving';
END IF;

RETURN NULL;

END !
DELIMITER ;
    
-- [Problem 5a]
-- runs the is_holiday function on the submission dates
-- counts the ID's and organizes
SELECT is_holiday(DATE(sub_date)) AS holiday, COUNT(fset_id) AS submissions
    FROM fileset
    GROUP BY holiday;

-- [Problem 5b]
-- uses the case syntax to sort the function outputs then counts
SELECT (CASE WHEN is_weekend(DATE(sub_date)) = 1 THEN 'weekend'
    WHEN is_weekend(DATE(sub_date)) = 0 THEN 'weekday' END) AS weekday,
    COUNT(fset_id) AS submissions
    FROM fileset
    GROUP BY weekday;

