-- Olympics Games Analysis

SELECT * 
FROM parks_and_recreation.olympic_games_medal_tally;

-- Finding the number of olympic editions from 1896 to 2022

SELECT COUNT(DISTINCT edition) AS Count_edition
FROM olympic_games_medal_tally;

-- Total Number of countries that participated in the Olympics from 1896-2022

SELECT COUNT(DISTINCT country) AS Count_country
FROM olympic_games_medal_tally;

-- Total number of editions participated by each country from 1896 to 2022

SELECT country, COUNT(edition) AS count_edition
FROM olympic_games_medal_tally
GROUP BY country
ORDER BY count_edition DESC;

-- Finding the sum of medals won by each country from 1896-2022

SELECT country, SUM(gold) AS sum_gold, SUM(silver) AS sum_silver, SUM(bronze) AS sum_bronze,
SUM(total) AS sum_total
FROM olympic_games_medal_tally
GROUP BY country
ORDER BY country;

-- Finding the sum of medals won in the United States from 1896-2022

SELECT *
FROM olympic_games_medal_tally
WHERE country = 'United States';

SELECT SUM(gold) AS sum_gold, SUM(silver) AS sum_silver, SUM(bronze) AS sum_bronze, SUM(total) AS sum_total
FROM olympic_games_medal_tally
WHERE country = 'United States';

-- Countries that have won more than 500 medals from the olympics

SELECT * 
FROM (
SELECT country, SUM(gold) AS sum_gold, SUM(silver) AS sum_silver, SUM(bronze) AS sum_bronze,
SUM(total) AS sum_total
FROM olympic_games_medal_tally
GROUP BY country
ORDER BY sum_total DESC
) AS sum_table
WHERE sum_total > 500;

-- The sum of medals given away each year and the number of countries participating each year

SELECT year, COUNT(country) count_country, SUM(gold) sum_gold, 
SUM(silver) sum_silver, SUM(bronze) sum_bronze, SUM(total) sum_total
FROM olympic_games_medal_tally
GROUP BY year
ORDER BY year;

-- Finding the average number of countries participating each year using subquery

SELECT AVG(count_country)
FROM (
SELECT year, COUNT(country) count_country, SUM(gold) sum_gold, 
SUM(silver) sum_silver, SUM(bronze) sum_bronze, SUM(total) sum_total
FROM olympic_games_medal_tally
GROUP BY year
ORDER BY year
) AS count_country_table;

-- Ranking based on the total number of medals won

SELECT country, SUM(gold) AS sum_gold, SUM(silver) AS sum_silver, SUM(bronze) AS sum_bronze,
SUM(total) AS sum_total,
ROW_NUMBER() OVER(ORDER BY SUM(total) DESC) AS Row_num,
RANK() OVER(ORDER BY SUM(total) DESC) AS Rank_num,
DENSE_RANK() OVER(ORDER BY SUM(total) DESC) AS Dense_Rank_num
FROM olympic_games_medal_tally
GROUP BY country
;

-- Using a CTE to find the ranking of Kenya based on the total number of medals won

WITH CTE_Olympics AS
(
SELECT country, SUM(gold) AS sum_gold, SUM(silver) AS sum_silver, SUM(bronze) AS sum_bronze,
SUM(total) AS sum_total,
ROW_NUMBER() OVER(ORDER BY SUM(total) DESC) AS Row_num,
RANK() OVER(ORDER BY SUM(total) DESC) AS Rank_num,
DENSE_RANK() OVER(ORDER BY SUM(total) DESC) AS Dense_Rank_num
FROM olympic_games_medal_tally
GROUP BY country
)
SELECT*
FROM CTE_Olympics
WHERE country = 'Kenya';

-- The number of olympic games that were not held due to war

SELECT *
FROM olympics_games;

SELECT edition, edition_id, isHeld
FROM olympics_games
WHERE isHeld = 'Not held due to war';

-- Finding the number of countries that participated in each olympic endition, sum of medals won, city each edition was held, and the start dates and end dates of the olympic editions

SELECT DISTINCT medal.edition, COUNT(country), SUM(gold), 
SUM(silver), SUM(bronze), SUM(total), games.city, games.country_noc,
games.start_date, games.end_date 
FROM olympic_games_medal_tally AS medal
JOIN olympics_games AS games
ON medal.edition = games.edition 
GROUP BY medal.edition, games.city, games.country_noc,
games.start_date, games.end_date ;

-- Finding which edition had the most number of medals and where was it held and how many countries participated

WITH CTE_Medals AS
(
SELECT DISTINCT medal.edition edition, COUNT(country) count_country, SUM(gold) sum_gold, 
SUM(silver) sum_silver, SUM(bronze) sum_bronze, SUM(total) sum_total, games.city city, games.country_noc country_noc,
games.start_date, games.end_date 
FROM olympic_games_medal_tally AS medal
JOIN olympics_games AS games
ON medal.edition = games.edition 
GROUP BY medal.edition, games.city, games.country_noc,
games.start_date, games.end_date
ORDER BY sum_total DESC
)
SELECT edition, count_country, sum_total, city, country_noc
FROM CTE_Medals
ORDER BY sum_total DESC
;

--  Using Stored Procedure to find the stats of specific countries

DELIMITER $$
CREATE PROCEDURE olympics_medals1(p_medals varchar(50))
BEGIN
	SELECT country, COUNT(edition) editions, SUM(gold) gold, 
	SUM(bronze) bronze, SUM(silver) silver, SUM(total) total
	FROM olympic_games_medal_tally
    WHERE country = p_medals
	GROUP BY country;
END $$
DELIMITER ;

CALL olympics_medals1('United States');

CALL olympics_medals1('Kenya');

-- Using stored procedures to find the statistics of specific editions

DELIMITER $$
CREATE PROCEDURE Olympic_games1(p_medalsedition varchar(100))
BEGIN
	SELECT medals.edition, medals.edition_id, COUNT(country) countries, SUM(gold) gold, SUM(silver) silver, 
	SUM(bronze) bronze, SUM(total) total, games.city, games.country_noc,
	games.start_date, games.end_date
	FROM olympic_games_medal_tally medals
	JOIN olympics_games games
	ON medals.edition = games.edition
    WHERE medals.edition = p_medalsedition
	GROUP BY medals.edition, medals.edition_id, games.city, games.country_noc,
	games.start_date, games.end_date;
END $$
DELIMITER ;

CALL Olympic_games1('1948 Summer Olympics');

CALL Olympic_games1('2020 Summer Olympics');



































