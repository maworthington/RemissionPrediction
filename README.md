# RemissionPrediction

How can we optimize the prediction of future clinical outcomes from behavioral and clinical data from a single time point? 

This repository contains code to replicate the analyses performed in Worthington et al. 2021, Schizophrenia Bulletin: Individualized Prediction of Prodromal Symptom Remission for Youth at Clinical High Risk for Psychosis. 

Using data from two distinct waves of the North American Prodrome Longitudinal Study (NAPLS2 and NAPLS3), we used a data-driven method to select relevant clinical, demographic and neurocognitive variables relevant to the outcome of remission. Our method involved the following steps:

1) <b> Testing and training datasets: </b> We used the entire NAPLS3 dataset (n = 567) as the training set and the entire NAPLS2 dataset (n = 553). 

2) <b> Feature selection: </b> We performed an elastic net regularization to select features that were most relevant to the outcome of interest (remitted vs. not remitted). 

3) <b> Model development: </b> We then fed these features to a gradient boost machine (GBM) classification algorithm. During the model training stage, we used 10-fold cross validation. Balanced sampling was performed within each training fold using synthetic minority oversampling technique (SMOTE) to account for the low number of remitters in our dataset. 

4) <b> Model performance: </b> Our classification algorithm developed in NAPLS3 achieved an AUC of 0.66 (0.60–0.72) with a sensitivity of 0.68 and specificity
of 0.53 when tested in the NAPLS2 sample. Overall, remitters had lower baseline prodromal symptoms than nonremitters.

![alt text](https://github.com/maworthington/RemissionPrediction/blob/main/OutcomePredictionWorkflow.png?raw=TRUE)
