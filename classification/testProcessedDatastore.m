clc;
clear;
close all;

imds = createProcessedDatastore();

fprintf("Processed images: %d\n",numel(imds.Files));

disp(countEachLabel(imds));