%% Main function
function [f1,f2] = utils()
    f1 = @arima_remarks;
    f2 = @chowt;
end
%% arima_remarks
% Performs arima modelling for given parameters, residual analysis and test
% for significance of the coefficents
function [est_m,res,underfit_test,overfit_test] = arima_remarks(params,constant,vk)
p = params(1);i=params(2);m=params(3);
model = arima(p,i,m); 
if constant == 0
    model.Constant = constant;
end
est_m = estimate(model,vk);
% Residual analysis
% Residual computation
[res,~,~] = infer(est_m,vk);
% ACF of residuals
figure();
autocorr(res,'NumLags',20)
title('ACF of residuals from ARIMA(1,1,1) model')
box off;
% PACF of residuals
figure();
parcorr(res,'NumLags',20)
title('PACF of residuals from ARIMA(1,1,1) model')
box off;
% Whiteness test (test for underfit)
[h_model,pval_model] = lbqtest(res);
disp('Whiteness Test for Residuals results');
disp(h_model);disp(pval_model);
underfit_test = ~h_model;
% uf = 1 means no underfit
% Test for overfit
summary = summarize(est_m);
sig = (summary.Table.PValue <= 0.05) | isnan(summary.Table.PValue);
overfit_test = prod(sig);
% of = 1 means no overfit
end
%% Chow Test
function y = chowt(x)
    y = x;
end
