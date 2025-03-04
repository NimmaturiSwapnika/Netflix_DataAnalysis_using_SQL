--  Actual data is saved in Excel, all the columns are taken from the data present in Excel
-- Creating a table


CREATE TABLE netflix(
show_id	varchar(255),
type varchar(255),
title varchar(255),
director varchar(255),
casts varchar(1000),      
country	varchar(255),
date_added varchar(255),
release_year int,
rating varchar(255),
duration varchar(255),
listed_in varchar(255),
description varchar(255)
);


SELECT * FROM netflix;

-- Checking if all the data is imported from Excel to the pgAdmin4 database management tool
SELECT COUNT(*) AS total_rows from netflix;


-- Business questions:

-- 1. Count the no.of movies and TV Shows

SELECT COUNT(*) FROM netflix
WHERE type = 'Movie';

SELECT COUNT(*) FROM netflix
WHERE type = 'TV Show';


-- To get the no.of movies & TV Shows in a single query

SELECT type, count(*)
FROM netflix
GROUP BY type;




-- 2. Find the most common rating for movies & Tv shows
SELECT * FROM netflix;

\* 'The rating column contains characters, it is not an integer, so we cannot use MAX(), 
to find the most common rating'
*/

SELECT type, rating
FROM (
SELECT type, rating, COUNT(*),
RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
FROM netflix
GROUP BY type, rating) AS t1
WHERE ranking = 1



-- 3. List all movies released in 2000
SELECT * FROM netflix;

SELECT title, release_year
FROM netflix
WHERE type = 'Movie' and release_year = 2000;

-- To get all the details of the movies:

SELECT * FROM netflix
WHERE type = 'Movie' AND release_year = 2000;



-- 4. Find the top 5 countries with the most content on Netflix
SELECT * FROM netflix;

\* "If we do this, then it doesnt give us the actual counts, because, there are multiple 
rows, in which there are multiple countrie's in single observation. We need to split them
to get the accurate answer"
*/

select country, count(type) as count from netflix
group by country
order by count desc
limit 5;

-- To get the accurate solution, we are splitting the countries
/*
String_to_array(): used to split the string by delimiter into an array
UNNEST(): Used to turn the array into individual rows
*/

SELECT 
UNNEST(string_to_array(country, ',')) as new_country
FROM netflix


SELECT * FROM netflix; 

-- In the query below, United States is appearing twice, it might be because of the space
SELECT 
UNNEST(string_to_array(country, ',')) as new_country, 
COUNT(type) as total
FROM netflix
group by new_country
order by total desc
limit 5;


-- To get Unique countries, make sure to trim the space

SELECT 
TRIM(UNNEST(string_to_array(country, ','))) as new_country,
COUNT(type) as total
FROM netflix
group by new_country
order by total desc
limit 5;



-- 5. Identify the longest & shortest movie
SELECT * FROM netflix; 

SELECT title, type, MAX(duration), MIN(duration) 
FROM netflix
GROUP BY title, type
HAVING type = 'Movie';


-- Identify the longest movie
SELECT *
FROM netflix
where type = 'Movie'
AND 
duration = (SELECT MAX(duration) FROM netflix);


-- Identify the shortest movie
SELECT * FROM netflix
WHERE type = 'Movie'
AND 
duration = (SELECT MIN(duration) FROM netflix WHERE type = 'Movie');


\* In the above subquery, it is important to use the where clause because there might be 
rows that are of non-movie record and they might contain a NULL value as its minimum duration, 
Since NULL values do not match any actual duration values in the table, the main query 
will return no results. To prevent this, we must filter the subquery with WHERE 
type = 'Movie' so that it returns the smallest valid duration specifically for movies.


Whereas, for MAX, there is no need to mention the type = 'Movie' in subquery because,
it picks the maximum duration from entire table which could be from a movie or a non-movie.
However, the main query ensures that only rows where type = 'Movie' are returned. Even if
the max duration happens to come from a non-movie record, it will still match a movie 
record with the same duration (if it exists), so filtering in the subquery is unnecessary.
*/



-- 6. Find content added in the last 5 years
SELECT * FROM netflix; 

\* 'We should convert the date_added from char into date first. To get the last 5 years
we can use current_date which gives todays date and then substract it from 5' */

SELECT *
FROM netflix 
WHERE TO_DATE(date_added, 'Month-DD, YYYY') >= current_date - INTERVAL '5 years';



-- 7. Find all the movies/ TV Shows directed by "Sangeeth Sivan"

-- This gives exact match
SELECT * FROM netflix
WHERE director = 'Sangeeth Sivan';


-- The LIKE operator is used to get all the records which has the name Sangeeth Sivan.
SELECT * FROM netflix
WHERE director LIKE '%Sangeeth Sivan%';


\* "ILIKE is used for case-sensitivity, if there are any records that are not matching 
exactly with Sangeeth Sivan and is sangeeth sivan, it still considers" */
SELECT * FROM netflix
WHERE director ILIKE '%Sangeeth Sivan%';




-- 8. List all TV Shows with more than 7 seasons
SELECT * FROM netflix; 

\* "The duration col is in text (ex: 1 season), so we need to only get the numbers 
from duration so we use split_part() to get the numbers seperated in a new col. 
Now this new col is also in text, but we need it as number so used cast to type convert  
&    "
*/
SELECT * FROM netflix
WHERE type = 'TV Show' AND 
CAST(split_part(duration, ' ', 1) AS NUMERIC) > 7;


-- Display the new column sessions
SELECT *, split_part(duration, ' ', 1) as sessions
FROM netflix
WHERE type = 'TV Show';


-- This query isn't right because, we can't use '>' with string/text, it should be used with numbers
SELECT * FROM netflix
WHERE type = 'TV Show' AND duration >= '7 seasons';


--9. Count no.of content items in each genre
SELECT * FROM netflix; 

SELECT  UNNEST(string_to_array(listed_in, ',')) as all_genre, COUNT(*) as count_of_items_each_genre
FROM netflix
GROUP BY all_genre;


/* 10. Find each year & the average no.of content release in India on Netflix. 
Return top 5 year with highest average content release */
SELECT * FROM netflix; 

SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year, COUNT(*)
FROM netflix 
where country ILIKE '%India%'
GROUP BY year;


-- TO GET THE AVERAGE CONTENT

/* count(*) --> gives us the yearly content,
(SELECT COUNT(*) FROM netflix WHERE country = 'India') --> gives us total content of India
To get average --> yearly content/ total content * 100

We need to convert into numeric, otherwise it gives us division error (gives 0 as output)
*/

SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year, 
COUNT(*) AS yearly_Content, 
ROUND(COUNT(*):: numeric/ (SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100, 2) AS average_content_per_year
FROM netflix 
where country ILIKE '%India%'
GROUP BY year;


-- Average content in USA
SELECT * FROM NETFLIX;


SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year, 
COUNT(*) AS no_of_content, 
ROUND(COUNT(*)::numeric/ (SELECT COUNT(*) FROM netflix WHERE country = 'United States'):: numeric*100, 2) AS average_content_per_year
FROM NETFLIX
where country ILIKE '%United States%'
GROUP BY year
ORDER BY no_of_content DESC
LIMIT 5;



-- 11. List all the Comedy movies

\* "This is not returning any of the records because, the genre is 'Comedies' but 
we used comedies, case sensitivity." */

SELECT * FROM netflix
WHERE type = 'Movie' AND listed_in LIKE '%comedies%';


-- To make it work, use ILIKE or write exactly as it is in the actual table
SELECT * FROM netflix
WHERE type = 'Movie' AND listed_in ILIKE '%Comedies%';



-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL;


-- 13. Find all the movies actor "Akshay Kumar" appeared in the last 10 years

SELECT * FROM netflix
WHERE casts ILIKE '%Akshay Kumar%' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14. Find top 10 actors who appeared in highest no.of movies produced in USA
SELECT * FROM netflix;


SELECT UNNEST(string_to_array(casts, ',')) as actors, COUNT(*) as no_of_movies 
FROM netflix
WHERE type = 'Movie' AND country ILIKE '%United States%'
GROUP BY actors 
ORDER BY no_of_movies DESC 
LIMIT 10;

-- INDIA
SELECT UNNEST(string_to_array(casts, ',')) as actors, COUNT(*) as no_of_movies 
FROM netflix
WHERE type = 'Movie' AND country ILIKE '%India%'
GROUP BY actors 
ORDER BY no_of_movies DESC 
LIMIT 10;


\* 15. a. Categorize content based on presence of keywords 'Kill' & 'Violence' in description
field. Label this content as 'Flagged' & others as 'Unflagged'. 
b. Count no.of items in each category */

SELECT * FROM netflix;

\* CTE (common table expression) is used here to store the categorization logic 
(through the CASE statement).

We need to categorize the content based on the presence of keywords (like 'Kill' & 'Violence') 
using a CASE statement. 
However, we cannot directly use the result of the CASE statement in the GROUP BY clause 
without first creating a derived result set.

A CTE is useful because it allows us to define a temporary result set (which includes the categorization logic via the CASE statement) 
and then we can reference it in the main query to perform additional operations, 
like COUNT and GROUP BY.


After creating this temporary result set, we can reference it to perform operations like
COUNT and GROUP BY, which is needed because, the problem is to count the no.of items in 
each category.
*/

 
WITH new_table 
AS(
SELECT *,
	CASE
		WHEN description ILIKE '%kill%' THEN 'Flagged'
		WHEN description ILIKE '%Violence%' THEN 'Flagged'
		ELSE 'Unflagged'
	END AS Category_label
FROM netflix
)
SELECT Category_label, COUNT(*) AS total_content
FROM new_table
GROUP BY Category_label;
