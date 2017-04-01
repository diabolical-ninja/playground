"""
Title:  Database Connections 
Desc:   Simple script demonstrating how to connect to a variety of databases
Author: Yass
Date:   2017-03-20
"""

# Libraries






# PostgreSQL  ####
import psycopg2

# Setup connection
conn = psycopg2.connect("dbname='house' user='<>' password='<>' host='<address>' port='5432'")
cur = conn.cursor()

# Simple test query
cur.execute("select * from leads")
rows = cur.fetchall()

for row in rows:
    print row
