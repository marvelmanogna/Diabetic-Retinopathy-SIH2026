clc;
clear;
close all;

%% Load saved evaluation data

load("D:\projects\SIH_2026\DR_Screening_SIH\results\model/evaluationData.mat");

%% Convert categorical labels to numbers

actual = str2double(string(actualLabels));

predicted = str2double(string(predictedLabels));

%% Referable definition

actualReferable = actual >= 2;

predictedReferable = predicted >= 2;

%% Confusion components

TP = sum( ...
    predictedReferable & ...
    actualReferable);

TN = sum( ...
    ~predictedReferable & ...
    ~actualReferable);

FP = sum( ...
    predictedReferable & ...
    ~actualReferable);

FN = sum( ...
    ~predictedReferable & ...
    actualReferable);

%% Sensitivity

if (TP + FN) > 0

    sensitivity = TP / (TP + FN);

else

    sensitivity = NaN;

end

%% Specificity

if (TN + FP) > 0

    specificity = TN / (TN + FP);

else

    specificity = NaN;

end

%% Print

disp("======================================");
disp("      REFERABLE DR EVALUATION");
disp("======================================");

fprintf("TP = %d\n",TP);
fprintf("TN = %d\n",TN);
fprintf("FP = %d\n",FP);
fprintf("FN = %d\n",FN);

fprintf("\nSensitivity = %.2f%%\n", ...
    sensitivity*100);

fprintf("Specificity = %.2f%%\n", ...
    specificity*100);

%% Save

save( ...
    "D:\projects\SIH_2026\DR_Screening_SIH\results\model/referableMetrics.mat", ...
    "TP","TN","FP","FN", ...
    "sensitivity", ...
    "specificity");