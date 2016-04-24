# server part of shiny app

require(party)
require(pamr)
require(kernlab)
require(cluster)
require(survival)
require(shiny)
require(caret)
require(readr)
require(dplyr)


shinyServer(function(input,output) {
    
    data_set <- NULL
    
    dataSet <- function() {
        if (is.null(data_set)) {
            audit.df <- read_csv("audit.csv")
            audit.df <- audit.df%>%mutate(TARGET_Adjusted=factor(TARGET_Adjusted))
            data_set <<- audit.df
        }
        data_set
    }
    
    trainControlFunc <- function (train_method) {
        trainControl(method=train_method,
                     number=5
        )
    }
    
    model_list <- list()
    
    # need to have model list reactive so that model comparisons re-evaluate
    # when models are added/changed
    modelList <- reactive ({
        current_model <- currentModel()
        
        model_type <- current_model$method
        
        # if the model list is not empty
        if (length(model_list)>0) {
            # remove the entry if a model of this type is in the list
            list_elem <- vapply(model_list,FUN.VALUE = logical(1),
                                FUN=function(l) l$model_type==model_type)
            if (sum(list_elem)>0) {
                model_list[[which(list_elem)]] <<- NULL
            }
        }
        
        # add the model to the list of models
        model_list[[length(model_list)+1]] <<- list(model_type=model_type,
                                                    model=current_model
        )
        
        model_list
    })
    
    currentModel <- reactive ({
        model_type <- input$model_type
        set.seed(20160420)
        model_obj <- train(form=TARGET_Adjusted~.,
                           data=dataSet()%>%dplyr::select(-RISK_Adjustment),
                           method=model_type,
                           trControl=trainControlFunc(input$train_method),
                           tuneLength=input$tune_length)
        
        
        model_obj
    })
    
    output$model_text_out <- renderPrint({
        print(currentModel())
    })
    
    output$model_plot <- renderPlot({
        plot(currentModel(),main="Tunable parameter values vs. accuracy")
    })
    
    output$model_confusion_matrix <- renderPrint({
        confusionMatrix(currentModel())
    })
    

    ##
    ## Compare Models page
    ##
    
    output$model_list_view <- renderPrint({
        data_frame(models=vapply(modelList(),FUN.VALUE=character(1),FUN=function(l) l$model_type))
    })
    
    resamplingResults <- reactive ({
        the_model_list <- modelList()
        if(length(the_model_list)<2) {
            return(NULL)
        }
        the_models <- lapply(the_model_list,function(l) l$model)
        the_model_names <- vapply(the_models,FUN.VALUE=character(1),FUN=function(m) m$method)
        resamples(the_models,modelNames=the_model_names)
    })
    
    output$model_statistics <- renderPrint({
        resampling_results <- resamplingResults()
        if (is.null(resampling_results)) {
            return("Must have at least two models built to run comparisons.")
        }
        summary(resampling_results)
    })
    
    output$model_comparison_text <- renderPrint({
        resampling_results <- resamplingResults()
        if (is.null(resampling_results)) {
            return("Must have at least two models built to run comparisons.")
        }
        summary(diff(resampling_results))
    })
    
})