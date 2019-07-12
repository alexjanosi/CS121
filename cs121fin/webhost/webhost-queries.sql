-- [Problem 1.4a]
-- selects the username from the overlap
-- of shared and public and counts the
-- number of usernames on a server
SELECT hostname FROM shared
NATURAL JOIN public
GROUP BY hostname, hostable
HAVING COUNT(username) > hostable;

-- [Problem 1.4b]
-- updates the price to $2 fewer where the username
-- is from a basic account and have 3 or more
-- software packages
UPDATE customer SET monthly_price = monthly_price - 2
WHERE username IN (SELECT username FROM basic
NATURAL JOIN owns GROUP BY username
HAVING COUNT(pkg_name) > 2);


