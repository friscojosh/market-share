### -----------------------------------------------------------------------------------------------
### Code testing the predictive power of various CFB metrics with career yards per game
### as the target variable.
### -----------------------------------------------------------------------------------------------

library("tidyverse")
library("caret")
library("caretEnsemble")
library("iml")

### Load data -------------------------------------------------------------------------------------

data <- read_csv("data/yards_to_predict.csv")
stripped <- data %>%
   select(-player, -fname, -lname, -college, -dob, year_born = year, games_played = games) %>%
   na.omit()


### Machine learning model code -------------------------------------------------------------------
set.seed(5568)

### Create a test and train set
inTrain <-
   createDataPartition(y = stripped$nfl_yards_game, p = .7, list = FALSE)
train <- stripped[inTrain,]
test <- stripped[-inTrain,]

### The response variable and the number of folds are given
nfl_folds <- createFolds(train$nfl_yards_game, 10)

nfl_control <- trainControl(
   method = "cv",
   number = 10,
   verboseIter = TRUE,
   savePredictions = TRUE,
   index = nfl_folds
)

mygrid1 <- expand.grid(alpha = 0:1, lambda = seq(0.001, 1, length = 100)) # use with glmnet
mygrid2 <- expand.grid(mtry = 1:10, splitrule = 'variance', min.node.size = 4) # use with ranger

### Create a model using random forest and glmnet. glmnet also centers, scales, and performs
### pricipal component analysis prior to running.
models <- caretList(
   nfl_yards_game ~ .,
   data = train,
   trControl = nfl_control,
   methodList = c("brnn", "knn"),
   tuneList = list(
      ranger = caretModelSpec(method = "ranger", tuneGrid = mygrid2),
      glmnet = caretModelSpec(method = "glmnet", tuneGrid = mygrid1,
                              preProcess = c("nzv", "center", "scale", "pca")
      ))
)

### Test to see if the models are highly correlated. 0.5 or less is better. -----------------------
modelCor(resamples(models))

### Stack all the models and perform logistic regression on each to see how the effects from each
### model are weighted.
stacked_models <- caretStack(models, method = "glm")
summary(stacked_models)

### Grab the predictions from the ensemble and check the r-squared and plot of predict against out
### of sample test data. Here 30% of the sample was held out.
p <- predict(stacked_models, newdata = test)
r_squared <- cor(p, test$nfl_yards_game)^2

### Convert predict to dataframe for ggplot
x = as.data.frame(p)

### Make a pretty picture -------------------------------------------------------------------------
ggplot(data = x, aes_string(x = x$p, y = test$nfl_yards_game)) +
   theme_minimal()+
   geom_point(alpha = .6) +
   stat_smooth(
      method = "auto",
      formula = y ~ x,
      span = .5,
      se = TRUE,
      level = 0.95,
      col = "orange",
      fill = '#ededed'
   ) +
   xlab("Ensemble Model Predict") +
   ylab("Out of Sample NFL Yards per Game") +
   labs(title = paste(round(r_squared, 3), "out of sample r-squared"))

### Let's look at feature importance of these stacked models. -------------------------------------
test_importance <- test %>%
   select(-nfl_yards_game)

### Mean squared error first
predictor = Predictor$new(stacked_models, data = test_importance, y = test$nfl_yards_game)
imp_mse = FeatureImp$new(predictor, loss = "mse")
plot(imp_mse)

### Now mean absolute error
predictor2 = Predictor$new(stacked_models, data = test_importance, y = test$nfl_yards_game)
imp_mae = FeatureImp$new(predictor2, loss = "mae")
plot(imp_mae)

### Compare to the feature importance of these stacked models for the training set. ---------------
train_importance <- train %>%
   select(-nfl_yards_game)

### mse
predictor = Predictor$new(stacked_models, data = train_importance, y = train$nfl_yards_game)
imp_mse = FeatureImp$new(predictor, loss = "mse")
plot(imp_mse)

### mae
predictor2 = Predictor$new(stacked_models, data = train_importance, y = train$nfl_yards_game)
imp_mae = FeatureImp$new(predictor2, loss = "mae")
plot(imp_mae)
