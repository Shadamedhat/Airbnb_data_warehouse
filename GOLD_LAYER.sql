USE Airbnb_DWH;
GO

DROP TABLE IF EXISTS gold.dim_city;
GO

SELECT
    ROW_NUMBER() OVER (ORDER BY city) AS city_key,
    city AS city_name
INTO gold.dim_city
FROM (SELECT DISTINCT city FROM silver.airbnb_listings) AS c;
GO

SELECT * FROM gold.dim_city;
 
 USE Airbnb_DWH;
GO

SELECT
    ROW_NUMBER() OVER (ORDER BY property_type) AS property_type_key,
    property_type AS property_type_name
INTO gold.dim_property_type
FROM (SELECT DISTINCT property_type FROM silver.airbnb_listings) AS p;
GO

SELECT * FROM gold.dim_property_type;

USE Airbnb_DWH;
GO

DROP TABLE IF EXISTS gold.fact_listings;
GO

SELECT
    s.listing_id,
    c.city_key,
    p.property_type_key,
    s.listing_name,
    s.nights,
    s.price_per_night,
    s.rating,
    s.reviews_count,
    s.is_superhost,
    s.is_guest_favorite,
    s.check_in_date,
    s.check_out_date,
    s.listing_url
INTO gold.fact_listings
FROM silver.airbnb_listings AS s
JOIN gold.dim_city AS c
    ON s.city = c.city_name
JOIN gold.dim_property_type AS p
    ON s.property_type = p.property_type_name;
GO

SELECT COUNT(*) AS rows_in_fact FROM gold.fact_listings;


USE Airbnb_DWH;
GO

SELECT
    c.city_name,
    COUNT(*)                          AS listings,
    AVG(f.price_per_night)            AS avg_price_per_night,
    AVG(f.rating)                     AS avg_rating
FROM gold.fact_listings AS f
JOIN gold.dim_city AS c
    ON f.city_key = c.city_key
GROUP BY c.city_name
ORDER BY avg_price_per_night DESC;
  
  USE Airbnb_DWH;
GO

ALTER TABLE gold.dim_city ALTER COLUMN city_key BIGINT NOT NULL;
GO
ALTER TABLE gold.dim_city ADD CONSTRAINT PK_dim_city PRIMARY KEY (city_key);
GO

USE Airbnb_DWH;
GO

ALTER TABLE gold.dim_property_type ALTER COLUMN property_type_key BIGINT NOT NULL;
GO
ALTER TABLE gold.dim_property_type ADD CONSTRAINT PK_dim_property_type PRIMARY KEY (property_type_key);
GO

USE Airbnb_DWH;
GO

ALTER TABLE gold.fact_listings ALTER COLUMN listing_id BIGINT NOT NULL;
GO
ALTER TABLE gold.fact_listings ALTER COLUMN city_key BIGINT NOT NULL;
GO
ALTER TABLE gold.fact_listings ALTER COLUMN property_type_key BIGINT NOT NULL;
GO
ALTER TABLE gold.fact_listings ADD CONSTRAINT PK_fact_listings PRIMARY KEY (listing_id);
GO
ALTER TABLE gold.fact_listings ADD CONSTRAINT FK_fact_city
    FOREIGN KEY (city_key) REFERENCES gold.dim_city (city_key);
GO
ALTER TABLE gold.fact_listings ADD CONSTRAINT FK_fact_property_type
    FOREIGN KEY (property_type_key) REFERENCES gold.dim_property_type (property_type_key);
GO

SELECT @@SERVERNAME;

USE Airbnb_DWH;
GO

IF COL_LENGTH('gold.dim_city', 'image_url') IS NULL
    ALTER TABLE gold.dim_city ADD image_url NVARCHAR(500);
GO

UPDATE gold.dim_city SET image_url = 'https://images.unsplash.com/photo-1534351590666-13e3e96b5017?fm=jpg&q=60&w=800&auto=format&fit=crop' WHERE city_name = 'Amsterdam';
UPDATE gold.dim_city SET image_url = 'https://images.unsplash.com/photo-1603565816030-6b389eeb23cb?fm=jpg&q=60&w=800&auto=format&fit=crop' WHERE city_name = 'Athens';
UPDATE gold.dim_city SET image_url = 'https://images.unsplash.com/photo-1578912996078-305d92249aa6?fm=jpg&q=60&w=800&auto=format&fit=crop' WHERE city_name = 'Barcelona';
UPDATE gold.dim_city SET image_url = 'https://images.unsplash.com/photo-1786007214445-a1080ffa83de?fm=jpg&q=60&w=800&auto=format&fit=crop' WHERE city_name = 'Berlin';
UPDATE gold.dim_city SET image_url = 'https://images.unsplash.com/photo-1616432902940-b7a1acbc60b3?fm=jpg&q=60&w=800&auto=format&fit=crop' WHERE city_name = 'Budapest';
UPDATE gold.dim_city SET image_url = 'https://images.unsplash.com/photo-1578859651203-c7126a106b59?fm=jpg&q=60&w=800&auto=format&fit=crop' WHERE city_name = 'Lisbon';
UPDATE gold.dim_city SET image_url = 'https://images.unsplash.com/photo-1486299267070-83823f5448dd?fm=jpg&q=60&w=800&auto=format&fit=crop' WHERE city_name = 'London';
UPDATE gold.dim_city SET image_url = 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?fm=jpg&q=60&w=800&auto=format&fit=crop' WHERE city_name = 'Paris';
UPDATE gold.dim_city SET image_url = 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?fm=jpg&q=60&w=800&auto=format&fit=crop' WHERE city_name = 'Rome';
UPDATE gold.dim_city SET image_url = 'https://images.unsplash.com/photo-1516550893923-42d28e5677af?fm=jpg&q=60&w=800&auto=format&fit=crop' WHERE city_name = 'Vienna';
GO

SELECT city_name, image_url FROM gold.dim_city ORDER BY city_name;