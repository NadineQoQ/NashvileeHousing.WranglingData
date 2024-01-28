# Nashville Housing SQL Using MySQL

## Dataset Link
[Download Dataset](https://www.kaggle.com/datasets/bvanntruong/housing-sql-project)

## Database Setup
1. Create a new database named `nashville_housing`.
2. Use the created database: `USE nashville_housing`.

## Table Creation
- Create a table named `nashville_data` to store housing information with various columns.

## Loading Dataset
1. Place the dataset file ('Nashville Housing Data for Data Cleaning.csv') in your own path.
2. Load the dataset into the `nashville_data` table using the provided SQL query.

## Cleaning Data
1. View the initial data with `SELECT * FROM nashville_housing.nashville_data;`.
2. Standardize date formats, handle missing values, and populate property addresses.
3. Break down address fields into individual columns for better analysis.
4. Transform categorical values such as 'Y' and 'N' to 'Yes' and 'No' in the 'SoldAsVacant' field.
5. Remove duplicate records and delete unused columns.

Feel free to adapt the script and queries based on specific dataset characteristics and analysis requirements.
