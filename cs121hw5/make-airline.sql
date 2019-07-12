-- [Problem 5]

-- drops tables while respecting referential integrity
-- tables that reference other tables are dropped first
DROP TABLE IF EXISTS tix;
DROP TABLE IF EXISTS associated;
DROP TABLE IF EXISTS purchased;
DROP TABLE IF EXISTS flt_seat;
DROP TABLE IF EXISTS unique_r;
DROP TABLE IF EXISTS flying;
DROP TABLE IF EXISTS purchase;
DROP TABLE IF EXISTS phone_num;
DROP TABLE IF EXISTS purchaser;
DROP TABLE IF EXISTS traveler;
DROP TABLE IF EXISTS seats;
DROP TABLE IF EXISTS flight;
DROP TABLE IF EXISTS aircraft;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS ticket;

-- customer table creates unique, generated customer_id
CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY
);

-- aircraft table holds information about each type of plane
CREATE TABLE aircraft (
    -- each plane is identified by its 3-digit code
    type_code CHAR(3) NOT NULL PRIMARY KEY,
    -- company string tells manufacturer
    company VARCHAR(20) NOT NULL,
    -- description of model of plane
    model VARCHAR(20) NOT NULL
);

-- ticket table creates unique tickets and their price
CREATE TABLE ticket (
    -- uniquely generated ticket IDs
    ticket_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    -- decimal for price allows for variaty
    sale_price DECIMAL(7, 2) NOT NULL,
    -- checks that prices are less than $10000 and real values
    CHECK ((sale_price < 10000.00) AND (sale_price > 0))
);

-- information about each individual flight
CREATE TABLE flight (
    -- unique flight ID per day
    flight_no VARCHAR(10) NOT NULL,
    -- date of flight also primary key since flight_no refreshes daily
    flight_date DATE NOT NULL,
    -- time of flight
    flight_time TIME NOT NULL,
    -- IATA aiport code of airport flying out of
    source_arpt CHAR(3) NOT NULL,
    -- IATA airport code of airport destination
    destination CHAR(3) NOT NULL,
    -- flag marking if international or not
    domestic CHAR(1) NOT NULL,
    -- code of airplane flying the flight
    -- cannot be NULL since each flight must need a plane
    type_code CHAR(3) NOT NULL,
    PRIMARY KEY (flight_no, flight_date),
    -- only on delete cascade since all flight will be cancelled if
    -- something happens to a plane. Updating does not make sense since
    -- a plane will not change to a different type
    FOREIGN KEY (type_code) REFERENCES aircraft(type_code)
                                  ON DELETE CASCADE,
    -- check that the flag is one of two possibilities
    CHECK ((domestic LIKE 'D') OR (domestic LIKE 'I'))
    
);

-- information about the seats on each plane
CREATE TABLE seats (
    -- code of the plane the seats are on
    type_code CHAR(3) NOT NULL,
    -- identifier of each seat on the plane
    seat_no CHAR(3) NOT NULL,
    -- unique ticket per seat
    ticket_id INT NOT NULL,
    -- unique character for type of class the seat is in
    class CHAR(1) NOT NULL,
    -- whether the seat is aisle, middle, or window
    seat_type VARCHAR(15) NOT NULL,
    -- flag if the seat is an exit row
    exit_row CHAR(1) NOT NULL,
    PRIMARY KEY (seat_no, type_code, ticket_id),
    -- only on delete cascade because the seats will be deleted
    -- if the plane is deleted. Planes are rarely upgraded, so 
    -- on update cascade does not make sense
    FOREIGN KEY (type_code) REFERENCES aircraft(type_code)
                            ON DELETE CASCADE,
    -- ticket id should not change
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id),
    -- checks that the exit flag is one of two possibilities
    CHECK ((exit_row LIKE 'Y') OR (exit_row LIKE 'N'))
);

-- information about people travelling
CREATE TABLE traveler (
    -- customers each have an unique, generated id
    customer_id INT NOT NULL PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    email VARCHAR(30) NOT NULL,
    -- password is a candidate key since each person has their own
    passport VARCHAR(40) UNIQUE,
    -- which country the traveler is from
    citizenship VARCHAR(40),
    -- emergency contact name
    emerg_name VARCHAR(40),
    -- emergencry contact phone number
    emerg_phone VARCHAR(15),
    -- frequent flyer # is a candidate key because you cannot use others'
    frequent_flyer CHAR(7) UNIQUE,
    -- customers will not update their unique id bc that does not make sense
    -- if a customer is kicked off the airline, their information should
    -- be deleted
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
                                        ON DELETE CASCADE
);

-- information about customers buying tickets
CREATE TABLE purchaser (
    -- customers each have an unique, generated id
    customer_id INT NOT NULL PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    email VARCHAR(30) NOT NULL,
    -- may supply payment information but not neccessary (can be NULL)
    card_no INT,
    exp_date CHAR(5),
    veri_code INT,
    -- customers will not update their unique id bc that does not make sense
    -- if a customer is kicked off the airline, their information should
    -- be deleted
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
                                        ON DELETE CASCADE
);

-- one or more possible phone numbers per customer
CREATE TABLE phone_num (
    customer_id INT NOT NULL,
    phone VARCHAR(15) NOT NULL,
    -- the key is a pair so multiple phones can be added
    PRIMARY KEY (customer_id, phone),
    -- customers will not update their unique id bc that does not make sense
    -- if a customer is kicked off the airline, their information should
    -- be deleted
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
                                        ON DELETE CASCADE
);

-- information about the purchase of tickets
CREATE TABLE purchase (
    -- unique id for each purchase in the airline
    purchase_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    purchase_time TIMESTAMP NOT NULL,
    -- confirmation number is unique per purchase so candidate key
    conf_number CHAR(6) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    -- customers will not update their unique id bc that does not make sense
    -- if a customer is kicked off the airline, their information should
    -- be deleted
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
                                        ON DELETE CASCADE
);

-- relation between the aircraft and the flight it is taking
CREATE TABLE flying (
    flight_no VARCHAR(10) NOT NULL,
    flight_date DATE NOT NULL,
    -- cannot be NULL since a plane is needed each flight
    type_code CHAR(3) NOT NULL,
    PRIMARY KEY (flight_no, flight_date),
    -- the flight number can be cancelled or updated depending
    -- on problems or delays
    FOREIGN KEY (flight_no, flight_date) 
    REFERENCES flight(flight_no, flight_date)
                            ON DELETE CASCADE ON UPDATE CASCADE,
    -- the plane can be deleted if the plane is destroyed or retired
    FOREIGN KEY (type_code) REFERENCES aircraft(type_code)
                            ON DELETE CASCADE
);

-- relates together ticket, flight, and seats
CREATE TABLE unique_r (
    flight_no VARCHAR(10) NOT NULL,
    flight_date DATE NOT NULL,
    seat_no CHAR(3) NOT NULL,
    ticket_id INT NOT NULL,
    PRIMARY KEY (flight_no, flight_date, seat_no, ticket_id),
    FOREIGN KEY (flight_no, flight_date) 
    -- flights can be cancelled or update (e.g. delayed)
    REFERENCES flight(flight_no, flight_date)
                            ON DELETE CASCADE ON UPDATE CASCADE,
    -- seats and tickets IDs will not be deleted or updated
    FOREIGN KEY (seat_no) REFERENCES seats(seat_no),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
);

-- connects seats with aircrafts
CREATE TABLE flt_seat (
    type_code CHAR(3) NOT NULL,
    seat_no CHAR(3) NOT NULL,
    PRIMARY KEY (type_code, seat_no),
    -- planes can be destroyed or disbanned
    FOREIGN KEY (type_code) REFERENCES aircraft(type_code)
                            ON DELETE CASCADE,
    -- seat identifiers will stay the same
    FOREIGN KEY (seat_no) REFERENCES seats(seat_no)
);

-- information linking purchasers with purchase
CREATE TABLE purchased (
    purchase_id INT NOT NULL PRIMARY KEY,
    customer_id INT NOT NULL,
    -- purchase information should not change so no cascade
    FOREIGN KEY (purchase_id) REFERENCES purchase(purchase_id),
    -- customer could lose his account id for not following airline rules
    FOREIGN KEY (customer_id) REFERENCES purchaser(customer_id)
                              ON DELETE CASCADE
);

-- information linking travelers with their tickets
CREATE TABLE associated (
    customer_id INT NOT NULL,
    ticket_id INT NOT NULL,
    PRIMARY KEY (customer_id, ticket_id),
    -- customer could lose his account id for not following airline rules
    FOREIGN KEY (customer_id) REFERENCES traveler(customer_id)
                              ON DELETE CASCADE,
    -- ticket id should not change
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
);

-- information linking each purchase with the tickets
CREATE TABLE tix (
    purchase_id INT NOT NULL,
    ticket_id INT NOT NULL REFERENCES ticket.ticket_id,
    PRIMARY KEY (purchase_id, ticket_id),
    -- purchase id and ticket id should never change
    FOREIGN KEY (purchase_id) REFERENCES purchase(purchase_id),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
);
