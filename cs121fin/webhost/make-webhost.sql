-- [Problem 1.3]
DROP TABLE IF EXISTS installed;
DROP TABLE IF EXISTS owns;
DROP TABLE IF EXISTS private;
DROP TABLE IF EXISTS public;
DROP TABLE IF EXISTS basic;
DROP TABLE IF EXISTS preferred;
DROP TABLE IF EXISTS dedicated;
DROP TABLE IF EXISTS shared;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS software;
DROP TABLE IF EXISTS server;

-- table for customer info
CREATE TABLE customer(
    -- username string
    username VARCHAR(20) NOT NULL,
    -- email string, not null because necessary
    email VARCHAR(50) NOT NULL,
    -- specific website url
    website_url VARCHAR(200) NOT NULL,
    -- date when account was opened
    opened_account TIMESTAMP NOT NULL,
    -- price per month for service
    monthly_price DECIMAL(5, 2) NOT NULL,
    -- each username can have
    -- multiple urls
    PRIMARY KEY (username, website_url)
);

-- table for software info
CREATE TABLE software(
    -- package name string
    pkg_name VARCHAR (40) NOT NULL,
    -- version for the package
    version VARCHAR(20) NOT NULL,
    -- description of package
    description VARCHAR(1000) NOT NULL,
    -- total price
    price DECIMAL(5, 2) NOT NULL,
    -- each package can have 
    -- multiple versions (updates)
    PRIMARY KEY (pkg_name, version)
);

-- table for server info
CREATE TABLE server(
    -- hostname string
    hostname VARCHAR(40) NOT NULL PRIMARY KEY,
    -- operating system
    op_sys VARCHAR(20) NOT NULL
);

-- table for shared servers
CREATE TABLE shared(
    -- same hostname as server
    hostname VARCHAR(40) NOT NULL PRIMARY KEY,
    -- number of users on server ( > 1)
    hostable INT NOT NULL,
    FOREIGN KEY (hostname) REFERENCES server(hostname),
    CHECK (hostable > 1)
);

-- table for dedicated servers
CREATE TABLE dedicated(
    -- same hostname as server
    hostname VARCHAR(40) NOT NULL PRIMARY KEY,
    -- number of users on server (only one)
    hostable INT NOT NULL,
    FOREIGN KEY (hostname) REFERENCES server(hostname),
    CHECK (hostable = 1)
);

-- table for basic customer
CREATE TABLE basic(
    -- same username and url as customer
    username VARCHAR(20) NOT NULL,
    website_url VARCHAR(200) NOT NULL,
    -- specific key for basic ("b")
    type CHAR(1),
    PRIMARY KEY (username, website_url),
    FOREIGN KEY (username, website_url) 
    REFERENCES customer(username, website_url),
    -- checks the type
    CHECK (type LIKE 'b')
);

-- table for preferred customer
CREATE TABLE preferred(
    -- same username and url as customer
    username VARCHAR(20) NOT NULL,
    website_url VARCHAR(200) NOT NULL,
    -- specific key for preferred ("p")
    type CHAR(1),
    PRIMARY KEY (username, website_url),
    FOREIGN KEY (username, website_url) 
    REFERENCES customer(username, website_url),
    -- checks the type is right
    CHECK (type LIKE 'p')
);

-- info for relation between dedicated servers
-- and preferred customers
CREATE TABLE private(
    -- hostname is candidate because once used
    -- no one should be able to use it
    username VARCHAR(20) NOT NULL,
    website_url VARCHAR(200) NOT NULL,
    hostname VARCHAR(40) NOT NULL UNIQUE,
    PRIMARY KEY (username, website_url),
    FOREIGN KEY (username, website_url) 
    REFERENCES preferred(username, website_url),
    FOREIGN KEY (hostname) REFERENCES dedicated(hostname)
);

-- info for relation between shared servers
-- and basic customers
CREATE TABLE public(
    -- hostname is not a key since participation
    username VARCHAR(20) NOT NULL,
    website_url VARCHAR(200) NOT NULL,
    hostname VARCHAR(40) NOT NULL,
    PRIMARY KEY (username, website_url),
    FOREIGN KEY (username, website_url) 
    REFERENCES basic(username, website_url),
    FOREIGN KEY (hostname) REFERENCES shared(hostname)
);

-- info for relation between customer and software
CREATE TABLE owns(
    -- no primary keys since both sides have
    -- weak participation
    username VARCHAR(20) NOT NULL,
    website_url VARCHAR(200) NOT NULL,
    pkg_name VARCHAR(40) NOT NULL,
    FOREIGN KEY (username, website_url) 
    REFERENCES customer(username, website_url),
    FOREIGN KEY (pkg_name) REFERENCES software(pkg_name)
);

-- info for the relation between server and software
CREATE TABLE installed(
    -- no primary keys since both sides have
    -- weak participation
    pkg_name VARCHAR(40) NOT NULL,
    hostname VARCHAR(40) NOT NULL,
    FOREIGN KEY (hostname) REFERENCES server(hostname),
    FOREIGN KEY (pkg_name) REFERENCES software(pkg_name)
);


