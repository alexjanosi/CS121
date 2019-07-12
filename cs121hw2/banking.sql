-- [Problem 1a]
-- simply selects numbers and amounts of loans
-- that meet the requirements
SELECT loan_number, amount
    FROM loan
    WHERE amount BETWEEN 1000 AND 2000;

-- [Problem 1b]
-- selects matching loan and borrower numbers
-- checks that the name is Smith and orders
SELECT loan.loan_number, loan.amount
    FROM loan, borrower
    WHERE loan.loan_number = borrower.loan_number
    AND borrower.customer_name = 'Smith'
    ORDER BY loan.loan_number;

-- [Problem 1c]
-- selects city name of branch where account branch is
-- and where the account number is
SELECT branch.branch_city
    FROM branch, account
    WHERE branch.branch_name = account.branch_name
    AND account.account_number = 'A-446';

-- [Problem 1d]
-- finds branch in customer's city and links to account
-- then orders names that start with J
SELECT depositor.customer_name, account.account_number,
    account.branch_name, account.balance
    FROM depositor, account
    WHERE depositor.account_number = account.account_number
    AND depositor.customer_name LIKE 'J%'
    ORDER BY depositor.customer_name;

-- [Problem 1e]
-- links customers with their accounts
-- groups by name and checks to see if there are 
-- more than five accounts
SELECT customer_name
    FROM depositor
    GROUP BY customer_name
    HAVING COUNT(account_number) > 5;
    
-- [Problem 2a]
-- creates VIEW with account # and name attributes
-- with linked accounts to customer names at Pownal
CREATE VIEW pownal_customers AS
    SELECT depositor.account_number, depositor.customer_name
    FROM depositor, account
    WHERE account.account_number = depositor.account_number
    AND account.branch_name = 'Pownal';
   
-- [Problem 2b]
-- checks customers in depositor (have an account number) but
-- not in borrower (have a loan number)
-- it is updatable because FROM is just customers and SELECT if
-- only from customers
CREATE VIEW onlyacct_customers AS
    SELECT customer_name, customer_street, customer_city
    FROM customer
    WHERE customer_name IN (SELECT customer_name FROM depositor)
    AND customer_name NOT IN (SELECT customer_name FROM borrower);
    
-- [Problem 2c]
-- left join creates the null values needed for the average balance
CREATE VIEW branch_deposits AS
    SELECT branch.branch_name, IFNULL(SUM(account.balance), 0) AS total_balance,
    AVG(account.balance) AS avg_balance
    FROM account RIGHT JOIN branch ON account.branch_name = branch.branch_name
    GROUP BY branch.branch_name;
    
-- [Problem 3a]
-- selects distinct values of customer cities that are not in
-- any branch city ordered by name
SELECT DISTINCT customer_city FROM customer
    WHERE customer_city NOT IN (SELECT branch_city FROM branch)
    ORDER BY customer_city;

-- [Problem 3b]
-- selects names that do not appear in borrower (have a loan ID)
-- and do not appear in depositor (have an account ID)
SELECT customer_name FROM customer
    WHERE customer_name NOT IN (SELECT customer_name FROM depositor)
    AND customer_name NOT IN (SELECT customer_name FROM borrower);

-- [Problem 3c]
-- updates accounts by adding 50 where the branch name
-- is located in Horseneck
UPDATE account
    SET balance = balance + 50
    WHERE branch_name IN (SELECT account.branch_name
    FROM branch
    WHERE account.branch_name = branch.branch_name
    AND branch_city = 'Horseneck');

-- [Problem 3d]
-- same as before except we can put multiple table names
-- next to update
UPDATE account, branch
    SET account.balance = account.balance + 50
    WHERE account.branch_name = branch.branch_name
    AND branch.branch_city = 'Horseneck';


-- [Problem 3e]
-- joins accounts with the accounts with max balances
SELECT account.account_number, account.branch_name, account.balance
    FROM account JOIN (SELECT branch_name, 
    MAX(balance) AS balance FROM account 
    GROUP by branch_name) AS account2
    ON account.branch_name = account2.branch_name
    AND account.balance = account2.balance;

-- [Problem 3f]
-- Uses IN instead of combining the max accounts with accounts
SELECT account_number, branch_name, balance
    FROM account
    WHERE (branch_name, balance) IN 
    (SELECT branch_name, MAX(balance) AS balance 
    FROM account GROUP BY branch_name);

-- [Problem 4]
-- selects name, assets, and rank of assets
-- rank is made from count of other banks with fewer assets
SELECT b1.branch_name, b1.assets, 1 + COUNT(b2.branch_name) AS rank
    FROM branch AS b1 LEFT OUTER JOIN branch AS b2
    ON (b1.assets < b2.assets)
    GROUP BY b1.branch_name, b1.assets
    ORDER BY rank, branch_name ASC;

