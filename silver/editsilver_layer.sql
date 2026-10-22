USE Airbnb_DWH;
GO

DROP TABLE IF EXISTS silver.airbnb_listings;
GO

SELECT
    ROW_NUMBER() OVER (ORDER BY city, URL) AS listing_id,
    TRIM(Name) AS listing_name,
    TRIM(city) AS city,
    CASE WHEN Property_type IS NULL OR TRIM(Property_type) IN ('', 'N/A')
         THEN 'Unknown' ELSE TRIM(Property_type) END AS property_type,
    TRY_CAST(REPLACE(REPLACE(Price, '$', ''), ',', '') AS DECIMAL(10,2)) AS price_total_5n,
    CAST(TRY_CAST(REPLACE(REPLACE(Price, '$', ''), ',', '') AS DECIMAL(10,2)) / 5.0
         AS DECIMAL(10,2)) AS price_per_night,
    TRY_CAST(Rating AS DECIMAL(3,2)) AS rating,
    CASE
        WHEN URL LIKE '%/rooms/30760852?%'            THEN 2146
        WHEN URL LIKE '%/rooms/1767525449338384697?%' THEN 5
        WHEN URL LIKE '%/rooms/1760009089107539804?%' THEN 6
        WHEN URL LIKE '%/rooms/1723009770919631335?%' THEN 5
        WHEN URL LIKE '%/rooms/1713755369289986895?%' THEN 5
        WHEN URL LIKE '%/rooms/1373696?%'             THEN 1048
        ELSE TRY_CAST(Reviews AS INT)
    END AS reviews_count,
    CASE WHEN TRIM(Superhost) = 'Yes' THEN 1 ELSE 0 END AS is_superhost,
    CASE WHEN TRY_CAST(is_fav AS INT) = 1 THEN 1 ELSE 0 END AS is_guest_favorite,
    URL AS listing_url
INTO silver.airbnb_listings
FROM bronze.Airbnb_Scraped_Data;
GO

SELECT COUNT(*) AS rows_in_silver FROM silver.airbnb_listings;
SELECT TOP 10 * FROM silver.airbnb_listings;

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver' AND TABLE_NAME = 'airbnb_listings';
SELECT
    SUM(CASE WHEN price_per_night IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END)          AS null_rating,
    SUM(CASE WHEN property_type = 'Unknown' THEN 1 ELSE 0 END) AS unknown_type
FROM silver.airbnb_listings;

SELECT COUNT(*) AS not_5_nights
FROM bronze.Airbnb_Scraped_Data
WHERE URL NOT LIKE '%check_out=2027-01-15%';

USE Airbnb_DWH;
GO

ALTER TABLE silver.airbnb_listings
ADD check_in_date DATE, check_out_date DATE, nights INT;
GO

UPDATE silver.airbnb_listings
SET check_in_date  = TRY_CAST(SUBSTRING(listing_url, CHARINDEX('check_in=',  listing_url) + 9,  10) AS DATE),
    check_out_date = TRY_CAST(SUBSTRING(listing_url, CHARINDEX('check_out=', listing_url) + 10, 10) AS DATE);
GO

UPDATE silver.airbnb_listings
SET nights = DATEDIFF(DAY, check_in_date, check_out_date);
GO

UPDATE silver.airbnb_listings
SET price_per_night = CAST(price_total_5n / NULLIF(nights, 0) AS DECIMAL(10,2));
GO

SELECT nights, COUNT(*) AS listings
FROM silver.airbnb_listings
GROUP BY nights;
EXEC sp_rename 'silver.airbnb_listings.price_total_5n', 'price_total', 'COLUMN';

select top 10* from silver.airbnb_listings


