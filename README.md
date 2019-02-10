Testing the predictiveness of share of college receiving yards,
speed score and other metrics in a four model ensemble.

The out-of-sample predict is pretty garbage. There are probably way to get incremental
improvement with depth of target and route type data but this is typical and generally
state of the art.

![alt text](https://github.com/friscojosh/market-share/blob/master/oos_plot.png "")

Here is the first of two feature importance plots. This one measures the loss in performance
when a feature is removed using mean squared error.

![alt text](https://github.com/friscojosh/market-share/blob/master/mse.png "")

Same idea but measureing loss using the mean absolute error.

![alt text](https://github.com/friscojosh/market-share/blob/master/mae.png "")

In general market share of CFB yards are important - and it's possible it might be even more important
than what this analysis shows - but it's not a huge driver of predictive power with
a rather typical mix of explanatory variables.
