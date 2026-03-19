# 🛰️ Remote Sensing Applications
### Vegetation, Wildfire & Land Cover Analysis

This project uses satellite imagery to answer three real-world environmental questions:
- **Is this crop field healthy?** — tracked using NDVI over time
- **How bad was this wildfire?** — mapped using burn severity index (dNBR)
- **What's on this land?** — classified using Landsat 8 spectral bands

Once the raster analysis is complete in ArcGIS Pro, the results are exported as attribute tables and loaded into a SQL database — making it possible to filter, aggregate, and summarize findings without reopening the GIS software. For example, querying which pixels had negative NDVI, how much area fell into each burn severity class, or how different land cover types compare in NIR reflectance.

All analysis was done in **ArcGIS Pro** and **ERDAS Imagine**, with results queried using **SQL**.

---

## 🗄️ SQL — Querying the Results

Raster attribute tables exported from ArcGIS Pro are loaded into a relational database. SQL is then used to summarize and filter findings across all three parts of the project.

**Part A — Track average NDVI across the crop season:**
```sql
SELECT
    image_date,
    ROUND(AVG(ndvi), 3)  AS avg_ndvi,
    ROUND(MIN(ndvi), 3)  AS min_ndvi,
    ROUND(MAX(ndvi), 3)  AS max_ndvi
FROM ndvi_timeseries
GROUP BY image_date
ORDER BY image_date;
```

**Part B — See how much area burned at each severity level:**
```sql
SELECT
    severity,
    COUNT(*)                               AS pixel_count,
    ROUND(AVG(dnbr), 3)                   AS avg_dnbr,
    ROUND(100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (), 2)         AS pct_of_total
FROM burn_severity
GROUP BY severity
ORDER BY avg_dnbr DESC;
```

**Part C — Compare how different land cover types reflect NIR light:**
```sql
SELECT
    class_name,
    ROUND(AVG(band5), 3)  AS avg_nir
FROM land_cover
GROUP BY class_name
ORDER BY avg_nir DESC;
```

---

## 📁 What's in This Repo

```
remote-sensing-analysis/
├── PartA/        → Soybean field vegetation analysis (SPOT-4 imagery)
├── PartB/        → King Fire burn severity mapping (Landsat 8)
├── PartC/        → Palm Desert land cover classification (Landsat 8)
├── Remote_Sensing_Applications_Data.pdf   → Full written report
├── LICENSE
└── README.md
```

---

## 🌿 Part A — Is the Crop Healthy? (NDVI Analysis)

**What I did:** Loaded 6 satellite images of a soybean field taken between August and October 1998. Computed NDVI for each image to track how the vegetation changed over the growing season.

**What is NDVI?**
NDVI (Normalized Difference Vegetation Index) measures how green and healthy vegetation is. It uses the difference between Near-Infrared (NIR) and Red light — healthy plants absorb red light and reflect NIR strongly, so a high NDVI = healthy, low or negative NDVI = dead or bare.

```
NDVI = (NIR − Red) / (NIR + Red)
```

| NDVI Range | Meaning |
|---|---|
| 0.6 – 1.0 | Dense healthy vegetation |
| 0.2 – 0.6 | Moderate vegetation |
| 0.0 – 0.2 | Sparse vegetation |
| < 0.0 | Bare soil, water, or dead plants |

**What I found:**
- NDVI was high in August — crops were actively growing
- By late September NDVI went **negative**, confirming the crops had died off
- The NIR and Red band values directly reflected the change in chlorophyll activity

**Files in `PartA/`:**

| File | What it is |
|---|---|
| `AOI_soybeanfield.shp` | The boundary of the study area (the field) |
| `AOI_soybeanfield.dbf` | Data table attached to that boundary |
| `AOI_soybeanfield.prj` | The coordinate system the map uses |
| `AOI_soybeanfield.cpg` | Text encoding file (needed for the .dbf to read correctly) |
| `spot-0804.img` to `spot-1026.img` | The 6 satellite images, one per date |

> A shapefile is actually 4 files working together — `.shp` (shape), `.dbf` (data), `.prj` (projection), `.cpg` (encoding). All four are required.

---

## 🔥 Part B — How Bad Was the Fire? (Burn Severity Mapping)

**What I did:** Compared satellite images of the King Fire taken before (2013) and after (2015) to measure how severely the land was burned, using a metric called dNBR.

**What is dNBR?**
NBR (Normalized Burn Ratio) measures vegetation and moisture using SWIR and NIR bands. By subtracting the post-fire NBR from the pre-fire NBR, you get dNBR — the higher the value, the more severe the burn.

```
NBR  = (NIR − SWIR) / (NIR + SWIR)
dNBR = NBR_prefire − NBR_postfire
```

| dNBR Range | Burn Severity |
|---|---|
| < −0.10 | Enhanced Regrowth |
| −0.10 to 0.09 | Unburned |
| 0.10 to 0.26 | Low |
| 0.27 to 0.43 | Moderate |
| 0.44 to 0.65 | High |
| > 0.66 | Very High |

**What I found:**
- The core of the fire perimeter showed **moderate burn severity**
- Areas near water bodies and low-fuel terrain came back as unburned
- Post-fire SWIR reflectance increased significantly — a clear indicator of vegetation loss

**Files in `PartB/`:**

| File | What it is |
|---|---|
| `KingFire20130730` | Pre-fire Landsat image (July 2013) |
| `KingFire20150805` | Post-fire Landsat image (August 2015) |
| `NBR_PreFire.tfw` | World file — positions the pre-fire NBR raster on the map |
| `NBR_PostFire.tfw` | World file — positions the post-fire NBR raster on the map |
| `dNBR.tfw` | World file — positions the final burn severity raster on the map |

> A `.tfw` world file is a small text file that tells GIS software where on Earth a raster image is located and what scale it's at.

---

## 🏜️ Part C — What's on This Land? (Land Cover Classification)

**What I did:** Used Landsat 8 imagery over Palm Desert, California to identify 9 different types of land cover by analyzing how each surface reflects light across 6 spectral bands.

**How does it work?**
Every surface (water, trees, roads, buildings) reflects light differently across the electromagnetic spectrum. By comparing reflectance values across bands, you can distinguish land cover types — this is called spectral profiling.

**Landsat 8 Bands Used:**

| Band | What it captures | Why it's useful |
|---|---|---|
| Band 2 — Blue | Short visible light | Detects water, atmospheric scatter |
| Band 3 — Green | Mid visible light | Vegetation vigor |
| Band 4 — Red | Long visible light | Chlorophyll absorption |
| Band 5 — NIR | Near-infrared | Vegetation health (used in NDVI) |
| Band 6 — SWIR-1 | Short-wave infrared | Moisture content, burn detection |
| Band 7 — SWIR-2 | Short-wave infrared | Burn severity (used in NBR) |

**Land Cover Classes Identified:**
Bare Soil · Pond · Salton Sea · Cropland 1 · Cropland 2 · Fallow · Trees · Road · Residential

**Files in `PartC/`:**

| File | What it is |
|---|---|
| `LC08_..._MTL.txt` | Landsat 8 metadata — sensor info, acquisition date, calibration |
| `LC08_..._ANG.txt` | Sun angle coefficients used to correct reflectance values |
| `palmdesert_stack234567.aux` | All 6 bands stacked into one file for analysis |
| `lc08_..._b2–b7.aux` | Each band as a separate file |

---

## ⬇️ Data Sources

Large `.tif` raster files are not included in this repo due to file size. Download the originals here:

- **Landsat 8 imagery** — [USGS Earth Explorer](https://earthexplorer.usgs.gov)
- **SPOT-4 imagery** — [CNES / Airbus Defence](https://www.intelligence-airbusds.com)
- **King Fire boundary** — [CAL FIRE](https://www.fire.ca.gov)

---

## 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| ArcGIS Pro | Raster processing, NDVI/NBR computation, classification |
| ERDAS Imagine | Image processing and band analysis |
| SQL | Querying and summarizing exported raster attribute tables |
| Landsat 8 (OLI) | Multispectral imagery for Parts B and C |
| SPOT-4 | Time-series imagery for Part A |

---

## 📄 Full Report

See `Remote_Sensing_Applications_Data.pdf` for all maps, charts, and written analysis.

---
