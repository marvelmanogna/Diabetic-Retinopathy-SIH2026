clc;
clear;
close all;


%% Load dataset

[imds, labels] = loadAPTOS();


%% Display information

disp("======================================");
disp("        APTOS DATASET CHECK");
disp("======================================");

fprintf("Total images: %d\n",numel(imds.Files));

disp("");


%% Show label distribution

disp("DR class distribution:");

disp(countEachLabel(imds));