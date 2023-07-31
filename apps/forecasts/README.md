# Web application to display the forecasts for malaria cases, stratified by state

The goal of this application is to provide point estimates and confidence intervals for the expected number of malaria cases within a given period (1 month, 3 months, 6 months and 1 year) given past trends in cases in the state. It should allow staff to quickly assess potential caseload regularly, facilitating planning and response, as well as providing a point of comparison when the observed number of cases rises unexpectedly.

# How does the application work

It uses compiled SIVEP data and machine learning processes with some additional weather and deforesting data to model the trends in malaria cases by state. The model is trained on historical data and then used to predict the number of cases in the future in a process that can be more or less automatic, but which benefits from supervision of  trained forecasters and malaria experts.

# Forecasting methods

For most states, we trained dynamic ARIMA models, which take additional covariates and model error as an ARIMA process, holding back the last year of available data as a test set. In some states, purely ARIMA models performed better than covariate based models and were chosen as final models. We assessed other forecasting techniques such as Neural Networks, VARs, ETS and others, but their performance gain was either negligible, nonexistent or did not justify the added complexity and computational cost. We also performed sensitivity analysis on the length of the training set, but it showed little improvement over using the full set.

# Implementation

The models are implemented in a Shiny Web Application that allows the user to select a state and then displays predictions and confidence intervals for the forecasting horizons of 1, 3, 6 and 12 months from the present.

