DROP TABLE IF EXISTS mart_price_by_neighbourhood;
CREATE TABLE mart_price_by_neighbourhood AS
SELECT 
CASE 
    WHEN UPPER("neighbourhood group") IN ('BROOKLN', 'BROOKLYN') THEN 'BROOKLYN'
    WHEN UPPER("neighbourhood group") IN ('MANHATAN', 'MANHATTAN') THEN 'MANHATTAN'
    ELSE UPPER("neighbourhood group")
END as neighbourhood_group,
ROUND(AVG(REPLACE(REPLACE(REPLACE(price, '$', ''), ' ', ''), ',', '')::NUMERIC), 2) AS price_avg,
ROUND(MAX(REPLACE(REPLACE(REPLACE(price, '$', ''), ' ', ''), ',', '')::NUMERIC), 2) AS price_max,
ROUND(MIN(REPLACE(REPLACE(REPLACE(price, '$', ''), ' ', ''), ',', '')::NUMERIC), 2) AS price_min
FROM "Airbnb_Open_Data" AS ad
GROUP BY 
CASE 
    WHEN UPPER("neighbourhood group") IN ('BROOKLN', 'BROOKLYN') THEN 'BROOKLYN'
    WHEN UPPER("neighbourhood group") IN ('MANHATAN', 'MANHATTAN') THEN 'MANHATTAN'
    ELSE UPPER("neighbourhood group")
END;

DROP TABLE IF EXISTS mart_room_type_summary;
CREATE TABLE mart_room_type_summary AS
SELECT 
"room type",
COUNT(*) AS total_listings,
ROUND(AVG(REPLACE(REPLACE(REPLACE(price, '$', ''), ' ', ''), ',', '')::NUMERIC), 2) AS price_avg
FROM "Airbnb_Open_Data" AS ad
WHERE "room type" IS NOT NULL
GROUP BY 
ad."room type"
ORDER BY total_listings DESC;

DROP TABLE IF EXISTS mart_host_performance;
CREATE TABLE mart_host_performance AS
SELECT 
"host id",
"host name",
COUNT(*) AS total_listings,
ROUND(AVG("review rate number"::NUMERIC), 2) AS avg_review_score
FROM "Airbnb_Open_Data"
WHERE "review rate number" IS NOT NULL
GROUP BY 
"host id",
"host name"
ORDER BY total_listings DESC;