### Individualized Prediction of Remission, Part II
### Author: Michelle Worthington, 2020 

### This code performs feature selection in a clinical dataset and trains a GBM classification model to predict clinical recovery. 

library(glmnet)
library(caret)
library(smotefamily)
library(pROC)
library(e1071)
library(ROSE)
library(DMwR)

## Feature selection process using elastic net regularization in training set (NAPLS3)

# Create model matrix for elastic net #
NAPLS3_x = model.matrix(SOPS_rem.6months ~ ., data = NAPLS3_train)[,-1]
NAPLS3_y = NAPLS3_train$SOPS_rem.6months

enetN3 = glmnet(NAPLS3_x, NAPLS3_y,
                family = "binomial", 
                alpha = .5,
                nlambda = 100, 
                lambda.min.ratio = .0001,
                pmax = 10)
enetN3$a0

featselect_results = coef(enetN3, s = .03)
featselect_results

## Use results from feauture selection process to create new subsets for model development 

training_set = subset(NAPLS3_train, select = c(SOPS_rem.6months, P1_SOPS.BL, P2_SOPS.BL, N5_SOPS.BL,
                                                   D3_SOPS.BL, D4_SOPS.BL, G3_SOPS.BL, G4_SOPS.BL, 
                                                   CDS4.BL, CDS7.BL))
testing_set = subset(NAPLS2_test, select = c(SOPS_rem.6months, P1_SOPS.BL, P2_SOPS.BL, N5_SOPS.BL,
                                                 D3_SOPS.BL, D4_SOPS.BL, G3_SOPS.BL, G4_SOPS.BL, 
                                                 CDS4.BL, CDS7.BL))
training_set = training_set %>%
  mutate(Remit = ifelse(SOPS_rem.6months == 1, "remit", "nonremit")) %>%
  mutate(SOPS_rem.6months = NULL)
  
testing_set = testing_set %>%
  mutate(Remit = ifelse(SOPS_rem.6months == 1, "remit", "nonremit")) %>%
  mutate(SOPS_rem.6months = NULL)


## Building predictive models using gradient boosting machine 

#### To account for outcome class imbalance, implementing synthetic oversampling technique in training folds
train_control = trainControl(method = "cv", 
                             number = 10, 
                             classProbs = T, 
                             summaryFunction = twoClassSummary)

gbmGrid = expand.grid(interaction.depth = c(1:5),
                      n.trees = c(25,50,100,150),
                      shrinkage = 0.1, 
                      n.minobsinnode = 10)


#### Training GBM model 
GBM_model = caret::train(Remit ~ .,
                         data = training_set,
                         method = "gbm",  
                         metric = "ROC",
                         maximize = T,  
                        # trGrid = gbmGrid,
                         trControl = train_control,
                         verbose = F)
GBM_model
getTrainPerf(GBM_model) 
GBM_model$bestTune 
varImp(GBM_model, scale = F) 


#### Testing model performance in NAPLS2 test set 

GBM_predictions = predict(GBM_model, newdata = testing_set, type = "prob") %>% # predict on a continuous scale for AUC
  mutate(pred = ifelse(remit > median(remit), 1, 0))
GBM_predictions_roc = pROC::roc(predictor = GBM_predictions$remit, response = testing_set$Remit)
pROC::auc(GBM_predictions_roc)
pROC::ci.auc(GBM_predictions_roc)

GBM_binary_preds = predict(GBM_model, newdata = testing_set) # predict binary outcomes for confusion matrix 
confusionMatrix(GBM_binary_preds, as.factor(testing_set$Remit), positive = "remit") 

# optimizing cutoff for testing model performance

test_cutoff = ifelse(GBM_predictions$remit > median(GBM_predictions$remit), "remit", "nonremit")
confusionMatrix(as.factor(test_cutoff), as.factor(testing_set$Remit), positive = "remit") 



