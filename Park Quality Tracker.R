# Install required packages (run once)
# install.packages(c("DBI", "RPostgres", "dplyr"))

library(shiny)
library(DBI)
library(RPostgres)
library(dplyr)

# Helper: create secure DB connection
connect_db <- function() {
  dbConnect(
    RPostgres::Postgres(),
    host = Sys.getenv("SUPABASE_HOST"),
    port = 5432,
    dbname = "postgres",
    user = "postgres.cpvqbtxghpobqlbaavlh",
    password = Sys.getenv("SUPABASE_PASSWORD"),
    sslmode = "require"
  )
}

ui <- fluidPage(
  titlePanel("Park Quality Tracker"),
  wellPanel(
    selectInput("park", "Select Park:", 
                choices = c("Central Park", "Prospect Park", "Riverside Park", 
                            "Flushing Meadows", "Battery Park")),
    numericInput("score", "Safety Score (1–5):", value = 3, min = 1, max = 5),
    textInput("notes", "Notes (optional):", placeholder = "e.g., broken swing"),
    actionButton("submit", "Submit Inspection", class = "btn-primary")
  ),
  hr(),
  h3("Recent Inspections"),
  tableOutput("recent_table"),
  h3("Summary by Park"),
  tableOutput("summary_table")
)

server <- function(input, output, session) {
  
  # Create a reactive trigger that fires on submit OR initial load
  refresh_data <- reactiveVal(0)  # starts at 0
  
  observeEvent(input$submit, {
    con <- connect_db()
    on.exit(dbDisconnect(con))
    
    dbExecute(con,
      "INSERT INTO playground_inspections (park_name, inspection_date, safety_score, notes)
       VALUES ($1, CURRENT_DATE, $2, $3)",
      params = list(input$park, input$score, input$notes)
    )
    showNotification("Ispection recorded!", duration = 2)
    
    # Trigger data refresh
    refresh_data(refresh_data() + 1)
  })
  
  # Fetch data whenever refresh_data changes (including initial load)
  recent_data <- reactive({
    refresh_data()  # depend on this value
    
    con <- connect_db()
    on.exit(dbDisconnect(con))
    
    dbGetQuery(con, "
      SELECT park_name, inspection_date, safety_score, notes
      FROM playground_inspections
      ORDER BY inspection_date DESC, id DESC
      LIMIT 10
    ")
  })
  
  output$recent_table <- renderTable(recent_data(), rownames = FALSE)
  
  output$summary_table <- renderTable({
    df <- recent_data()
    if (nrow(df) == 0) return(NULL)
    
    df %>%
      group_by(park_name) %>%
      summarise(
        count = n(),
        avg_score = round(mean(safety_score, na.rm = TRUE), 2),
        .groups = "drop"
      )
  }, rownames = FALSE)
}

shinyApp(ui, server)