# Opportunity_Hoarding
R code from Opportunity Hoarding Project

Project Code: 102562-0001-002-00004

Opportunity hoarding is the preservation of boundaries between White communities from communities of color.   These types of  practices concentrate opportunity-enhancing resources (e.g., access to high-quality schools and local revenue) among those already economically and politically advantaged, just as it constrains access to opportunity among people of color.  One example of this phenomenon is the creation of new governments. More research is needed to understand how governance structures such as political fragmentation resulting from cityhood movements can influence other population health and heath inequities, as well as other racial and ethnic groups.  For example, higher levels of jurisdictional fragmentation (e.g., the number of governmental units within an MSA) is associated with higher mortality rates for Black, but not White, Americans.   

This study will set the stage for developing the concept of opportunity hoarding and will provide case studies on the effects of political fragmentation.  This will allow us to identify how political structures shape contexts for population health and other outcomes related to equity. we will assess these relationships at the national level and will present some representative cases at the county level. 



Output for the brief:

National Level Map Graphic of Municpal Incorporation by State since 2000-2022 .
Tract Level Map of Child Opportunity Index in Fulton, DeKalb, Gwinnet County Georgia since 2000
Racial and Income demograpnics for the county and city levels in Georgia


Folders:
	Data
	exports
	graphs


Steps for Running the Code

Step 00: Importing Data Folders from Box
	add census_2020 folder
	muni-incorporation-master folder
	Georgia_Census Tracts
	1_index
	2_subdomains
	3_pop

Step 1: Run muni-incorporation-master/code R files in the Data folder 

Set Up Code: 
	muni-incorp.R
	muni-incorp-state.R

Output: should be exported to the 'exports' folder
	exports/ muni-incorp-full.csv
	exports/ muni-incorp-state-full.csv


Step 2: Run the 01_COI_Index.R

Output: Excel file be exported to 'exports' folder / graphs should be export to 'graphs' folder

1 Excel File
	- COI_Shape_Map.xlsx

3 Map Visualizations
	- COI_Visualization v1.png
	-COI_visualization v2.png
	-state_total.png


Step 3: Run the 02_ATL_Race.R 

	
Output: Excel file be exported to 'exports' folder 

2 Excel Files
	- county_table.xlsx
	- city_table.xlsx





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


This folder of text document maps county level to tract level (geoid20) from the Census Bureau 2020. this helps connect the map to specific county level region's in Georgia