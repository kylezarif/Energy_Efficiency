###################################
#                                 #
#  Create ee set, validation set  #
#                                 #
###################################

if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if(!require(caret)) install.packages("caret", repos = "http://cran.us.r-project.org")
if(!require(data.table)) install.packages("data.table", repos = "http://cran.us.r-project.org")
if(!require(dslabs)) install.packages("corrplot", repos = "http://cran.us.r-project.org")
if(!require(lubridate)) install.packages("lubridate", repos = "http://cran.us.r-project.org")
if(!require(purrr)) install.packages("purrr", repos = "http://cran.us.r-project.org")
if(!require(knitr)) install.packages("knitr", repos = "http://cran.us.r-project.org")
if(!require(dplyr)) install.packages("dplyr", repos = "http://cran.us.r-project.org")
if(!require(corrplot)) install.packages("corrplot", repos = "http://cran.us.r-project.org")
if(!require(rpart)) install.packages("rpart", repos = "http://cran.us.r-project.org")
if(!require(e1071)) install.packages("e1071", repos = "http://cran.us.r-project.org")
if(!require(randomForest)) install.packages("randomForest", repos = "http://cran.us.r-project.org")

# Energy Efficiency dataset:
# https://archive.ics.uci.edu/ml/machine-learning-databases/00242/
# https://archive.ics.uci.edu/ml/datasets/Energy+efficiency
# https://raw.githubusercontent.com/kylezarif/Energy_Efficiency/master/ENB2012_data.xlsx


# Download data
url <- "https://raw.githubusercontent.com/kylezarif/Energy_Efficiency/master/ENB2012_data.xlsx"
eefm <- read.delim(url)

# Updating the name of the columns
colnames(eefm) <- c("Relative_Compactness","Surface_Area","Wall_Area",
                    "Roof_Area", "Overall_Height", "Orientation", "Glazing_Area",
                    "Glazing_Area_Distribution", "Heating_Load", "Cooling_Load")


# Let's see the class and number of missing values
data.frame(cbind(data.frame(VarType=sapply(eefm,class)),data.frame(Total_Missing=sapply(eefm,function(x){sum(is.na(x))}))))

# According to the original project done by Angeliki Xifara and Athanasios Tsanas Let's round outputs Heating Load and Cooling Load to the nearest integer
eefm <- eefm %>%
  mutate(Heating_Load = floor(Heating_Load), Cooling_Load = floor(Cooling_Load))

library(e1071) 
# Validation set will be 20% of eefm data
set.seed(1, sample.kind="Rounding")
# if using R 3.5 or earlier, use `set.seed(1)` instead
n <- nrow(eefm)  # Number of observations
test_index <- round(n*0.80)  # 80% for ee set
set.seed(314)    # Set seed for reproducible results
tindex <- sample(n, test_index)   # Create a random index
ee <- eefm[tindex,]   # Create ee set
validation <- eefm[-tindex,]   # Create validation set

# Validation sets for Heating Load and Cooling Load
validation_hl <- select (validation,-c(Cooling_Load))
validation_cl <- select (validation,-c(Heating_Load))





#####################################################
#                                                   #
# Dividing the ee data into training and test sets  #
#                                                   #
#####################################################

set.seed(1, sample.kind="Rounding")
# test set will be 20% of ee data
# if using R 3.5 or earlier, use `set.seed(1)` instead
n <- nrow(ee)  # Number of observations
test_index <- round(n*0.80)  # 80% for training set
set.seed(314)    # Set seed for reproducible results
tindex <- sample(n, test_index)   # Create a random index
train_set <- ee[tindex,]   # Create train set
test_set <- ee[-tindex,]   # Create test set

# train and test sets for Heating Load Model by removing Cooling Load
train_set_hl <- select (train_set,-c(Cooling_Load))
test_set_hl <- select (test_set,-c(Cooling_Load))

# train and test sets for Cooling Load Model by removing Heating Load
train_set_Cl <- select (train_set,-c(Heating_Load))
test_set_Cl <- select (test_set,-c(Heating_Load))





#######################################
#                                     #
#  Data Exploration and Visualization #
#                                     #
#######################################


###########################
# Considering Heating Load
###########################
# Let's do a Correlation plot to see if there is any strong positive or negative correlation between variables
## Correlation plot
y.label <-as.numeric(train_set_hl$Heating_Load)
corrplot(cor(cbind(train_set_hl,y = train_set_hl$Heating_Load)),type="upper")

cor(train_set_hl,train_set_hl$Heating_Load)
# We can see that Overal_Height has the highest correlation with heating load followed by relative compactnes, wall area, and glazing area

# Let's apply a Heating load model to see P-values
model_hl <- lm(Heating_Load~.,data=train_set_hl)
summary(model_hl)

#P-values for orientation, and roof area are all greater than 0.05. This means that the relationship between 
#the dependent and these independent variables is not significant at the 95% certainty level. Let's drop these 2 
#variables and try again. High p-values for these independent variables do not mean that they definitely 
#should not be used in the model. It could be that some other variables are correlated with these variables 
#and making these variables less useful for prediction. Let's drop these variables from heating load data set
train_set_hl <- select (train_set_hl, -c(Roof_Area), -c(Orientation))

# Histogram of Heating Load
train_set_hl %>%
  ggplot(aes(Heating_Load))+
  geom_histogram(binwidth = 1.5, fill = 'red')


###########################
# Considering Cooling Load
###########################
# Let's do a Correlation plot to see if there is any strong positive or negative correlation between variables
## Correlation plot
y.label <-as.numeric(train_set_Cl$Cooling_Load)
corrplot(cor(cbind(train_set_Cl,y = train_set_Cl$Cooling_Load)),type="upper")

cor(train_set_Cl,train_set_Cl$Cooling_Load)
# We can see that overal height has the highest correlation with cooling load followed by relative compactnes and wall area

# Let's apply a cooling load model to see P-values
model_cl <- lm(Cooling_Load~.,data=train_set_Cl)
summary(model_cl)

#P-values for glazing area distribution, orientation, and roof area are all greater than 0.05. This means that the relationship between 
#the dependent and these independent variables is not significant at the 95% certainty level. Let's drop these variables from
#cooling load data sets
train_set_Cl <- select (train_set_Cl, -c(Roof_Area), -c(Orientation), -c(Glazing_Area_Distribution))

# Histogram of Cooling Load
train_set_Cl %>%
  ggplot(aes(Cooling_Load))+
  geom_histogram(binwidth = 1.5, fill = 'blue')





#################################
#                               #
#  k-nearest neighbors (kNN)    #
#                               #
#################################


###########################
# Considering Heating Load
###########################
fit_knn <- train(Heating_Load ~ ., method = "knn",
                 tuneGrid = data.frame(k = seq(1,9,2)),
                 data = train_set_hl)

ggplot(fit_knn) #We see the number of neighbors that minimizes RMSE 

# Let's change how we perform cross validation and apply 10-fold cross validation
control <- trainControl(method = "cv", number = 10, p = .9)
fit_knn <- train(Heating_Load ~ ., method = "knn",
                 data = train_set_hl,
                 tuneGrid = data.frame(k = seq(1,9,2)),
                 trControl = control)
fit_knn$bestTune #maximizes the accuracy

# Predict KNN on the test set
knn_hat <- predict(fit_knn,test_set_hl) 

# Let's check the accuracy of the model
confusionMatrix(table(factor(knn_hat, levels=min(test_set_hl$Heating_Load):max(test_set_hl$Heating_Load)),
                      factor(test_set_hl$Heating_Load, levels=min(test_set_hl$Heating_Load):max(test_set_hl$Heating_Load))))$overall["Accuracy"]
#The accuracy is 80%

###########################
# Considering Cooling Load
###########################
fit_knn_cl <- train(Cooling_Load ~ ., method = "knn",
                    tuneGrid = data.frame(k = seq(1,15,2)),
                    data = train_set_Cl)

ggplot(fit_knn_cl)

# Let's change how we perform cross validation and apply 10-fold cross validation
control <- trainControl(method = "cv", number = 10, p = .9)
fit_knn_cl <- train(Cooling_Load ~ ., method = "knn",
                    data = train_set_Cl,
                    tuneGrid = data.frame(k = seq(1,9,2)),
                    trControl = control)
fit_knn$bestTune #maximizes the accuracy

# Predict on the test set
knn_hat_cl <- predict(fit_knn_cl,test_set_Cl) 

# Let's check the accuracy of the model
confusionMatrix(table(factor(knn_hat_cl, levels=min(test_set_Cl$Cooling_Load):max(test_set_Cl$Cooling_Load)),
                      factor(test_set_Cl$Cooling_Load, levels=min(test_set_Cl$Cooling_Load):max(test_set_Cl$Cooling_Load))))$overall["Accuracy"]
#The accuracy is 84%




#####################
#                   #
#  Regression trees #
#                   #
#####################

###########################
# Considering Heating Load
###########################
library(rpart)
fit_rpart <- rpart(Heating_Load ~ ., data = train_set_hl)

# To pick the best complexity problem and avoid over training:
train_rpart_hl <- train(Heating_Load ~ .,
                        method = "rpart",
                        tuneGrid = data.frame(cp = seq(0,0.00005,len = 50)),
                        data = train_set_hl)
ggplot(train_rpart_hl)

fit_rpart <- rpart(Heating_Load ~ ., data = train_set_hl, control = rpart.control(cp = 0.000025, minsplit = 2))
plot(fit_rpart, margin = 0.01)
text(fit_rpart,cex = 0.4)

# Let's apply the model on the test set
rpart_hat_hl <- predict(fit_rpart, test_set_hl)

# Let's plot predicted values versus heating load on the test set
test_set_hl %>%
  ggplot(aes(rpart_hat_hl,Heating_Load))+
  geom_point()

# Let's check the accuracy of the model
confusionMatrix(table(factor(rpart_hat_hl, levels=min(test_set_hl$Heating_Load):max(test_set_hl$Heating_Load)),
                      factor(test_set_hl$Heating_Load, levels=min(test_set_hl$Heating_Load):max(test_set_hl$Heating_Load))))$overall["Accuracy"]
# We have improvement and the accuracy is higher equal to 91%

###########################
# Considering Cooling Load
###########################
fit_rpart_cl <- rpart(Cooling_Load ~ ., data = train_set_Cl)

# To pick the best complexity problem and avoid over training:
train_rpart_cl <- train(Cooling_Load ~ .,
                        method = "rpart",
                        tuneGrid = data.frame(cp = seq(0,0.00001,len = 50)),
                        data = train_set_Cl)
ggplot(train_rpart_cl)

fit_rpart_cl <- rpart(Cooling_Load ~ ., data = train_set_Cl, control = rpart.control(cp = 0.0000075, minsplit = 8))
plot(fit_rpart_cl, margin = 0.01)
text(fit_rpart_cl,cex = 0.4)

# Let's apply the model on the test set
rpart_hat_cl <- predict(fit_rpart_cl, test_set_Cl)

# Let's plot predicted values versus heating load on the test set
test_set_Cl %>%
  ggplot(aes(rpart_hat_cl,Cooling_Load))+
  geom_point()

# Let's check the accuracy of the model
confusionMatrix(table(factor(rpart_hat_cl, levels=min(test_set_Cl$Cooling_Load):max(test_set_Cl$Cooling_Load)),
                      factor(test_set_Cl$Cooling_Load, levels=min(test_set_Cl$Cooling_Load):max(test_set_Cl$Cooling_Load))))$overall["Accuracy"]
# We have improvement and the accuracy is higher equal to 100%





#################
#               #
# Random Forest #
#               #
#################

###########################
# Considering Heating Load
###########################
fit_rf <- randomForest(Heating_Load~., data = train_set_hl)
plot(fit_rf)
# We can see in this case the accuracy improves as we add more trees untill about 90 trees

# We can make the estimates smoother by changing the parameters that controls the minimum number of data points in the nodes of the tree. The smaller RMSE, the smoother the final estimates will be.
nodesize <- seq(1,11,2)
rf_RMSE <- sapply(nodesize, function(ns){
  train( Heating_Load ~., method = "rf", data = train_set_hl,
         tuneGrid = data.frame(mtry = 2),
         nodesize = ns)$results$RMSE
})
qplot(rf_RMSE,nodesize)

# To predict Heating Load using the optimized random forest method:
fit_rf <- randomForest(Heating_Load~., data = train_set_hl, nodesize = nodesize[which.min(rf_RMSE)])

# Let's fit the model on the test set
rf_hat_hl <- predict(fit_rf, test_set_hl)
rf_hat_hl <- floor(rf_hat_hl) # to round results to the nearest integer

confusionMatrix(table(factor(rf_hat_hl, levels=min(test_set_hl$Heating_Load):max(test_set_hl$Heating_Load)),
                      factor(test_set_hl$Heating_Load, levels=min(test_set_hl$Heating_Load):max(test_set_hl$Heating_Load))))$overall["Accuracy"]
#The accuracy is low 


###########################
# Considering Cooling Load
###########################
fit_rf_cl <- randomForest(Cooling_Load~., data = train_set_Cl)
plot(fit_rf_cl)
# We can see in this case the accuracy improves as we add more trees untill about 70 trees

# We can make the estimates smoother by changing the parameters that controls the minimum number of data points in the nodes of the tree. The smaller RMSE, the smoother the final estimates will be.
rf_RMSE_cl <- sapply(nodesize, function(ns){
  train( Cooling_Load ~., method = "rf", data = train_set_Cl,
         tuneGrid = data.frame(mtry = 2),
         nodesize = ns)$results$RMSE
})

# To predict Cooling Load using the optimized random forest method:
fit_rf_cl <- randomForest(Cooling_Load~., data = train_set_Cl, nodesize = nodesize[which.min(rf_RMSE_cl)])

# Let's fit the model on the test set
rf_hat_cl <- predict(fit_rf_cl, test_set_Cl)
rf_hat_cl <- floor(rf_hat_cl) # to round results to the nearest integer

confusionMatrix(table(factor(rf_hat_cl, levels=min(test_set_Cl$Cooling_Load):max(test_set_Cl$Cooling_Load)),
                      factor(test_set_Cl$Cooling_Load, levels=min(test_set_Cl$Cooling_Load):max(test_set_Cl$Cooling_Load))))$overall["Accuracy"]
#The accuracy is low 





#####################################
#                                   #
#             Validation            #
#                                   #
#####################################

###################################
#  Validation of Regression trees #
###################################

# For Heating load prediction let's validate the model on the validation set for regression trees (CART)
rpart_hat <- predict(fit_rpart, validation_hl)
RT_HL <- confusionMatrix(table(factor(rpart_hat, levels=min(validation_hl$Heating_Load):max(validation_hl$Heating_Load)),
                               factor(validation_hl$Heating_Load, levels=min(validation_hl$Heating_Load):max(validation_hl$Heating_Load))))$overall["Accuracy"]

accuracy_results <- tibble(method = "RT_HL", Accuracy = RT_HL)
accuracy_results %>% knitr::kable()

# For Cooling load prediction let's validate the model on the validation set for regression trees (CART)
rpart_hat_cl <- predict(fit_rpart_cl, validation_cl)
RT_CL <- confusionMatrix(table(factor(rpart_hat_cl, levels=min(validation_cl$Cooling_Load):max(validation_cl$Cooling_Load)),
                               factor(validation_cl$Cooling_Load, levels=min(validation_cl$Cooling_Load):max(validation_cl$Cooling_Load))))$overall["Accuracy"]

accuracy_results <- bind_rows(accuracy_results,
                              tibble(method="RT_CL",  
                                     Accuracy = RT_CL ))
accuracy_results %>% knitr::kable()

##########################
#   Validation of KNN    #
##########################

# For heating load prediction let's validate the model on the validation set for KNN
knn_hat <- predict(fit_knn,validation_hl)
KNN_HL <- confusionMatrix(table(factor(knn_hat, levels=min(validation_hl$Heating_Load):max(validation_hl$Heating_Load)),
                                factor(validation_hl$Heating_Load, levels=min(validation_hl$Heating_Load):max(validation_hl$Heating_Load))))$overall["Accuracy"]

accuracy_results <- bind_rows(accuracy_results,
                              tibble(method="KNN_HL",  
                                     Accuracy = KNN_HL ))
accuracy_results %>% knitr::kable()

# For Cooling load prediction let's validate the model on the validation set for KNN
knn_hat_cl <- predict(fit_knn_cl,validation_cl) 
KNN_CL <- confusionMatrix(table(factor(knn_hat_cl, levels=min(validation_cl$Cooling_Load):max(validation_cl$Cooling_Load)),
                                factor(validation_cl$Cooling_Load, levels=min(validation_cl$Cooling_Load):max(validation_cl$Cooling_Load))))$overall["Accuracy"]

accuracy_results <- bind_rows(accuracy_results,
                              tibble(method="KNN_CL",  
                                     Accuracy = KNN_CL ))
accuracy_results %>% knitr::kable()





###################################
#   Validation of Random Forest   #
###################################

# For heating load prediction let's validate the model on the validation set with Random Forest 
rf_hat_hl <- predict(fit_rf, validation_hl)
rf_hat_hl <- floor(rf_hat_hl)

RF_HL <- confusionMatrix(table(factor(rf_hat_hl, levels=min(validation_hl$Heating_Load):max(validation_hl$Heating_Load)),
                               factor(validation_hl$Heating_Load, levels=min(validation_hl$Heating_Load):max(validation_hl$Heating_Load))))$overall["Accuracy"]

accuracy_results <- bind_rows(accuracy_results,
                              tibble(method="RF_HL",  
                                     Accuracy = RF_HL))
accuracy_results %>% knitr::kable()

# For cooling load prediction let's validate the model on the validation set with Random Forest 
rf_hat_cl <- predict(fit_rf_cl, validation_cl)
rf_hat_cl <- floor(rf_hat_cl)

RF_CL <- confusionMatrix(table(factor(rf_hat_cl, levels=min(validation_cl$Cooling_Load):max(validation_cl$Cooling_Load)),
                               factor(validation_cl$Cooling_Load, levels=min(validation_cl$Cooling_Load):max(validation_cl$Cooling_Load))))$overall["Accuracy"]

accuracy_results <- bind_rows(accuracy_results,
                              tibble(method="RF_CL",  
                                     Accuracy = RF_CL))
accuracy_results %>% knitr::kable()


