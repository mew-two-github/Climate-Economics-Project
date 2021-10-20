% Run after univariate_analysis.m
%% Checking for integrating effects after taking log
results = zeros(m,2);
Data = log(Data);
for i = 1:m
    [results(i,1), results(i,2)] = adftest((Data(:,i)));
end
if sum(results(i,1))    
    disp('Earlier stuff ok');
else
    disp('Earlier stuff wrong');
end

