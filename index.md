Web-based Predictive Analytics
========================================================
author: WE Hopkins
date: 2016-04-21

* Predictive analytics, made possible by current machine learning algorithms, allows for
anticipation based on past patterns
* The caret package in R provides a unified framework for creating models using
many different machine learning algorithms
* Problem: the steep learning curve of R (and caret, and machine learning, etc.)
* Solution: web-based interface for using caret





Proof of Concept
========================================================

The web application is a proof-of-concept prototype supporting the following workflow:

- specifying model training
- selection of model type
- adjusting tuning parameter
- evaluating results
- comparing multiple models

Example Data Set
========================================================

Australian taxpayer attributes and whether audit found errors in tax returns (TARGET_Adjusted)

* develop model to predict whether an audit will find errors

![plot of chunk unnamed-chunk-1](index-figure/unnamed-chunk-1-1.png) 

Overview of Prototype Use
========================================================

Workflow divided between Build Models and Compare Models
* Build Models
    + select training/validation method (5-fold cross-validation default)
    + select model algorithm (conditional tree default)
    + select # of tuning parameter values (3 default) 
    + hit Train Model button
* Compare Models
    + Need two models to compare
    
[Try it out](something)


Further Work
========================================================

To move from proof of concept to useful tool, need to add the
following capabilities:

* load own training data set
* evaluate, transform, and filter data set
* specify tunable parameters customized to the model type
* load separate predictor data set and return predictions 
* use a broader selection of machine learning algorithms
