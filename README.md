# 🎬 Netflix Content Analysis — SQL Project

![Netflix](https://img.shields.io/badge/Netflix-E50914?style=for-the-badge&logo=Netflix&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)

A comprehensive SQL-based analysis of Netflix's movies and TV shows dataset. This project extracts actionable business insights by solving 15 real-world business problems using PostgreSQL.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Dataset](#dataset)
- [Schema](#schema)
- [Objectives](#objectives)
- [Business Problems & Solutions](#business-problems--solutions)


---

## Overview

Netflix has thousands of titles spanning movies and TV shows across dozens of countries and genres. This project digs into that catalog using pure SQL to uncover patterns around content type distribution, audience ratings, regional output, cast appearances, and content categorization.

---

## Dataset

The data is sourced from Kaggle:

📦 **[Netflix Movies and TV Shows Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows)**

| Field | Description |
|---|---|
| `show_id` | Unique identifier for each title |
| `type` | Movie or TV Show |
| `title` | Title of the content |
| `director` | Director(s) of the content |
| `casts` | Cast members |
| `country` | Country of production |
| `date_added` | Date added to Netflix |
| `release_year` | Original release year |
| `rating` | Content rating (e.g., PG-13, TV-MA) |
| `duration` | Duration in minutes (movies) or seasons (TV shows) |
| `listed_in` | Genre(s) |
| `description` | Brief description of the content |

---

## Schema

```sql
DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix (
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

---

## Objectives

- Analyze the distribution of content types (Movies vs TV Shows)
- Identify the most common ratings for each content type
- Explore content by release year, country, and duration
- Discover top-producing countries and trending release patterns
- Uncover cast and director insights
- Categorize content by sensitive keywords

---

## Business Problems & Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type, COUNT(*) AS total_content
FROM netflix
GROUP BY type;
```

**Objective:** Understand the split between movies and TV shows on Netflix.

---

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
WITH RatingCounts AS (
    SELECT type, rating, COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT type, rating, rating_count,
           RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT type, rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;
```

**Objective:** Identify the most frequently occurring rating per content type.

---

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT *
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

---

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT country, COUNT(country) AS country_count
FROM netflix
GROUP BY country
ORDER BY country_count DESC
LIMIT 5;
```

**Objective:** Identify which countries produce the most Netflix content.

---

### 5. Identify the Longest Movie

```sql
SELECT *
FROM netflix
WHERE type = 'Movie'
  AND duration = (SELECT MAX(duration) FROM netflix);
```

**Objective:** Find the movie with the longest duration.

---

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve content recently added to Netflix.

---

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by a specific director.

---

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::NUMERIC > 5;
```

**Objective:** Identify long-running TV shows.

---

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;
```

**Objective:** Break down content count by individual genre.

---

### 10. Top 5 Years with Highest Average Content Released in India

```sql
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
```

**Objective:** Rank years by India's content contribution on Netflix.

---

### 11. List All Movies that are Documentaries

```sql
SELECT *
FROM netflix
WHERE listed_in ILIKE '%documentaries%';
```

**Objective:** Filter all documentary content.

---

### 12. Find All Content Without a Director

```sql
SELECT *
FROM netflix
WHERE director IS NULL;
```

**Objective:** Identify titles with missing director information.

---

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in Over the Last 10 Years

```sql
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count appearances of a specific actor in recent content.

---

### 14. Find the Top 10 Actors in Indian-Produced Movies

```sql
SELECT
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*) AS total_content
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY total_content DESC
LIMIT 10;
```

**Objective:** Identify the most prolific actors in India-origin Netflix content.

---

### 15. Categorize Content Based on 'Kill' and 'Violence' Keywords

```sql
WITH new_table AS (
    SELECT *,
        CASE
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad Content'
            ELSE 'Good Content'
        END AS category
    FROM netflix
)
SELECT category, COUNT(*) AS total_content
FROM new_table
GROUP BY category;
```

**Objective:** Label content as 'Bad' or 'Good' based on description keywords and count each group.

---

