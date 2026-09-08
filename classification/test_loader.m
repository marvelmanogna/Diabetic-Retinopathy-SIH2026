clc;
clear;
close all;

[imds, labels] = loadAPTOS();

disp("Number of images:");
disp(numel(imds.Files));

disp("Class distribution:");

countEachLabel(imds)