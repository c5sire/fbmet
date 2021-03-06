#' metAddin
#'
#' Creates an Rstudio Addin.
#' @import dplyr
#' @import agricolae
#' @import shiny
#' @import miniUI
# @import shinyBS
#' @return exit status
#'
#' @export
metAddin <- function(){

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("MET explorer"),
    miniUI::miniTabstripPanel( selected = "Data",
     miniTabPanel("Data", icon = icon("table"),
      miniContentPanel(padding = 0
      )
     ),
    miniTabPanel("Plots", icon = icon("bar-chart"),
      miniContentPanel(
        #withProgress(message = "Generating plots ...", {
          linkedBiplotUI("met")
        #})
    )),
    miniTabPanel("Report", icon = icon("file-text-o"),
                 miniContentPanel(padding = 0
                 )
    ),
    miniTabPanel("Help", icon = icon("file-o"),
    miniContentPanel(
      helpPanel(fbhelp::list_tutorials("fbmet")[[1]])
    )),
    miniTabPanel("About", icon = icon("info"),
    miniContentPanel(
      helpPanel(fbhelp::list_tutorials("fbmet", name = "about")[[1]],
                center = TRUE)
    ))
    )
  )

  server <- function(input, output, session) {
    plrv =  loadRData((system.file("data/plrv.rda", package="agricolae")))

    model<- with(plrv, AMMI(Locality, Genotype, Rep, Yield,
                 console=FALSE))
    ##ndat <- dplyr::group_by(plrv, "Genotype", "Locality")
    ndat <- with(plrv, dplyr::summarise(group_by(plrv, Genotype, Locality),
                             Yield = mean(Yield))
    )
    withProgress(message = "Generating plots ...", {
      metsel = callModule(met_selected, "met", plrv, model, ndat)
    })
    observeEvent(input$done, {
      stopApp()
    })
  }

  viewer <- paneViewer(300)
  runGadget(ui, server, viewer = viewer)

}
