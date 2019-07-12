-- [Problem 1.1]
DROP TABLE IF EXISTS perms;

-- table that includes information about the permissions
CREATE TABLE perms(
    -- path string that needs permission
    resource_path VARCHAR(1000),
    -- username string
    username VARCHAR(20),
    -- type of permission
    permissions VARCHAR(20),
    -- permission true or false
    granted BOOLEAN,
    -- each pair of three is unique
    PRIMARY KEY (resource_path, username, permissions)
);

-- [Problem 1.2]
DROP PROCEDURE IF EXISTS add_perm;

DELIMITER !
-- procedure takes in path, username, permission string, and boolean
-- and adds these to the valid permission table
CREATE PROCEDURE add_perm(IN res_path VARCHAR(1000), user VARCHAR(1000),
perm VARCHAR(20), grant_perm BOOLEAN)
BEGIN
    INSERT INTO perms VALUES
    (res_path, user, perm, grant_perm);
END !
DELIMITER ;

-- [Problem 1.3]
DROP PROCEDURE IF EXISTS del_perm;

DELIMITER !
-- procedure takes in path, username, and permission string
-- and deletes these tuples from the table
CREATE PROCEDURE del_perm(IN res_path VARCHAR(1000), user VARCHAR(1000),
perm VARCHAR(20))
BEGIN
    DELETE FROM perms WHERE
    resource_path LIKE res_path AND username LIKE user
    AND permissions LIKE perm;
END !
DELIMITER ;


-- [Problem 1.4]
DROP PROCEDURE IF EXISTS clear_perms;

DELIMITER !
-- procedure takes in nothing and erases
-- all data from the table
CREATE PROCEDURE clear_perms()
BEGIN
    TRUNCATE TABLE perms;
END !
DELIMITER ;

-- [Problem 1.5]
DROP FUNCTION IF EXISTS has_perm;

DELIMITER !
-- checks to see if valid username and password combo
CREATE FUNCTION has_perm(res_path VARCHAR(1000), user VARCHAR(20),
perm VARCHAR(20)) RETURNS BOOLEAN
BEGIN
    DECLARE best VARCHAR(1000);
    DECLARE possible VARCHAR(1000);
    
    SET possible = (SELECT resource_path FROM perms
    WHERE username LIKE user AND permissions LIKE perm
    AND resource_path LIKE res_path);
    
    -- first checks to see if the permission was
    -- given specifically
    IF possible LIKE res_path THEN
    RETURN (SELECT granted FROM perms
    WHERE username LIKE user AND permissions LIKE perm
    AND resource_path LIKE res_path);
    END IF;
    
    DROP TEMPORARY TABLE IF EXISTS spec;
    CREATE TEMPORARY TABLE spec(
        spec_path VARCHAR(1000)
    );
    
    -- otherwise it checks to see if the higher
    -- groups match (checking prefixes)
    INSERT INTO spec SELECT resource_path FROM
    perms WHERE  res_path LIKE CONCAT(resource_path, '/%')
    AND username LIKE user and permissions LIKE perm;
    
    -- takes the permission with the longest
    -- path which is the most relevant
    SET best = (SELECT spec_path FROM spec
    ORDER BY LENGTH(spec_path) DESC LIMIT 1);
    
    -- takes the boolean for that set
    IF best IS NOT NULL THEN
    RETURN (SELECT granted FROM perms
    WHERE username LIKE user AND permissions 
    LIKE perm AND resource_path LIKE best);
    END IF;
    
    RETURN 0;
   
END !
DELIMITER ;
