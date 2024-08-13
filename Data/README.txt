About the datasets

Municipal Mapping Dataset: https://github.com/cbgoodman/muni-incorporation 

This repository contains the R code and raw spreadsheets needed to create an individual-level and state-specific dataset of dates of municipal incorporation for all active (included in the Census of Governments) municipalities in the United States. 

Relevant data Indictors include: 

	Census ID Number, Census County Numeric Code, Census Unit Numeric Code 

	FIPS County Numeric Code, FIPS Place Numeric Code 

	Coordinates 

	Year of municipal incorporation 


COI data: Child Opportunity Index Data : https://data.diversitydatakids.org/dataset/coi30-2020-tracts-child-opportunity-index-3-0-database--2020-census-tracts

The Child Opportunity Index (COI) 3.0 is a composite index of neighborhood features that help children thrive. COI 3.0 was first released in March 2024 and is updated annually. It builds on COI 2.0, which was released in 2020. The data available on this page is for 2020 census tracts, i.e., census tracts as defined for the 2020 Decennial Census.
	1_index: COI 3.0 overall index and three domains
	Child Opportunity Levels, Scores and composite z-scores for the overall index and three domains (2020 	census tracts)

	2_subdomain: COI 3.0 subdomains
	Child Opportunity Levels, Scores and composite z-scores for 14 subdomains (2020 census tracts)

	3_pop: Child population data
	Number of children aged 0-17 years by race/ethnicity (2020 census tracts)


Georgia_Census_Tract: https://mcdc.missouri.edu/applications/geocorr2022.html

This workbook, which mostly contains data attained from a query I ran using the above tool. In this sheet, census tracts are the unique identifier of the rows, found in the column, Tract. The other columns give details about a given census tract. 

Using these data, I have created a binary variable, found in the column labeled municipal incorporation indicator that has a value of one for tracts that fall within places that were incorporated in the 21st century and zero otherwise. 
This code connect the Place level municipality data to the COI data in order to create the map.

Census_2020: https://www2.census.gov/geo/maps/DC2020/PL20/st13_ga/censustract_maps/
Contains
	Dekalb_tract_geoid20 : Dekalb County Tracts
	Fulton_tract_geoid20 : Fulton County Tracts
	Gwinnett_tract_geoid20 : Gwinnett County Tracts


This folder of text document maps county level to tract level (geoid20) from the Census Bureau 2020. this helps connect the map to specific county level region's in Georgia.