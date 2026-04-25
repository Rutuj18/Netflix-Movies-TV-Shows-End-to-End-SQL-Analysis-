-- =============================================
-- Netflix SQL Analysis Project
-- 15 Business Problems & Solutions
-- Author: Dikshita Pawar
-- =============================================


-- -----------------------------------------------
-- Q1. Count the Number of Movies vs TV Shows
-- -----------------------------------------------
SELECT 
    type, 
    COUNT(*) AS total_content
FROM netflix
GROUP BY type;


-- -----------------------------------------------
-- Q2. Find the Most Common Rating for Movies and TV Shows
-- -----------------------------------------------
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


-- -----------------------------------------------
-- Q3. List All Movies Released in a Specific Year (e.g., 2020)
-- -----------------------------------------------
SELECT *
FROM netflix
WHERE type = 'Movie' 
  AND release_year = 2020;


-- -----------------------------------------------
-- Q4. Find the Top 5 Countries with the Most Content on Netflix
-- -----------------------------------------------
SELECT 
    country, 
    COUNT(country) AS country_count
FROM netflix
GROUP BY country
ORDER BY country_count DESC
LIMIT 5;


-- -----------------------------------------------
-- Q5. Identify the Longest Movie
-- -----------------------------------------------
SELECT *
FROM netflix
WHERE type = 'Movie' 
  AND duration = (SELECT MAX(duration) FROM netflix);


-- -----------------------------------------------
-- Q6. Find Content Added in the Last 5 Years
-- -----------------------------------------------
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


-- -----------------------------------------------
-- Q7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
-- -----------------------------------------------
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';


-- -----------------------------------------------
-- Q8. List All TV Shows with More Than 5 Seasons
-- -----------------------------------------------
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::NUMERIC > 5;


-- -----------------------------------------------
-- Q9. Count the Number of Content Items in Each Genre
-- -----------------------------------------------
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;


-- -----------------------------------------------
-- Q10. Top 5 Years with Highest Average Content Released in India
-- -----------------------------------------------
SELECT  
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    COUNT(*) AS yearly_content,
    ROUND(
        COUNT(*)::NUMERIC / 
        (SELECT COUNT(*) FROM netflix WHERE country = 'India')::NUMERIC * 100, 2
    ) AS avg_content_pct
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY avg_content_pct DESC
LIMIT 5;


-- -----------------------------------------------
-- Q11. List All Movies that are Documentaries
-- -----------------------------------------------
SELECT *
FROM netflix
WHERE listed_in ILIKE '%documentaries%';


-- -----------------------------------------------
-- Q12. Find All Content Without a Director
-- -----------------------------------------------
SELECT *
FROM netflix
WHERE director IS NULL;


-- -----------------------------------------------
-- Q13. Find How Many Movies Actor 'Salman Khan' Appeared in Over the Last 10 Years
-- -----------------------------------------------
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- -----------------------------------------------
-- Q14. Find the Top 10 Actors in Indian-Produced Content
-- -----------------------------------------------
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*) AS total_content
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY total_content DESC
LIMIT 10;


-- -----------------------------------------------
-- Q15. Categorize Content Based on 'Kill' and 'Violence' Keywords
-- -----------------------------------------------
WITH categorized AS (
    SELECT *,
        CASE
            WHEN description ILIKE '%kill%' 
              OR description ILIKE '%violence%' THEN 'Bad Content'
            ELSE 'Good Content'
        END AS category
    FROM netflix
)
SELECT 
    category,
    COUNT(*) AS total_content
FROM categorized
GROUP BY category;
