-- [Problem 3]
-- natural joins the tables with needed information
-- then compares to count of type_id 
-- don't need distinct because type_id is primary
SELECT person_id, person_name
    FROM geezer NATURAL JOIN game_score NATURAL JOIN game
    GROUP BY person_id, person_name
    HAVING COUNT(DISTINCT type_id) = (SELECT 
    COUNT(type_id) FROM game_type);

-- [Problem 4]
-- creates a view that takes all the attributes where the type_id and score
-- are equal to the max score of each type_id. Ordered by type_id and
-- then person_id, both in increasing order
CREATE VIEW top_scores AS
    SELECT type_id, score, type_name, person_id, person_name
    FROM game_score NATURAL JOIN game NATURAL JOIN game_type NATURAL JOIN geezer
    WHERE (type_id, score) IN (SELECT type_id, MAX(score) AS score
    FROM game_score NATURAL JOIN game NATURAL JOIN game_type NATURAL JOIN geezer
    GROUP BY type_id) ORDER BY type_id, person_id;

-- [Problem 5]
-- selects type_id where the count of games per type is greater than the
-- average games per type from April 5th to April 18th (inclusive)
-- for a total period of two weeks
SELECT type_id
    FROM game NATURAL JOIN game_type
    WHERE DATE(game_date) BETWEEN '2000-04-18' - INTERVAL 13 DAY 
    AND '2000-04-18' GROUP BY type_id HAVING COUNT(game_id) > (SELECT 
    COUNT(game_id) / COUNT(DISTINCT type_id) FROM game NATURAL JOIN 
    game_type WHERE DATE(game_date) 
    BETWEEN '2000-04-18' - INTERVAL 13 DAY AND '2000-04-18');

-- [Problem 6]
-- creates a table to store all the game_id's where Ted Codd played a game
-- of cribbage. Then, deletes all the games from game_score and game. Then,
-- gets rid of the temporary table. I did it this way since a normal delete
-- will only delete Codd's score and not all others who were in the same game
CREATE TABLE temp (
    game_ted int
);

INSERT INTO temp (SELECT game_id FROM game WHERE
    type_id = (SELECT type_id from game_type WHERE type_name = 'cribbage'));
    
DELETE FROM temp WHERE game_ted NOT IN (SELECT game_id FROM game_score 
    WHERE person_id IN (SELECT person_id FROM geezer 
    WHERE person_name = 'Ted Codd'));
    
DELETE FROM game_score WHERE game_id IN (SELECT * FROM temp);

DELETE FROM game where game_id NOT IN (SELECT game_id 
    FROM game_score GROUP by game_id);

DROP TABLE temp;

-- [Problem 7]
-- Updates the two cases where the geezer had some prescriptions already or not
-- adds a space when adding to string and does not if originally NULL
UPDATE geezer SET
    prescriptions = CONCAT(prescriptions, ' Extra pudding on Thursdays!')
    WHERE person_id IN (SELECT DISTINCT person_id FROM game_score NATURAL JOIN
    game NATURAL JOIN game_type WHERE type_name = 'cribbage' 
    ORDER BY person_id);
    
UPDATE geezer SET
    prescriptions = 'Extra pudding on Thursdays!'
    WHERE person_id IN (SELECT DISTINCT person_id FROM game_score NATURAL JOIN
    game NATURAL JOIN game_type WHERE type_name = 'cribbage' ORDER BY person_id)
    AND prescriptions IS NULL;

-- [Problem 8]
-- uses case to sum depending on how many players got the top score
-- only counts games where the min_players amount is greater than one    
SELECT person_id, person_name, 
SUM(CASE 
    WHEN score = (SELECT MAX(score) FROM game_score WHERE game_id = t.game_id)
    AND (SELECT COUNT(person_id) FROM game_score WHERE game_id = t.game_id 
    AND score = (SELECT MAX(score) FROM game_score 
    WHERE game_id = t.game_id)) = 1 THEN 1
    WHEN score = (SELECT MAX(score) FROM game_score WHERE game_id = t.game_id)
    AND (SELECT COUNT(person_id) FROM game_score WHERE game_id = t.game_id 
    AND score = (SELECT MAX(score) FROM game_score 
    WHERE game_id = t.game_id)) > 1 THEN 0.5
    ELSE 0
END) AS total_points FROM
    geezer NATURAL JOIN game_score AS t NATURAL JOIN game NATURAL JOIN game_type
    WHERE min_players > 1
    GROUP BY person_id, person_name
    ORDER BY total_points DESC;
    