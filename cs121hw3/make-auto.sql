-- [Problem 1]
DROP TABLE IF EXISTS participated;
DROP TABLE IF EXISTS owns;
DROP TABLE IF EXISTS person;
DROP TABLE IF EXISTS car;
DROP TABLE IF EXISTS accident;

-- Creates person table with values
CREATE TABLE person (
    driver_id  CHAR(10) NOT NULL,
    name    VARCHAR(40) NOT NULL,
    address    VARCHAR(50) NOT NULL,
    PRIMARY KEY (driver_id)
);
    
-- Creates car table with values
CREATE TABLE car (
    license CHAR(7) NOT NULL,
    model    VARCHAR(50),
    year    VARCHAR(10),
    PRIMARY KEY (license)
);

-- Creates accident table with values
CREATE TABLE accident (
    report_number INT NOT NULL AUTO_INCREMENT,
    date_occurred TIMESTAMP NOT NULL,
    location VARCHAR(300) NOT NULL,
    description VARCHAR(5000),
    PRIMARY KEY (report_number)
);

-- Creates owns table with values
CREATE TABLE owns (
    driver_id CHAR(10) NOT NULL,
    license CHAR(7) NOT NULL,
    PRIMARY KEY (driver_id, license),
    FOREIGN KEY (driver_id) REFERENCES person(driver_id)
                    ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (license) REFERENCES car(license)
                    ON UPDATE CASCADE ON DELETE CASCADE
);

-- Creates participiated table with values
CREATE TABLE participated (
    driver_id CHAR(10) NOT NULL,
    license CHAR(7) NOT NULL,
    report_number INT NOT NULL AUTO_INCREMENT,
    damage_amount NUMERIC(12, 2),
    PRIMARY KEY (driver_id, license, report_number),
    FOREIGN KEY (driver_id) REFERENCES person(driver_id)
                            ON UPDATE CASCADE,
    FOREIGN KEY (license) REFERENCES car(license)
                             ON UPDATE CASCADE,
    FOREIGN KEY (report_number) REFERENCES accident(report_number)
                             ON UPDATE CASCADE
);
