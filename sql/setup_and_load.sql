CREATE DATABASE IF NOT EXISTS airbnb_db;
USE airbnb_db;

DROP TABLE IF EXISTS airbnb_clean;

CREATE TABLE airbnb_clean (
  id BIGINT,
  log_price DOUBLE,
  property_type VARCHAR(50),
  room_type VARCHAR(50),
  amenities TEXT,
  accommodates INT,
  bed_type VARCHAR(50),
  cancellation_policy VARCHAR(50),
  cleaning_fee VARCHAR(10),
  city VARCHAR(50),
  description TEXT,
  first_review VARCHAR(30),
  host_has_profile_pic VARCHAR(10),
  host_identity_verified VARCHAR(10),
  host_response_rate DOUBLE,
  host_since VARCHAR(30),
  instant_bookable VARCHAR(10),
  last_review VARCHAR(30),
  latitude DOUBLE,
  longitude DOUBLE,
  name VARCHAR(500),
  neighbourhood VARCHAR(100),
  number_of_reviews INT,
  review_scores_rating DOUBLE,
  bedrooms DOUBLE,
  beds DOUBLE,
  price DOUBLE,
  bathrooms_imputed VARCHAR(10),
  bathrooms DOUBLE
);

LOAD DATA LOCAL INFILE '/path/to/airbnb_clean.csv'
INTO TABLE airbnb_clean
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(id, log_price, property_type, room_type, amenities, accommodates,
 bed_type, cancellation_policy, cleaning_fee, city, description,
 first_review, host_has_profile_pic, host_identity_verified,
 @host_response_rate, host_since, instant_bookable, last_review,
 latitude, longitude, name, neighbourhood, number_of_reviews,
 @review_scores_rating, @bedrooms, @beds, @price,
 bathrooms_imputed, @bathrooms)
SET host_response_rate = NULLIF(@host_response_rate, ''),
    review_scores_rating = NULLIF(@review_scores_rating, ''),
    bedrooms = NULLIF(@bedrooms, ''),
    beds = NULLIF(@beds, ''),
    price = NULLIF(@price, ''),
    bathrooms = NULLIF(@bathrooms, '');

ALTER TABLE airbnb_clean
ADD COLUMN price_flag VARCHAR(20)
GENERATED ALWAYS AS (
  CASE
    WHEN price < 15 THEN 'low_suspect'
    WHEN price > 1500 AND accommodates <= 2 THEN 'high_suspect'
    ELSE 'ok'
  END
) STORED;

SELECT COUNT(*) AS total_rows FROM airbnb_clean;