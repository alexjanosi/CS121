-- [Problem 1]
-- drops game_score and game first since they reference 
-- the other tables
DROP TABLE IF EXISTS game_score;
DROP TABLE IF EXISTS game;
DROP TABLE IF EXISTS geezer;
DROP TABLE IF EXISTS game_type;

-- [Problem 2]
-- table includes information about the players
-- at the Northeast Retirement Home
CREATE TABLE geezer (
    -- ID given to each person starting at one
    person_id    INT    NOT NULL AUTO_INCREMENT,
    -- name of person with max of 100 characters
    person_name VARCHAR(100)    NOT NULL,
    -- gender specified with one character (M or F)
    gender    CHAR(1)    NOT NULL,
    -- date (not time) of birth
    birth_date DATE NOT NULL,
    -- string of prescriptions at max of 100 characters
    -- may be NULL
    prescriptions VARCHAR(1000),
    PRIMARY KEY (person_id),
    CHECK ((gender LIKE 'M') OR (gender LIKE 'F'))
);

-- table storing the information about the games at
-- the retirement home
CREATE TABLE game_type (
    -- ID given to each game type starting at one
    type_id    INT    NOT NULL AUTO_INCREMENT,
    -- short name of the game with max 20 characters
    -- candidate key so UNIQUE value
    type_name    VARCHAR(20)    NOT NULL UNIQUE,
    -- string describing the game at max 1000 characters
    game_desc    VARCHAR(1000)    NOT NULL,
    -- minimum amount of players per game (must be one or more)
    min_players INT NOT NULL,
    -- maximum amount of players per game, may be NULL
    max_players INT,
    PRIMARY KEY (type_id),
    CHECK (min_players >= 1),
    CHECK ((max_players IS NULL) OR (max_players >= min_players))
);

-- table storing the information about each game played
-- at the retirement home
CREATE TABLE game (
    -- unique ID value for each game played
    -- starts at one
    game_id    INT    NOT NULL AUTO_INCREMENT,
    -- referenced type ID
    type_id    INT    NOT NULL,
    -- date and time of game played, defaults to current time
    game_date    DATETIME    NOT NULL DEFAULT NOW(),
    PRIMARY KEY (game_id),
    FOREIGN KEY (type_id) REFERENCES game_type(type_id)
);

-- table storing the information about the score of each
-- game played at the retirement home
CREATE TABLE game_score (
    -- referrenced game ID
    game_id     INT    NOT NULL,
    -- referrenced person ID
    person_id    INT    NOT NULL,
    -- score of the game as an INT
    score    INT    NOT NULL,
    PRIMARY KEY (game_id, person_id),
    FOREIGN KEY (game_id) REFERENCES game(game_id),
    FOREIGN KEY (person_id) REFERENCES geezer(person_id)
);
