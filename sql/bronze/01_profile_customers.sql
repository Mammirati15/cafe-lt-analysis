/*
 * Author: Matt A.
 * Date: April 25th, 2026
 * Layer: Bronze
 * Input: customers_lt.csv
 * Output: Customers.md
 * Known Issues: 
 *  2,175 records with age=118 and null income (invalid sentinel values).
 *  gender has null values for unknown customers.
 *  became_member_on stored as integer (yyyymmdd), requires casting to date.
 *  Full distribution of age and income to be verified for additional outliers.
 * Last Modified: April 25th, 2026
 */

 --First identify the number of rows for base
 SELECT COUNT(*) FROM customers;

 -- Check for duplicate customer IDs
SELECT customer_id, COUNT(*) as count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Count nulls per field
SELECT 
    COUNT(*) - COUNT(customer_id) as null_customer_id,
    COUNT(*) - COUNT(age) as null_age,
    COUNT(*) - COUNT(income) as null_income,
    COUNT(*) - COUNT(gender) as null_gender,
    COUNT(*) - COUNT(became_member_on) as null_became_member
FROM customers;

-- Identify invalid age records
SELECT COUNT(*) as invalid_age_count
FROM customers
WHERE age = 118;

-- Age and income distribution
SELECT 
    MIN(age) as min_age,
    MAX(age) as max_age,
    ROUND(AVG(age),1) as avg_age,
    MIN(income) as min_income,
    MAX(income) as max_income,
    ROUND(AVG(income),1) as avg_income
FROM customers;

-- Gender distribution
SELECT gender, COUNT(*) as count
FROM customers
GROUP BY gender
ORDER BY count DESC;