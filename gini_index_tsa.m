clear; close all;
%% Get utility functions
[f1,~] = utils();
%% Open and visualise data
path = "./Data/Gini_index.xlsx";
data = table2array(readtable(path));
time = data(:,1); gini = data(:,2);
plot(time,gini);
title('Gini Coefficient evolution');
xlabel('Year'); ylabel('Gini Coeff');
% Exhibits an almost linear rise from 2000 till about 2010
% Not taking data points after 2014 because Gini Coeff stays constant after
% that (must be some error in the reported data)
time = time(1:end-5); gini = gini(1:end-5);
%% Testing for integrating effects
[h1,p1] = adftest(gini);
% Hypothesis of unit root not rejected => Has integrating effects
diff_gini = diff(gini);
[h2,p2] = adftest(diff_gini);
% After differencing the series, the unit root hypothesis is rejected. So
% the series has I = 1 effect.
figure;
plot(time(2:end),diff(gini));
title("Differenced Gini Coeff");ylabel("Difference");xlabel("Time");
%% Arima model
figure;
subplot(211); autocorr(diff_gini); title('ACF of diff Gini');
subplot(212); parcorr(diff_gini); title('PACF of diff Gini');
% Correlations indicate no significant AR or MA effects
[est_m1,res,uf,of] = f1([0,1,0],1,gini,0,0);
% No underfitting! (since residuals are white). Constant term is 
% insignificant.
[est_m2,res2,uf2,of2] = f1([0,1,0],0,gini,1,0);
figure;
plot(time,res2);
%% Second way: RLS
% Modelling as gini[k] = a*gini[k-1] + c
N = length(gini);
H = [gini(1:N-1) ones(N-1,1)];
numParams = 2;
model1 = recursiveLS(numParams,'ForgettingFactor',0.97);
thetaest_vec = zeros(numParams,N-1);
cov_track = zeros(numParams,N-1);
for i = 2:N
    theta = model1(gini(i),H(i-1,:)');
    Ptheta1 = model1.ParameterCovariance;
    cov_track(1:numParams,i-1) = diag(Ptheta1);
    thetaest_vec(1:numParams,i-1) = theta;
end
figure;
subplot(211); plot(thetaest_vec(1,:));
title('Estimate of a'); 
xlabel('Number of Observations'); ylabel('Estimate')
subplot(212);plot(thetaest_vec(2,:));
title('Estimate of c'); 
xlabel('Number of Observations'); ylabel('Estimate');
% Comment your observations