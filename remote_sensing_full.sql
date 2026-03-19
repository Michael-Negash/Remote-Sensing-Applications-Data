-- ================================================================
-- Remote Sensing Applications — SQL Query Suite
-- Vegetation, Wildfire & Land Cover Analysis
-- Author: Michael-Negash
-- ================================================================


-- ================================================================
-- SCHEMA — Run these first to create the tables
-- ================================================================

CREATE TABLE ndvi_timeseries (
    pixel_id    INTEGER,
    image_date  DATE,
    nir         FLOAT,
    red         FLOAT,
    ndvi        FLOAT
);

CREATE TABLE burn_severity (
    pixel_id    INTEGER,
    nbr_pre     FLOAT,
    nbr_post    FLOAT,
    dnbr        FLOAT,
    severity    TEXT   -- 'Enhanced Regrowth','Unburned','Low','Moderate','High','Very High'
);

CREATE TABLE land_cover (
    pixel_id    INTEGER,
    class_name  TEXT,
    band2       FLOAT,  -- Blue
    band3       FLOAT,  -- Green
    band4       FLOAT,  -- Red
    band5       FLOAT,  -- NIR
    band6       FLOAT,  -- SWIR-1
    band7       FLOAT   -- SWIR-2
);


-- ================================================================
-- PART A — Vegetation Health & NDVI Analysis (Soybean Field)
-- ================================================================

-- Average NDVI per image date — tracks the full crop cycle
SELECT
    image_date,
    ROUND(AVG(ndvi), 3)  AS avg_ndvi,
    ROUND(MIN(ndvi), 3)  AS min_ndvi,
    ROUND(MAX(ndvi), 3)  AS max_ndvi
FROM ndvi_timeseries
GROUP BY image_date
ORDER BY image_date;


-- Flag pixels with negative NDVI — confirms crop die-off
SELECT
    pixel_id,
    image_date,
    ROUND(ndvi, 3)  AS ndvi
FROM ndvi_timeseries
WHERE ndvi < 0
ORDER BY image_date, ndvi ASC;


-- Count how many pixels went negative per date
SELECT
    image_date,
    COUNT(*)  AS dead_pixel_count
FROM ndvi_timeseries
WHERE ndvi < 0
GROUP BY image_date
ORDER BY image_date;


-- NDVI change from first image to last — measures full seasonal decline
SELECT
    a.pixel_id,
    ROUND(a.ndvi, 3)            AS ndvi_start,
    ROUND(b.ndvi, 3)            AS ndvi_end,
    ROUND(b.ndvi - a.ndvi, 3)  AS ndvi_change
FROM ndvi_timeseries a
JOIN ndvi_timeseries b
    ON a.pixel_id = b.pixel_id
WHERE a.image_date = (SELECT MIN(image_date) FROM ndvi_timeseries)
  AND b.image_date = (SELECT MAX(image_date) FROM ndvi_timeseries)
ORDER BY ndvi_change ASC;


-- Classify each pixel-date into a vegetation health category
SELECT
    pixel_id,
    image_date,
    ROUND(ndvi, 3) AS ndvi,
    CASE
        WHEN ndvi >= 0.6  THEN 'Dense Vegetation'
        WHEN ndvi >= 0.2  THEN 'Moderate Vegetation'
        WHEN ndvi >= 0.0  THEN 'Sparse Vegetation'
        ELSE                   'Bare / Dead'
    END AS health_class
FROM ndvi_timeseries
ORDER BY image_date, pixel_id;


-- Summary: count of pixels per health class per date
SELECT
    image_date,
    CASE
        WHEN ndvi >= 0.6  THEN 'Dense Vegetation'
        WHEN ndvi >= 0.2  THEN 'Moderate Vegetation'
        WHEN ndvi >= 0.0  THEN 'Sparse Vegetation'
        ELSE                   'Bare / Dead'
    END AS health_class,
    COUNT(*) AS pixel_count
FROM ndvi_timeseries
GROUP BY image_date, health_class
ORDER BY image_date, health_class;


-- ================================================================
-- PART B — Wildfire Burn Severity Mapping (King Fire)
-- ================================================================

-- Pixel count and percentage breakdown by severity class
SELECT
    severity,
    COUNT(*)                                   AS pixel_count,
    ROUND(AVG(dnbr), 3)                       AS avg_dnbr,
    ROUND(MIN(dnbr), 3)                       AS min_dnbr,
    ROUND(MAX(dnbr), 3)                       AS max_dnbr,
    ROUND(100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (), 2)             AS pct_of_total
FROM burn_severity
GROUP BY severity
ORDER BY avg_dnbr DESC;


-- Filter high and very high severity pixels only
SELECT
    pixel_id,
    ROUND(dnbr, 3)  AS dnbr,
    severity
FROM burn_severity
WHERE severity IN ('High', 'Very High')
ORDER BY dnbr DESC;


-- Pre vs post fire NBR comparison — shows vegetation loss per pixel
SELECT
    pixel_id,
    ROUND(nbr_pre, 3)              AS nbr_pre,
    ROUND(nbr_post, 3)             AS nbr_post,
    ROUND(nbr_pre - nbr_post, 3)  AS nbr_loss,
    severity
FROM burn_severity
ORDER BY nbr_loss DESC;


-- Average NBR loss grouped by severity class
SELECT
    severity,
    ROUND(AVG(nbr_pre - nbr_post), 3)  AS avg_nbr_loss
FROM burn_severity
GROUP BY severity
ORDER BY avg_nbr_loss DESC;


-- Classify burn severity from raw dNBR values
SELECT
    pixel_id,
    ROUND(dnbr, 3) AS dnbr,
    CASE
        WHEN dnbr < -0.10                     THEN 'Enhanced Regrowth'
        WHEN dnbr BETWEEN -0.10 AND 0.09      THEN 'Unburned'
        WHEN dnbr BETWEEN  0.10 AND 0.26      THEN 'Low'
        WHEN dnbr BETWEEN  0.27 AND 0.43      THEN 'Moderate'
        WHEN dnbr BETWEEN  0.44 AND 0.65      THEN 'High'
        ELSE                                       'Very High'
    END AS severity_class
FROM burn_severity
ORDER BY dnbr DESC;


-- ================================================================
-- PART C — Land Cover Classification (Palm Desert, Landsat 8)
-- ================================================================

-- Average reflectance per land cover class across all 6 bands
SELECT
    class_name,
    ROUND(AVG(band2), 3)  AS avg_blue,
    ROUND(AVG(band3), 3)  AS avg_green,
    ROUND(AVG(band4), 3)  AS avg_red,
    ROUND(AVG(band5), 3)  AS avg_nir,
    ROUND(AVG(band6), 3)  AS avg_swir1,
    ROUND(AVG(band7), 3)  AS avg_swir2
FROM land_cover
GROUP BY class_name
ORDER BY class_name;


-- Rank all classes by NIR reflectance — vegetation has highest NIR
SELECT
    class_name,
    ROUND(AVG(band5), 3)  AS avg_nir
FROM land_cover
GROUP BY class_name
ORDER BY avg_nir DESC;


-- Identify water bodies — low reflectance across all bands
SELECT
    class_name,
    ROUND(AVG(band2), 3)  AS avg_blue,
    ROUND(AVG(band5), 3)  AS avg_nir,
    ROUND(AVG(band6), 3)  AS avg_swir1
FROM land_cover
WHERE class_name IN ('Pond', 'Salton Sea')
GROUP BY class_name;


-- Compare vegetation vs built-up classes using NIR, SWIR, and Red
SELECT
    class_name,
    ROUND(AVG(band5), 3)  AS avg_nir,
    ROUND(AVG(band6), 3)  AS avg_swir1,
    ROUND(AVG(band4), 3)  AS avg_red
FROM land_cover
WHERE class_name IN ('Trees', 'Cropland 1', 'Cropland 2', 'Fallow',
                     'Bare Soil', 'Road', 'Residential')
GROUP BY class_name
ORDER BY avg_nir DESC;


-- Pixel count per land cover class
SELECT
    class_name,
    COUNT(*)  AS pixel_count
FROM land_cover
GROUP BY class_name
ORDER BY pixel_count DESC;


-- Flag potentially misclassified pixels
-- Trees should have high NIR, roads should have low NIR
SELECT
    pixel_id,
    class_name,
    ROUND(band5, 3)  AS nir
FROM land_cover
WHERE
    (class_name = 'Trees' AND band5 < 0.2)
    OR
    (class_name = 'Road'  AND band5 > 0.4)
ORDER BY class_name, nir;
