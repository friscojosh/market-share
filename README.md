Testing the predictive power of various CFB metrics with career yards per game as the target variable.

The data set is players who played in the NFL and CFB. CFB Data begins in 2003. Career NFL yards per game averages were calculated through 2016. Data was collected from Yahoo sports pages and player stats were spot checked against College Football Reference. Some errors may still be present.

The out-of-sample predict is pretty garbage. There are probably ways to get incremental
improvement with depth of target and route type data, but this is a typical feature mix and generally
state of the art.

![alt text](https://github.com/friscojosh/market-share/blob/master/oos-plot.png "")

Here are the first of two feature importance plots. This one measures the loss in performance
when a feature is "shuffled" using mean squared error.

![alt text](https://github.com/friscojosh/market-share/blob/master/mse.png "")

Same idea but measureing loss using the mean absolute error.

![alt text](https://github.com/friscojosh/market-share/blob/master/mae.png "")

In general market share of CFB yards are important - and it's possible it might be even more important
than what this analysis shows - but it's not a huge driver of predictive power with
a rather typical mix of explanatory variables.
