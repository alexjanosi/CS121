-- [Problem a]
-- This query computes the number of loans each customer has
-- it organizes it in descending order
SELECT customer_name, COUNT(loan_number) AS num_loans
    FROM customer NATURAL LEFT JOIN borrower
    GROUP BY customer_name
    ORDER by num_loans DESC;
    
-- [Problem b]
-- This query computes the name of branches where the
-- sum of the loans is greater than the assets of the branch
SELECT branch_name
    FROM branch NATURAL LEFT JOIN 
    (SELECT branch_name, SUM(amount) AS sum_amount
    FROM loan GROUP BY branch_name) AS t1
    WHERE assets < sum_amount
    GROUP BY branch_name;

-- [Problem c]
-- This query computes the number of accounts and loans
-- at each branch. Ordered by increasing branch name
SELECT branch_name,
    (SELECT COUNT(*) FROM account a 
    WHERE a.branch_name = b.branch_name) AS num_accounts,
    (SELECT COUNT(*) FROM loan l
    WHERE l.branch_name = b.branch_name) AS num_loans
    FROM branch b ORDER BY branch_name;

-- [Problem d]
-- This is the same query except decorrelated
SELECT branch_name, COUNT(account_number) AS num_accounts, 
    COUNT(loan_number) AS num_loans
    FROM (SELECT branch_name, loan_number, null AS account_number 
    FROM branch NATURAL LEFT JOIN loan 
    UNION SELECT branch_name, null, account_number 
    FROM branch NATURAL LEFT JOIN account) as t1
    GROUP BY branch_name
    ORDER BY branch_name;