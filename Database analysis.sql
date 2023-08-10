-- Analysis Goal:
--Assist app developer determine which aplication should he create.
--Topics to analyze:
--1.Popular genres,
--2. Current prices,
--3. User rating and feedback.

--Performing EDA on a dataset--

--Unique App Count in Both Tables
SELECT COUNT(DISTINCT id) unique_id, count(id) total_entries
from AppleStore

SELECT COUNT(DISTINCT id) unique_id, count(id) total_entries
from appleStore_description_combined

--Checking for any missing values--

--Checking Missing Values in Key Columns
SELECT COUNT(*) missing_values
from AppleStore
where id is NULL
OR track_name is NULL
or user_rating is NULL
or prime_genre is NULL

SELECT COUNT(*) missing_values
from appleStore_description_combined
where id is NULL 
or app_desc is NULL

--Finding out the number of apps per genre--

--Number of Apps per Genre and Additional Analysis
SELECT prime_genre, count(id) app_number
from AppleStore
GROUP by 1
Order by 2 desc


SELECT count(id) num_id
from AppleStore
WHERE rating_count_tot >1

--Since there are a lot of apps with low number of reviews( a lot of 0s and such) i ve decided to exclude all apps that have less than 5.000 reviews
SELECT 
    MIN(rating_count_tot) AS min_reviews,
    MAX(rating_count_tot) AS max_reviews,
    AVG(rating_count_tot) AS avg_reviews,
    COUNT(*) AS total_apps
FROM AppleStore;

--Top 10 genres (excluded genres that have apps with less than 5.000 reviews)
SELECT prime_genre, count(id) app_number, Avg(user_rating) avg_rating, min(user_rating) min_rating, max(user_rating) max_rating
from AppleStore
WHERE rating_count_tot >5.000
GROUP by 1
order by 2 desc, 3 desc
limit 10

--Checking 10 worst rated genres( as an opportunity to make an app that would improve their rating)
SELECT prime_genre, Avg(user_rating) avg_rating
from AppleStore
GROUP by 1
order by 2 asc
limit 10



--Reviews per each content rating group 
SELECT DISTINCT(cont_rating)
from AppleStore

SELECT cont_rating, count(id) app_number, Avg(user_rating) avg_rating
from AppleStore
WHERE rating_count_tot >5
GROUP by 1
order by 3 desc
--Price analysis
--First I'm going to add two new columns app_category and app_pricing. Firt one will tell us whether the app is free or paid, and second one will help us categorize app based on their price.

--Making app_category column
ALTER TABLE AppleStore
ADD COLUMN app_category TEXT;
UPDATE AppleStore
SET app_category = CASE 
    WHEN price = 0 THEN 'Free'
    ELSE 'Paid'
END;

--Checking min and max value before creating price categories
select min(price) min_price, max(price) max_price
from AppleStore

ALTER TABLE AppleStore
ADD COLUMN price_category TEXT;
UPDATE AppleStore
SET price_category = CASE 
        WHEN price = 0 THEN 'Free'
        WHEN price > 0 AND price < 50 THEN '1-49'
        WHEN price >= 50 AND price < 100 THEN '50-99'
        WHEN price >= 100 AND price < 150 THEN '100-149'
        WHEN price >= 150 AND price < 200 THEN '150-199'
        WHEN price >= 200 AND price < 250 THEN '200-249'
        ELSE '250-299.99'
        end

--Average rating for paid and free apps
SELECT app_category, avg(user_rating) avg_reviews
from AppleStore
GROUP by 1
ORDER by 2 desc

--Average rating for each pricing category
SELECT price_category,rating_count_tot,avg(user_rating) avg_reviews
from AppleStore
GROUP by 1
ORDER by 3 desc

--Making "bins" for column lang_num to more easily analyze distribution of reviews for different number of languages that app supports
alter table AppleStore
add column lang_group TEXT
UPDATE AppleStore
set lang_group= case
when lang_num >=0 and lang_num <=15
then "0-15"
when lang_num >15 and lang_num <=30
then "16-30"
when lang_num >30 and lang_num <=45
then "31-45"
when lang_num >45 and lang_num <=60
then "46-60"
when lang_num >60 and lang_num <=75
then "61-75"
END 

--Checking if apps with multiple languages have higher rating
SELECT lang_group, avg(user_rating) avg_reviews
from AppleStore
GROUP by 1
order by 2 desc

--Checking correlation between rating and description length
SELECT case 
when length(adc.app_desc)<500 then 'Short' 
when length(adc.app_desc) BETWEEN 500 and 1000 then 'Medium' 
else 'Long'
end desc_category,
avg(user_rating) avg_reviews
from AppleStore aps
join appleStore_description_combined adc
on aps.id=adc.id
group by 1
order by 2 desc

-- longer reviews tend to be more positive 


--Checking best rated app for each of the genres presented 
select prime_genre, track_name, user_rating
from 
	(
      SELECT
     prime_genre,
      track_name,
      user_rating,
      RANK() OVER (Partition by prime_genre order by user_rating desc, rating_count_tot desc) as rank
      from AppleStore)
      as aps 
where aps.rank=1