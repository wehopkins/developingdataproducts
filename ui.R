# user interface part of shiny app

require(caret)
require(shiny)

shinyUI(
    navbarPage(
        "Predictive Analytics",
        tabPanel(
            "Build Models",
            fluidPage(
                fluidRow(
                    h5("Specify Training Control"),
                    column(5,
                           selectInput("train_method","training method",
                                       choices=list(
                                           "cross-validation"="cv",
                                           "repeated cross-validation"="repeatedcv",
                                           "bootstrap"="boot",
                                           "bootstrap with adjustment"="boot632",
                                           "leave-one-out cross-validation"="LOOCV",
                                           "fit one model"="none"
                                       ),selected="cv"
                           )
                    )
                ),
                fluidRow(
                    column(5,
                           selectInput("model_type","model algorithm",
                                       choices=list(
                                           "conditional inference tree"="ctree",
                                           "flexible discriminant analysis"="fda",
                                           "k-nearest neighbors"="knn",
                                           "nearest shrunken centroids"="pam",
                                           "naive bayes"="nb",
                                           #"linear discriminant analysis"="lda", need to accommodate no tuneables
                                           "support vector machine, radial"="svmRadial"
                                       ),
                                       selected="ctree"
                           ),
                           h5("tuning parameters"),
                           numericInput("tune_length","count of values",value=3,
                                        min=1,max=10,step=1),
                           submitButton("Train Model"),
                           br(),
                           verbatimTextOutput("model_confusion_matrix")
                           
                    ),
                    column(7,
                           verbatimTextOutput("model_text_out"),
                           plotOutput("model_plot")
                    )
                )
                
                
            )
        ),                 
        tabPanel(
            "Compare Models",
            fluidPage(
                column(3,
                       verbatimTextOutput("model_list_view")
                ),
                column(5,
                       verbatimTextOutput("model_statistics"))
            ))
    )
)
