USE airbnb_db;

-- Data quality summary
SELECT COUNT(*) AS total_rows,
       SUM(price IS NULL) AS null_price,
       SUM(bathrooms IS NULL) AS null_bathrooms,
       SUM(bathrooms_imputed = 'True') AS imputed_rows,
       ROUND(AVG(price), 2) AS avg_price,
       MIN(price) AS min_price,
       MAX(price) AS max_price
FROM airbnb_clean;

-- Price outliers: extremes
SELECT SUM(price < 15) AS under_15,
       SUM(price BETWEEN 15 AND 29.99) AS from_15_to_30,
       SUM(price > 1000) AS over_1000,
       SUM(price > 1500) AS over_1500
FROM airbnb_clean;

SELECT id, price, city, property_type, room_type, accommodates, bedrooms, number_of_reviews
FROM airbnb_clean
WHERE price < 15 OR price > 1500
ORDER BY price;

SELECT price, COUNT(*) AS listings
FROM airbnb_clean
WHERE price BETWEEN 5 AND 20
GROUP BY price
ORDER BY price;

SELECT price_flag, COUNT(*) AS listings
FROM airbnb_clean
GROUP BY price_flag;

-- average and median price
SELECT COUNT(*) AS listings,
       ROUND(AVG(price), 2) AS avg_price,
       (SELECT ROUND(AVG(price), 2) FROM (
           SELECT price,
                  ROW_NUMBER() OVER (ORDER BY price) AS rn,
                  COUNT(*) OVER () AS cnt
           FROM airbnb_clean
        ) t
        WHERE rn IN (FLOOR((cnt + 1) / 2), CEIL((cnt + 1) / 2))
       ) AS median_price
FROM airbnb_clean;

-- price by property type
SELECT property_type, COUNT(*) AS listings,
       ROUND(AVG(price), 2) AS avg_price,
       ROUND(MIN(price), 2) AS min_price,
       ROUND(MAX(price), 2) AS max_price
FROM airbnb_clean
GROUP BY property_type
HAVING COUNT(*) >= 100
ORDER BY avg_price DESC;

-- price by city
SELECT city, COUNT(*) AS listings,
       ROUND(AVG(price), 2) AS avg_price,
       ROUND(MIN(price), 2) AS min_price,
       ROUND(MAX(price), 2) AS max_price
FROM airbnb_clean
GROUP BY city
ORDER BY avg_price DESC;

-- capacity vs price
SELECT accommodates, COUNT(*) AS listings, ROUND(AVG(price), 2) AS avg_price
FROM airbnb_clean
GROUP BY accommodates
ORDER BY accommodates;

-- bedrooms vs price
SELECT bedrooms, COUNT(*) AS listings, ROUND(AVG(price), 2) AS avg_price
FROM airbnb_clean
GROUP BY bedrooms
ORDER BY bedrooms;

-- room type vs price
SELECT room_type, COUNT(*) AS listings, ROUND(AVG(price), 2) AS avg_price
FROM airbnb_clean
GROUP BY room_type
ORDER BY avg_price DESC;

-- rating vs price
SELECT CASE
         WHEN review_scores_rating IS NULL THEN '0. no rating'
         WHEN review_scores_rating < 80 THEN '1. under 80'
         WHEN review_scores_rating < 90 THEN '2. 80-89'
         WHEN review_scores_rating < 95 THEN '3. 90-94'
         WHEN review_scores_rating < 100 THEN '4. 95-99'
         ELSE '5. 100'
       END AS rating_band,
       COUNT(*) AS listings,
       ROUND(AVG(price), 2) AS avg_price
FROM airbnb_clean
GROUP BY rating_band
ORDER BY rating_band;

-- Rated vs unrated by room type
SELECT room_type,
       CASE WHEN review_scores_rating IS NULL THEN 'unrated' ELSE 'rated' END AS rating_status,
       COUNT(*) AS listings,
       ROUND(AVG(price), 2) AS avg_price
FROM airbnb_clean
GROUP BY room_type, rating_status
ORDER BY room_type, rating_status;

-- highest and lowest priced segments
SELECT city, room_type, COUNT(*) AS listings, ROUND(AVG(price), 2) AS avg_price
FROM airbnb_clean
GROUP BY city, room_type
HAVING COUNT(*) >= 100
ORDER BY avg_price DESC;

-- traits of higher-priced listings (price deciles)
SELECT decile,
       MIN(price) AS min_price,
       MAX(price) AS max_price,
       ROUND(AVG(accommodates), 1) AS avg_guests,
       ROUND(AVG(bedrooms), 1) AS avg_bedrooms,
       ROUND(100 * AVG(room_type = 'Entire home/apt'), 1) AS pct_entire_home
FROM (
  SELECT price, accommodates, bedrooms, room_type,
         NTILE(10) OVER (ORDER BY price) AS decile
  FROM airbnb_clean
) t
GROUP BY decile
ORDER BY decile;

-- review volume vs price
SELECT CASE
         WHEN number_of_reviews = 0 THEN '0. none'
         WHEN number_of_reviews <= 5 THEN '1. 1-5'
         WHEN number_of_reviews <= 20 THEN '2. 6-20'
         WHEN number_of_reviews <= 50 THEN '3. 21-50'
         ELSE '4. over 50'
       END AS review_band,
       COUNT(*) AS listings,
       ROUND(AVG(price), 2) AS avg_price
FROM airbnb_clean
GROUP BY review_band
ORDER BY review_band;