USE Airbnb_DWH;
GO
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT URL) AS unique_urls
FROM bronze.Airbnb_Scraped_Data;
/* =====================================================
   01_data_checks.sql
   Checks on bronze.Airbnb_Scraped_Data (read-only: nothing is changed)
   Run each section separately: select it, then press F5
   ===================================================== */

USE Airbnb_DWH;
GO

/*  Duplicates: total rows vs unique URLs
      (equal numbers = no duplicates)
*/
SELECT COUNT(*)            AS total_rows,
       COUNT(DISTINCT URL) AS unique_urls
FROM bronze.Airbnb_Scraped_Data;

/* -----------------------------------------------------
   2. Missing values per column (NULL, empty text or 'N/A')
      Our result was: Property_type 26, Price 1, Rating 5, rest 0
   ----------------------------------------------------- */
SELECT
    SUM(CASE WHEN Name          IS NULL OR TRIM(Name)          IN ('', 'N/A') THEN 1 ELSE 0 END) AS name_missing,
    SUM(CASE WHEN city          IS NULL OR TRIM(city)          IN ('', 'N/A') THEN 1 ELSE 0 END) AS city_missing,
    SUM(CASE WHEN Property_type IS NULL OR TRIM(Property_type) IN ('', 'N/A') THEN 1 ELSE 0 END) AS type_missing,
    SUM(CASE WHEN Price         IS NULL OR TRIM(Price)         IN ('', 'N/A') THEN 1 ELSE 0 END) AS price_missing,
    SUM(CASE WHEN Rating        IS NULL OR TRIM(Rating)        IN ('', 'N/A') THEN 1 ELSE 0 END) AS rating_missing,
    SUM(CASE WHEN Reviews       IS NULL OR TRIM(Reviews)       IN ('', 'N/A') THEN 1 ELSE 0 END) AS reviews_missing,
    SUM(CASE WHEN Superhost     IS NULL OR TRIM(Superhost)     IN ('', 'N/A') THEN 1 ELSE 0 END) AS superhost_missing,
    SUM(CASE WHEN is_fav        IS NULL OR TRIM(is_fav)        IN ('', 'N/A') THEN 1 ELSE 0 END) AS fav_missing,
    SUM(CASE WHEN URL           IS NULL OR TRIM(URL)           IN ('', 'N/A') THEN 1 ELSE 0 END) AS url_missing
FROM bronze.Airbnb_Scraped_Data;
/*name/city/type/price/rating/review/superhost/fav/url
  0 	0	 26	  1	     5	     0	   0	   0	0
/* -----------------------------------------------------
   3. Data types: which values can NOT be converted to numbers?
   ----------------------------------------------------- */*/

SELECT DISTINCT Rating
FROM bronze.Airbnb_Scraped_Data
WHERE TRY_CAST(Rating AS DECIMAL(3,2)) IS NULL;

-- Reviews should be a whole number 
SELECT DISTINCT Reviews
FROM bronze.Airbnb_Scraped_Data
WHERE TRY_CAST(Reviews AS INT) IS NULL;

-- Price: first character 
SELECT DISTINCT LEFT(Price, 1) AS first_char
FROM bronze.Airbnb_Scraped_Data;

-- Superhost values (expected: Yes / No)
SELECT DISTINCT Superhost FROM bronze.Airbnb_Scraped_Data;

-- is_fav values (expected: 0 / 1)
SELECT DISTINCT is_fav FROM bronze.Airbnb_Scraped_Data;


/* -----------------------------------------------------
   4. Suspicious rows: Guest Favorite with 0 reviews
      (impossible: probably a scraping error, e.g. "1,048 reviews")
      Open the URL and check the real number
   ----------------------------------------------------- */
SELECT city, Rating, Reviews, URL
FROM bronze.Airbnb_Scraped_Data
WHERE is_fav = '1' AND Reviews = '0';


/* -----------------------------------------------------
   5. Cleaning preview (display only, nothing is saved)
   ----------------------------------------------------- */
SELECT TOP 20
    TRIM(Name) AS listing_name,
    TRIM(city) AS city,
    CASE WHEN Property_type IS NULL OR TRIM(Property_type) IN ('', 'N/A')
         THEN 'Unknown' ELSE TRIM(Property_type) END AS property_type,
    TRY_CAST(REPLACE(REPLACE(Price, '$', ''), ',', '') AS DECIMAL(10,2)) AS price_total_5n,
    TRY_CAST(Rating AS DECIMAL(3,2)) AS rating,
    TRY_CAST(Reviews AS INT)         AS reviews_count,
    CASE WHEN TRIM(Superhost) = 'Yes' THEN 1 ELSE 0 END AS is_superhost,
    TRY_CAST(is_fav AS INT)          AS is_guest_favorite
FROM bronze.Airbnb_Scraped_Data;

SELECT city, Rating, Reviews AS reviews_old,
    CASE
        WHEN URL LIKE '%/rooms/30760852?%'            THEN 2146
        WHEN URL LIKE '%/rooms/1767525449338384697?%' THEN 5
        WHEN URL LIKE '%/rooms/1760009089107539804?%' THEN 6
        WHEN URL LIKE '%/rooms/1723009770919631335?%' THEN 5
        WHEN URL LIKE '%/rooms/1713755369289986895?%' THEN 5
        WHEN URL LIKE '%/rooms/1373696?%'             THEN 1048
        ELSE TRY_CAST(Reviews AS INT)
    END AS reviews_new
FROM bronze.Airbnb_Scraped_Data
WHERE is_fav = '1' AND Reviews = '0';