clc;
clear;
close all;

[net,classNames,inputSize] = loadDRModel();

disp("======================================");
disp("        MODEL LOADING TEST");
disp("======================================");

disp("Network type:");
disp(class(net));

disp("Class names:");
disp(classNames);

disp("Input size:");
disp(inputSize);