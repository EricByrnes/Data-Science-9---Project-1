
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

suppressPackageStartupMessages(library(googleVis))
suppressPackageStartupMessages(library(dplyr))
library(shiny)

# static data
#  help text for claim level selection
claimHelp <- c(
   "C" = "Number of volunteering hours claimed by volunteers",
   "V" = "Number of volunteering hours verified by a third party",
   "A" = "Number of volunteering hours approved by schools toward graduation or other formal service learning requirement")
#  field name
claimField <- c(
   "C" = "Claimed Hours",
   "V" = "Verified Hours",
   "A" = "Approved Hours")

# query data
claims <- read.csv("./Claims.csv",
                   colClasses = c("Date",
                                  rep("numeric", 3),
                                  rep("integer", 2),
                                  "character",
                                  rep("numeric", 2),
                                  "character",
                                  "character"),
                   stringsAsFactors = FALSE)
#  fix up unverified / unapproved claims
claims[is.na(claims$VerifiedHrs), "VerifiedHrs"] <- 0
claims[is.na(claims$ApprovedHrs), "ApprovedHrs"] <- 0
# zip code latitude/longitude lookup
zips <- read.csv("./ClaimZips.csv",
                 colClasses = c("character",
                                rep("numeric", 2),
                                "character",
                                "character"),
                 stringsAsFactors = FALSE)
zips[, "ZipDesc"] <- paste0("Zip Code ", zips[, "Zip"],
                            " (", zips[, "StateCode"], ")")

claims.filter <- claims


shinyServer(function(input, output) {
   
   # get inputs
   #  get year (start date) to query
   sinceDate <- reactive({ as.Date(paste0(input$since_year, "-01-01")) })
   #  get hours field to query
   queryField <- reactive(claimField[[input$claim_level]])
   
   # set outputs
   #  set help text explaining what is being displayed
   output$claim_help <- renderText(paste0("Showing: ", claimHelp[[input$claim_level]],
                                          ", from January 1, ", input$since_year, " on"))
   
   # draw map
   output$claim_map <- renderGvis({
      # generate data
      #  filter data according to inputs
      claims.filter <- claims %>%
         filter(WorkMonth >= sinceDate()) %>%
         group_by(Zip) %>%
         summarise(ClaimedHrs = sum(ClaimedHrs),
                   VerifiedHrs = sum(VerifiedHrs),
                   ApprovedHrs = sum(ApprovedHrs),
                   NumClaims = sum(NumClaims),
                   NumVolunteers = sum(NumVolunteers))
      
      #  column names
      names(claims.filter)[2:4] <- claimField
      names(claims.filter)[5:6] <- c("Number of Claims", "Number of Volunteers")
      
      #  merge with zip code data
      claims.map <- merge(claims.filter, zips, by = "Zip")
      
      gvisGeoChart(claims.map,
         locationvar = "LatLong",
         colorvar = "Number of Volunteers",
         sizevar = queryField(),
         hovervar = "ZipDesc",
         options = list(region = "US", displayMode = "markers",
                        width = 550, height = 370,
                        colorAxis = "{ colors: ['#b3ff99','#00ff00'] }",
                        backgroundColor = "#dfffff")
      )
   })

})
