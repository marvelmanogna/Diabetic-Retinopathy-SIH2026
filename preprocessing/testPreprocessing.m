clc;
clear;
close all;

% Load image
img = imread( ...
    "D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS\train_images/77e15f213b04.png");

% Process image
processed = preprocessFundus(img);

% Display
figure;

subplot(1,2,1);
imshow(img);
title("Original");

subplot(1,2,2);
imshow(processed);
title("Processed");

% Display size
disp("Processed image size:");

disp(size(processed));

outputFolder = "D:\projects\SIH_2026\DR_Screening_SIH\results/preprocessing";

if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

imwrite(processed, "D:\projects\SIH_2026\DR_Screening_SIH\results/preprocessing/sample_processed.png");

disp("Processed image saved successfully!");