Codebook: Park Quality Tracker

Variables Collected

Variable        Input Type      Allowed Values                                      Description
park            selectInput     "Central Park", "Prospect Park", "Riverside Park", 
                                "Flushing Meadows", "Battery Park"                Name of the inspected park
score           numericInput    Integer 1–5                                       Subjective safety rating 
                                                                                  (1 = very unsafe, 5 = very safe)
notes           textInput       Any text (optional)                               Free-form observations 
                                                                                  (e.g., "broken swing", "clean restroom")

Derived Outputs

Output                      Description                         Calculation
Recent Inspections Table    Last 10 submitted records           SELECT ... ORDER BY inspection_date DESC LIMIT 10
Count per Park              Number of inspections per park      COUNT(*) GROUP BY park_name
Average Safety Score        Mean safety rating per park         ROUND(AVG(safety_score), 2)

Data Flow

1. User fills form → clicks Submit Inspection
2. App connects to Supabase via secure credentials
3. New row inserted into playground_inspections
4. UI automatically refreshes to show updated data