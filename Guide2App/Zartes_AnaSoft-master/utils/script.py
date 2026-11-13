import pandas as pd
import pyodbc

# Connection string for Access database in shared drive
conn_str = (
    r'Driver={Microsoft Access Driver (*.mdb, *.accdb)};'
    r'DBQ=\\qmadnas\zartes\DOCUZAR\Analisis e Informes\ZarTESDB.mdb;'
)

# Create connection
conn = pyodbc.connect(conn_str)

# Your query
query = """
SELECT ID_TES FROM [Data_Acquisition]
"""

# Execute query and load into DataFrame
df = pd.read_sql(query, conn)

# Print results
print(df)

# Optional: save to CSV
# df.to_csv('output.csv', index=False)

# Close connection
conn.close()
