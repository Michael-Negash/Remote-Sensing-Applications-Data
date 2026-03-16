# Remote Sensing Applications: Vegetation, Wildfire & Land Cover Analysis
**ArcGIS Pro · Raster Analysis · Landsat · Burn Severity Mapping · ERDAS Imagine**

## Overview
Multi-part remote sensing analysis covering vegetation health monitoring, 
wildfire burn severity mapping, and land cover classification using 
SPOT-4 and Landsat 8 imagery.

---

## Part A — Vegetation Health & NDVI Analysis (Soybean Field)
Processed SPOT-4 time-series imagery (Aug–Oct 1998) to compute NDVI 
and analyze seasonal vegetation patterns across a soybean field.

**Key Findings:**
- NDVI tracked full crop cycle from growth to senescence
- Negative NDVI values in late September confirmed crop die-off
- NIR and Red band contrast validated chlorophyll activity changes

**Files:**
| File | Description |
|------|-------------|
| `AOI_soybeanfield.shp` | Study area boundary shapefile |
| `AOI_soybeanfield.prj` | Projection file |
| `spot-0804.img` | SPOT-4 imagery — Aug 4, 1998 |
| `spot-0819.img` | SPOT-4 imagery — Aug 19, 1998 |
| `spot-0914.img` | SPOT-4 imagery — Sep 14, 1998 |
| `spot-0925.img` | SPOT-4 imagery — Sep 25, 1998 |
| `spot-1010.img` | SPOT-4 imagery — Oct 10, 1998 |
| `spot-1026.img` | SPOT-4 imagery — Oct 26, 1998 |

---

## Part B — Wildfire Burn Severity Mapping (King Fire)
Assessed wildfire damage using pre- and post-fire Landsat imagery 
and dNBR burn severity classification in ArcGIS Pro.

**Key Findings:**
- Post-fire NBR confirmed vegetation loss and increased SWIR reflectance
- Center of fire perimeter showed moderate burn severity
- Unburned areas linked to water bodies and low-fuel terrain

**Files:**
| File | Description |
|------|-------------|
| `dNBR.tfw` | dNBR world file |
| `NBR_PreFire.tfw` | Pre-fire NBR world file |
| `NBR_PostFire.tfw` | Post-fire NBR world file |
| `KingFire20130730` | Pre-fire Landsat imagery (2013) |
| `KingFire20150805` | Post-fire Landsat imagery (2015) |

---

## Part C — Land Cover Classification (Palm Desert, Landsat 8)
Generated spectral profiles for 9 land-cover classes using Landsat 8 
imagery and analyzed band reflectance patterns for classification.

**Land Cover Classes:**
Bare Soil · Pond · Salton Sea · Cropland 1 · Cropland 2 · 
Fallow · Trees · Road · Residential

**Files:**
| File | Description |
|------|-------------|
| `LC08_L1TP_039037_20200721_20200722_01_RT_MTL.txt` | Landsat 8 metadata |
| `LC08_L1TP_039037_20200721_20200722_01_RT_ANG.txt` | Angle coefficient file |
| `palmdesert_stack234567.aux` | Band stack (Bands 2–7) |
| `lc08_..._b2–b7.aux` | Individual Landsat 8 bands |

---

## ⚠️ Large Files Not Included
`.tif` raster files are excluded due to large file sizes.

**Download source data here:**
- **Landsat 8 imagery:** [USGS Earth Explorer](https://earthexplorer.usgs.gov)
- **SPOT-4 imagery:** [CNES / Airbus Defence](https://www.intelligence-airbusds.com)
- **King Fire boundary:** [CAL FIRE](https://www.fire.ca.gov)

---

## Tools & Technologies
- **Software:** ArcGIS Pro, ERDAS Imagine
- **Methods:** NDVI, NBR, dNBR, Burn Severity Mapping, 
  Spectral Profile Analysis, Raster & Vector Processing
- **Data:** SPOT-4, Landsat 8 (OLI), Shapefile vectors

---

## Full Report
See `Remote Sensing Applications Data.pdf` for complete analysis and results.
