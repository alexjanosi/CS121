-- [Problem 6a]
-- natural joining all the linked relations and tables will give us
-- all the purchase and ticket information for this customer
SELECT purchase_time, flight_date, last_name, first_name
    FROM purchaser NATURAL JOIN purchased NATURAL JOIN purchase
    NATURAL JOIN tix NATURAL JOIN ticket 
    NATURAL JOIN unique_r NATURAL JOIN flight WHERE customer_id = 54321
    ORDER BY purchase_time DESC, flight_date, last_name, first_name;

-- [Problem 6b]
-- natural joining ticket, unique_r, flight, and flying will give us the
-- flights and ticket information from the last two weeks. Using a left join,
-- we create null values for aircrafts not used that will appear as zero
-- in the sum
SELECT model, SUM(IFNULL(sale_price, 0)) AS total_revenue
    FROM aircraft NATURAL LEFT JOIN (flying NATURAL JOIN flight 
    NATURAL JOIN unique_r NATURAL JOIN ticket)
    WHERE flight_date BETWEEN NOW() AND NOW() - INTERVAL 2 WEEK
    GROUP BY model;

-- [Problem 6c]
-- natural joining traveler with associated with pair each traveler with
-- all of their tickets. The tickets can be assocaited with each flight_no.
-- unique_r natural join flight will give the ticket_id and all
-- the flight info. From there we pick were info is NULL and "I'
-- for international
SELECT customer_id
    FROM traveler NATURAL JOIN associated NATURAL JOIN
    unique_r NATURAL JOIN flight
    WHERE (passport IS NULL OR citizenship IS NULL OR
    emerg_name IS NULL OR emerg_phone is NULL) AND
    domestic LIKE 'I';
    