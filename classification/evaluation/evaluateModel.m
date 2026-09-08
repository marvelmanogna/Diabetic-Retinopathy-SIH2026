clc;
clear;
close all;

%% ============================================================
% MODEL EVALUATION
% =============================================================

disp("======================================");
disp("       MODEL EVALUATION");
disp("======================================");

%% Load datastore

imds = createProcessedDatastore();

%% Split

[trainDS,valDS,testDS] = splitDataset(imds);

%% Load model

[net,classNames,inputSize] = loadDRModel();

%% Create test datastore

augTestDS = augmentedImageDatastore( ...
    inputSize(1:2), ...
    testDS);

%% Predict test set

disp("Predicting test images...");

scores = minibatchpredict( ...
    net, ...
    augTestDS);

%% Convert predictions

predictedLabels = scores2label( ...
    scores, ...
    classNames);

%% Actual labels

actualLabels = testDS.Labels;

%% Confusion matrix

figure;

confusionchart( ...
    actualLabels, ...
    categorical(predictedLabels));

title("APTOS DR Classification");

%% Accuracy

accuracy = mean( ...
    categorical(predictedLabels) == actualLabels);

fprintf("\nAccuracy: %.2f%%\n", ...
    accuracy*100);

%% Save figure

if ~exist("D:\projects\SIH_2026\DR_Screening_SIH\results\model","dir")
    mkdir("D:\projects\SIH_2026\DR_Screening_SIH\results\model");
end

saveas( ...
    gcf, ...
    "D:\projects\SIH_2026\DR_Screening_SIH\results\model/confusionMatrix.png");

%% Save evaluation data

save( ...
    "D:\projects\SIH_2026\DR_Screening_SIH\results\model/evaluationData.mat", ...
    "actualLabels", ...
    "predictedLabels", ...
    "scores", ...
    "accuracy");

disp("Evaluation complete.");