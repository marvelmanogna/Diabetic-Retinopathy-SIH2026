clc;
clear;
close all;

%% Load model

[net,classNames,inputSize] = loadDRModel();

%% Load APTOS image

[imds,~] = loadAPTOS();

img = readimage(imds,1);

%% Predict

result = predictDR( ...
    img, ...
    net, ...
    classNames);

%% Display image

figure;

imshow(img);

title( ...
    "Prediction: " + ...
    result.gradeName);

%% Display result

disp("======================================");
disp("       DR PREDICTION");
disp("======================================");

fprintf("Grade       : %d\n",result.grade);

fprintf("Diagnosis   : %s\n", ...
    result.gradeName);

fprintf("Model score : %.4f\n", ...
    result.score);

fprintf("Referable   : %s\n", ...
    string(result.referable));