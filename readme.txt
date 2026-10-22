# Airbnb Data Warehouse & Analytics

## Project Overview

An end-to-end data engineering project focused on Airbnb listings across 10 European cities.

The project demonstrates data collection, data quality assessment, SQL-based data cleaning, dimensional modeling, and business intelligence reporting using Power BI.

## Project Objectives

- Organize Airbnb listing data from multiple European cities.
- Identify missing values, invalid data, and potential duplicates.
- Implement a Medallion Architecture with Bronze, Silver, and Gold layers.
- Design a Star Schema for analytical reporting.
- Analyze listing prices, ratings, reviews, and property characteristics through Power BI.

## Tech Stack

- **Python & Selenium:** Data collection and browser automation
- **SQL Server:** Data storage and warehouse development
- **SQL:** Data quality checks, data cleaning, transformations, and dimensional modeling
- **Power BI:** Data visualization and interactive analytics

## Data Architecture

### Bronze Layer
Stores the raw listing data before applying cleaning transformations.

### Silver Layer
Cleans and standardizes the data, converts columns to appropriate data types, and handles missing or invalid values.

### Gold Layer
Organizes the transformed data into a Star Schema with fact and dimension tables for analytical queries.

## Data Quality

The project includes checks for:

- Duplicate listing URLs
- Missing values
- Price and rating validity
- Data type consistency
- Categorical and binary values

## Data Model

The Gold layer uses a fact table containing listing measures and dimension tables containing descriptive attributes.

The model is designed to support analysis by city, listing, property type, and stay dates, where applicable to the implemented schema.

## Power BI Dashboard

The Power BI report provides an interactive way to explore listing metrics and compare results across cities and property characteristics.

## Repository Structure

- `data/` — source data, if permitted for redistribution
- `sql/` — SQL scripts for the Bronze, Silver, and Gold layers
- `power-bi/` — Power BI report

## How to Use

1. Review the SQL scripts in the `sql/` directory.
2. Configure the SQL Server database and data source as needed.
3. Execute the scripts in the documented order.
4. Open the Power BI report, if included, and configure its data connection.

## Notes

Listing prices represent the total price for the selected stay dates, not necessarily the nightly price.

Data quality and listing attributes may vary depending on the source and collection conditions.

## Author

Shada Medhat