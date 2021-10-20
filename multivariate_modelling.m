clear; close all;
%% Open data
path = "./Data/Gini_index.xlsx";
data = table2array(readtable(path));
time = data(10:end-5,1); gini = data(10:end-5,2);
subplot(221);
plot(time,gini);
title('Gini Coefficient evolution');
xlabel('Year'); ylabel('Gini Coeff');
path = "./Data/india_data.xlsx";
% opts = detectImportOptions(path);
T = readtable(path,"ReadRowNames",true);
data = table2array(T)';
% Finding the first NAN value and taking data upto the instance before it
cut_off = length(data(:,1));
for i = 1:length(data(:,1))
    if (sum(isnan(data(i,:))))
        cut_off = i-1;
        break;
    end
end
time2 = data(1:cut_off,1);
Data = data(1:cut_off,2:end);
subplot(222);
plot(time2,Data(:,1));
title('CO2 emissions'); 
ylabel('CO2 emissions'); xlabel('Year');
subplot(223);
plot(time2,Data(:,2));
title('GDP'); 
ylabel('GDP'); xlabel('Year');
GDP = Data(1:end-3,1);
CO2 = Data(1:end-3,2);
y = CO2;
X = [gini GDP];
%% Analysis using OLS
% Stabilize Data Values
y = log(y);
X = log(X);
[h1,p1] = adftest(y);
% h1 = 0, so difference the series
dlogy = diff(y);

dlogX = X(1:end-1,:);
[h2,p2] = adftest(X(:,1));
% h2 = 0, so difference the series
dlogX(:,1) = diff(X(:,1));

[h3,p3] = adftest(X(:,2));
% h3 is not 0, but since other 2 are differenced, need to remove one data
% point
dlogX(:,2) = X(2:end,2);

ols_mdl = fitlm(dlogX,dlogy);
res = ols_mdl.Residuals.Raw;
ols_mdl

fprintf('R-squared = %.4f, Adjusted R-squared = %.4f \n',ols_mdl.Rsquared.Ordinary,ols_mdl.Rsquared.Adjusted);
figure;
subplot(211); autocorr(res);
subplot(212); parcorr(res);
% Has some PACF at higher lags, but can safely ignore them since our total
% time is ~2-3 such periods
[hres1,pres1] = lbqtest(res);
% Residuals are white
[h_adres1,p_adres2] = adtest(res);
% Gaussianity rejected! Residuals are not Gaussian
figure;
plotResiduals(ols_mdl,'caseorder');
% Exhibits some heteroskedasticity
%% Feasible Generalized least squares
[coeff,se,EstCoeffCov] = fgls(dlogX,dlogy,'innovMdl','HC0','display','final');

%% OLS Analysis without differencing
ols_mdl2 = fitlm(X,y);
res2 = ols_mdl2.Residuals.Raw;
ols_mdl2

fprintf('R-squared = %.4f, Adjusted R-squared = %.4f \n',ols_mdl2.Rsquared.Ordinary,ols_mdl2.Rsquared.Adjusted);
figure;
subplot(211); autocorr(res2);
subplot(212); parcorr(res2);
% Slowly dying ACF, and immediately dying PACF => MA(1)
[hres2,pres2] = lbqtest(res2);
% Residuals are correlated!

%% FGLS again
% Not continuing this. However the procedure: fit an MA model to res2,
% convert to AR using arma2ar. Then find significant terms in AR, denote
% number of terms as p. Pass that p to FGLS
% [coeff2,se2,EstCoeffCov2] = fgls(X,y,'arlags',1,'display','final');
%% BOD x Gini
bod = xlsread("./Data/BOD.xlsx","Averaged");
figure;
plot(bod(1,:),bod(2,:));
title("BOD"); ylabel("BOD in mg/L"); xlabel("Year");
% Since sample size is small (~10) not subjecting it to adftest
bod_data = log(bod(2,1:end-4))'; % because other data till 2014
% Resize matrices
idx = find(time==2007);
dlogy_new = dlogy(idx:end);
dlogX_new = [bod_data,dlogX(idx:end,2)];

% run ols
ols_mdl_bod = fitlm(dlogX,dlogy);
res_bod = ols_mdl_bod.Residuals.Raw;
ols_mdl_bod

fprintf('R-squared = %.4f, Adjusted R-squared = %.4f \n',ols_mdl_bod.Rsquared.Ordinary,ols_mdl_bod.Rsquared.Adjusted);
figure;
subplot(211); autocorr(res_bod,"NumLags",5);
subplot(212); parcorr(res_bod,"NumLags",5);
% No autocorrelation effects
[hresBOD,presBOD] = lbqtest(res_bod);
% Residuals are white
[h_adres_BOD,p_adres_BOD] = adtest(res_bod);
% Gaussianity rejected! Residuals are not Gaussian
figure;
plotResiduals(ols_mdl_bod,'caseorder');
% Exhibits some heteroskedasticity
% run fgls
[coeff_BOD,se_BOD,EstCoeffCov_BOD] = fgls(dlogX_new,dlogy_new,'innovMdl','HC0','display','final');