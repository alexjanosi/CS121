-- [Problem 1]
-- simply selects attribute A from r
-- PI gets rid of duplicates
SELECT DISTINCT a
    FROM r;

-- [Problem 2]
-- Same as before but with select on b = 17
-- SIGMA does not get rid of duplicates
SELECT *
    FROM r
    WHERE b = 17;

-- [Problem 3]
-- FROM r,s creates all the combinations which is cartesian product
SELECT *
    FROM r, s;

-- [Problem 4]
-- combination of the previous problems
SELECT DISTINCT a, f
    FROM r, s
    WHERE c = d;

-- [Problem 5]
-- simple union from selections
(SELECT * FROM r1) UNION (SELECT a, b, c FROM r2);


-- [Problem 6]
-- selects attributes where they appear in the other relation
SELECT * FROM r1 WHERE (a, b, c) IN (SELECT * FROM r2);


-- [Problem 7]
-- opposite of Problem 6
SELECT * FROM r1 WHERE (a, b, c) NOT IN (SELECT * FROM r2);

