# Setup script to load source CSVs into DuckDB for analysis
# Run once before starting SQL analysis: python3 setup_db.py

import duckdb

con = duckdb.connect('cafe_lt.db')

con.execute("CREATE OR REPLACE TABLE customers AS SELECT * FROM read_csv_auto('bronze/customers_lt.csv')")
con.execute("CREATE OR REPLACE TABLE events AS SELECT * FROM read_csv_auto('bronze/events_lt.csv')")
con.execute("CREATE OR REPLACE TABLE offers AS SELECT * FROM read_csv_auto('bronze/offers_lt.csv')")

print("Customers:", con.execute("SELECT COUNT(*) FROM customers").fetchone()[0])
print("Events:", con.execute("SELECT COUNT(*) FROM events").fetchone()[0])
print("Offers:", con.execute("SELECT COUNT(*) FROM offers").fetchone()[0])

con.close()
print("Database ready.")