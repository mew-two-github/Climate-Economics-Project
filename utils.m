function [f1,f2] = utils()
    f1 = @arima_remarks;
end
function [est_m,res,underfit,overfit] = arima_remarks(params,vk)
p = params(1);i=params(2);m=params(3);
model = arima(p,i,m); 
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
% Whiteness test
[h_model1,pval_model1] = lbqtest(res);
disp('Whiteness Test for Residuals results');
disp(h_model1);disp(pval_model1);
underfit = ~h_model1;
summarize()
end
