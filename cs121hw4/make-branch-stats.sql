-- [Problem 1]
-- creates an index on account that makes this
-- process more efficient
CREATE INDEX idx_account ON account(branch_name, balance);

-- [Problem 2]
-- defines table that holds materialized results
-- uses column names that will be used for view
DROP TABLE mv_branch_account_stats;
CREATE TABLE mv_branch_account_stats (
    branch_name VARCHAR(15) NOT NULL PRIMARY KEY,
    num_accounts INT NOT NULL,
    total_deposits NUMERIC(12, 2),
    min_balance NUMERIC(12, 2),
    max_balance NUMERIC(12, 2)
);

-- [Problem 3]
-- inserts in the values for the view into
-- the table
INSERT INTO mv_branch_account_stats
    SELECT branch_name, COUNT(*), SUM(balance),
    MIN(balance), MAX(balance)
    FROM account GROUP BY branch_name;
    
-- [Problem 4]
-- creates view in a fashion that will make it materialized
-- computes avg here instead of in table for efficiency
DROP VIEW branch_account_stats;
CREATE VIEW branch_account_stats AS
    SELECT branch_name, num_accounts, total_deposits,
    (total_deposits / num_accounts) AS avg_balance, 
    min_balance, max_balance FROM mv_branch_account_stats;

-- [Problem 5]
DELIMITER !
-- creates a trigger that updates branch_account_stats when
-- a value is added to account and adds a new row if the
-- branch name did not exist before
CREATE TRIGGER trg_insert AFTER INSERT ON account FOR EACH ROW 
BEGIN
DECLARE new_count INT;
DECLARE new_total NUMERIC(12, 2);
DECLARE new_min NUMERIC(12, 2);
DECLARE new_max NUMERIC(12, 2);

-- the first account is added
IF (NEW.branch_name NOT IN (SELECT branch_name 
    FROM mv_branch_account_stats)) THEN INSERT INTO mv_branch_account_stats 
    VALUES (NEW.branch_name, 1, NEW.balance, NEW.balance, NEW.balance);
ELSE

-- calculates new values for mv_branch_account_stats
SET new_count = (SELECT (num_accounts + 1) FROM mv_branch_account_stats
                WHERE branch_name = NEW.branch_name);
SET new_total = (SELECT (total_deposits + NEW.balance) 
                FROM mv_branch_account_stats
                WHERE branch_name = NEW.branch_name);
SET new_min = (SELECT LEAST(min_balance, NEW.balance)
                FROM mv_branch_account_stats
                WHERE branch_name = NEW.branch_name);
SET new_max = (SELECT GREATEST(max_balance, NEW.balance)
                FROM mv_branch_account_stats
                WHERE branch_name = NEW.branch_name);
REPLACE INTO mv_branch_account_stats VALUES
(NEW.branch_name, new_count, new_total, new_min, new_max);
END IF;

END!

DELIMITER ;

-- [Problem 6]
DELIMITER !
-- creates a trigger that updates branch_account_stats when
-- a value is deleted from account and takes away a row if the
-- branch name has no more accounts
CREATE TRIGGER trg_delete AFTER DELETE ON account FOR EACH ROW 
BEGIN
DECLARE old_count INT;
DECLARE old_total NUMERIC(12, 2);
DECLARE old_min NUMERIC(12, 2);
DECLARE old_max NUMERIC(12, 2);

-- the last account got deleted
IF (OLD.branch_name NOT IN (SELECT branch_name FROM account)) THEN
    DELETE FROM mv_branch_account_stats 
    WHERE branch_name = OLD.branch_name;
ELSE

-- calculates new values for mv_branch_account_stats
SET old_count = (SELECT (num_accounts - 1) FROM mv_branch_account_stats
                WHERE branch_name = OLD.branch_name);
SET old_total = (SELECT (total_deposits - OLD.balance) 
                FROM mv_branch_account_stats
                WHERE branch_name = OLD.branch_name);
SET old_min = (SELECT MIN(balance) FROM account
              WHERE branch_name = OLD.branch_name);
SET old_max = (SELECT MAX(balance) FROM account
              WHERE branch_name = OLD.branch_name);
REPLACE INTO mv_branch_account_stats VALUES
(OLD.branch_name, old_count, old_total, old_min, old_max);
END IF;
END!

DELIMITER ;

-- [Problem 7]
DELIMITER !
-- creats a trigger that updates branch_account_stats when
-- a value is updated in accounts and deletes a row and adds a row
-- if the branch name is changed
CREATE TRIGGER trg_update AFTER UPDATE ON account FOR EACH ROW 
BEGIN

DECLARE new_count INT;
DECLARE new_total NUMERIC(12, 2);
DECLARE old_min NUMERIC(12, 2);
DECLARE old_max NUMERIC(12, 2);

-- calculates new values for mv_branch_account stats
SET new_count = (SELECT num_accounts FROM mv_branch_account_stats
                WHERE branch_name = OLD.branch_name);
SET new_total = (SELECT (total_deposits + NEW.balance - OLD.balance) 
                FROM mv_branch_account_stats
                WHERE branch_name = OLD.branch_name);
SET old_min = (SELECT MIN(balance) FROM account
              WHERE branch_name = NEW.branch_name);
SET old_max = (SELECT MAX(balance) FROM account
              WHERE branch_name = NEW.branch_name);

-- branch name change              
IF (OLD.branch_name NOT IN (SELECT branch_name FROM account)) THEN
    DELETE FROM mv_branch_account_stats 
        WHERE branch_name = OLD.branch_name;
    INSERT INTO mv_branch_account_stats VALUES (NEW.branch_name, 
        new_count, new_total, old_min, old_max);
-- not a branch name change
ELSE
    REPLACE INTO mv_branch_account_stats VALUES
        (OLD.branch_name, new_count, new_total, old_min, old_max);
END IF;    

END!

DELIMITER ;