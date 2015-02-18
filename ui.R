# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

# static data
#  prompt for claim level dropdown
claimLabels <- c("Claimed" = "C", "Verified" = "V", "Approved" = "A")

shinyUI(fluidPage(

   # Application title
   titlePanel("x2VOL Volunteering Data"),
   # Subtitle / description
   helpText("Displays volunteering and service learning completed by students using the ", a("x2VOL volunteer tracking system", href = "http://www.x2vol.com", target = "_blank"), " (data is in hours volunteered). This system contains data for approximately 375 schools - primarily high schools but also containing some middle schools - and about 150,000 students. Due to the system's rapid growth, most data is concentrated in recent years."),
   helpText("Select the start date by sliding ", strong("Since Year"), " and status of volunteering time by selecting ", strong("Claim Level"), ". Volunteering data on or after the given year start is displayed. Claim Level/Status may be: ", strong("Claimed"), " - hours reported by the volunteer; ", strong("Verified"), " - hours verified by a third-party such as the person or organization the volunteering was done for, and ", strong("Approved"), " - hours approved by a school counselor toward graduation, extracurricular, or other goals set by the school."),
   helpText("Circles on the map represent zip codes where student volunteers live. Circles are shaded to show the number of volunteers and sized to show the number of hours they volunteered. In clustered areas, hover over the area to magnify the area. Hover over individual markers to show the location and volunteering hours selected."),
   
   # Sidebar with controls
   sidebarLayout(
      sidebarPanel(
         # slider input for starting year
         sliderInput("since_year", "Since Year:",
            min = 2010, max = 2015, value = 2010, sep = ""),
         # volunteer claim level (claimed, verified, approved)
         selectInput("claim_level", "Claim Level:",
                     choices = claimLabels, selected = "C")
    ),

    # Show a map of claims
    mainPanel(
      htmlOutput("claim_map"),
      htmlOutput("claim_help")
    )
  )
))
