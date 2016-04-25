# server part of shiny app

require(party)
require(pamr)
require(kernlab)
require(cluster)
require(survival)
require(MASS)
require(klaR)
require(earth)
require(plotmo)
require(e1071)
require(plotrix)
require(TeachingDemos)
require(mda)
require(class)
require(shiny)
require(knitr)
require(caret)
require(readr)
require(dplyr)


shinyServer(function(input,output) {
    
    data_set <- NULL
    
    dataSet <- function() {
        if (is.null(data_set)) {
            audit.df <- read_csv("audit.csv")
            audit.df <- audit.df%>%mutate(TARGET_Adjusted=factor(TARGET_Adjusted))%>%
                dplyr::select(-ID,-RISK_Adjustment)
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
    
    nzvCols <- function(data.df) {
        nzv.indices <- nearZeroVar(data.df)
        if (length(nzv.indices>0)) {
            nzv_cols <- names(data.df)[nzv.indices]
            return(paste0("-",nzv_cols))
        }
        
        NULL
    }
    
    type_to_nzv <- c("knn","nb","pam")
    
    typeToFilter <- function(model_type,data.df) {
        if (model_type%in%type_to_nzv) {
            nzv_cols <- nzvCols(data.df)
            return(data.df%>%select_(.dots=nzv_cols))
        }
        data.df
    }
    
    type_to_preprocess <- list("svmRadial"=c("center","scale"),
                               "knn"=c("center","scale"))
    
    typeToPreprocess <- function(model_type) {
        if (model_type%in%names(type_to_preprocess)) {
            return(type_to_preprocess[[model_type]])
        }
        NULL
    }
    
    currentModel <- reactive ({
        model_type <- input$model_type
        set.seed(20160420)
        model_obj <- train(form=TARGET_Adjusted~.,
                           data=typeToFilter(model_type,dataSet()),
                           method=model_type,
                           trControl=trainControlFunc(input$train_method),
                           tuneLength=input$tune_length,
                           preProcess=typeToPreprocess(model_type))
        
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
    
    output$model_list_view <- renderTable({
        data_frame("models built"=vapply(modelList(),FUN.VALUE=character(1),FUN=function(l) l$model_type))
    })
    
    resamplingResults <- reactive ({
        the_model_list <- modelList()
        validate(need(length(the_model_list)>1,
                      message="Must have at least two models built to run comparisons.")
        )
        the_models <- lapply(the_model_list,function(l) l$model)
        the_model_names <- vapply(the_models,FUN.VALUE=character(1),FUN=function(m) m$method)
        resamples(the_models,modelNames=the_model_names)
    })
    
    output$model_statistics <- renderPrint({
        resampling_results <- resamplingResults()
        summary(resampling_results)
    })
    
    output$model_stats_plot <- renderPlot({
        resampling_results <- resamplingResults()
        dotplot(resampling_results)
        
    })
    
    output$model_comparison_text <- renderPrint({
        resampling_results <- resamplingResults()
        summary(diff(resampling_results))
    })
  
    output$model_comparison_plot <- renderPlot({
        resampling_results <- resamplingResults()
        dotplot(diff(resampling_results))
    })
    
      
})