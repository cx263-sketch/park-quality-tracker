Park Quality Tracker
A Shiny app for submitting and visualizing park safety inspections, backed by a Supabase PostgreSQL database.

How to Run

1. Install required R packages (run once):
   install.packages(c("shiny", "DBI", "RPostgres", "dplyr"))

2. Set up secure credentials:
   - Create a file named .Renviron in your project root.
   - Add your Supabase connection details (replace with your actual values):
        SUPABASE_HOST=aws-1-us-east-1.pooler.supabase.com
        SUPABASE_PASSWORD=your_actual_password_here
   - Never commit .Renviron to Git! Add it to .gitignore.

3. Run the app:
   source("Park Quality Tracker.R")
   or in RStudio: Click "Run App"

Secure Database Connection

- Credentials are never hardcoded in the script.
- The app uses Sys.getenv() to read SUPABASE_HOST and SUPABASE_PASSWORD from the .Renviron file.
- This follows R best practices for secret management.
- Connection uses SSL (sslmode = "require") for encrypted data transfer.

Database Schema

The app assumes a table named playground_inspections with the following columns:

Column              Type      Description
id                  SERIAL    Auto-incrementing primary key
park_name           TEXT      Name of the park (e.g., "Central Park")
inspection_date     DATE      Date of inspection (defaults to current date)
safety_score        INTEGER   Safety rating from 1 (unsafe) to 5 (very safe)
notes               TEXT      Optional free-text comments

You can create this table in Supabase SQL Editor:

CREATE TABLE playground_inspections (
  id SERIAL PRIMARY KEY,
  park_name TEXT NOT NULL,
  inspection_date DATE DEFAULT CURRENT_DATE,
  safety_score INTEGER CHECK (safety_score BETWEEN 1 AND 5),
  notes TEXT
);

Features

- Submit inspections: Choose park, rate safety (1–5), add notes.
- View recent data: Shows last 10 inspections in descending date order.
- Summary statistics: Counts inspections per park and computes average safety score.
