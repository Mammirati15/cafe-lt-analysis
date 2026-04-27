/*
 * Author: Matt A.
 * Date: April 26th, 2026
 * Layer: Bronze
 * Input: events_lt.csv
 * Output: events_profiling.md
 * Known Issues: 
 *   396 duplicates (all columns the same) all with offer completed events
 *   JSON from the value column needs addressing
 *   2,175 invalid customer records (age=118) exist in customers table.
 *   Their events appear in this table and must be filtered on every join
 *   to prevent contamination of completion counts and demographic analysis.
 * Last Modified: April 26th, 2026
 */

 --Count number of rows
 SELECT COUNT(*) FROM events;

--Check for duplicates where all columns match
 SELECT customer_id, event, value, time, COUNT(*) as count 
 FROM events
 GROUP BY customer_id, event, value, time
 HAVING COUNT(*) > 1

 -- Null counts per field
SELECT
    COUNT(*) - COUNT(customer_id) as null_customer_id,
    COUNT(*) - COUNT(event) as null_event,
    COUNT(*) - COUNT(value) as null_value,
    COUNT(*) - COUNT(time) as null_time
FROM events;

-- Event type distribution
SELECT event, COUNT(*) as count
FROM events
GROUP BY event
ORDER BY count DESC;

-- Time range
SELECT MIN(time) as min_time, MAX(time) as max_time
FROM events;

-- Sample value field by event type to observe JSON structure
SELECT event, value
FROM events
GROUP BY event, value
LIMIT 10;