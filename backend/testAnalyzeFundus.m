clc;
clear;
close all;

%% Load one image

[imds,~] = loadAPTOS();

img = readimage(imds,1);

%% Analyze

result = analyzeFundus(img);

%% Display

disp("======================================");
disp("       COMPLETE AI ANALYSIS");
disp("======================================");

disp("Image quality:");

disp(result.quality.status);

disp("DR result:");

disp(result.prediction.gradeName);

fprintf( ...
    "Score: %.4f\n", ...
    result.prediction.score);

disp("Referable:");

disp(result.prediction.referable);

disp("Analysis status:");

disp(result.status);