clc;
clear;
close all;

imds = createProcessedDatastore();

[trainDS,valDS,testDS] = splitDataset(imds);

disp("TRAIN:");
disp(countEachLabel(trainDS));

disp("VALIDATION:");
disp(countEachLabel(valDS));

disp("TEST:");
disp(countEachLabel(testDS));