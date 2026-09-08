clc;
clear;
close all;

%% Get first image

imageFiles = dir("D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS\train_images/*.png");

originalFile = fullfile( ...
    imageFiles(1).folder, ...
    imageFiles(1).name);

%% Read original

original = imread(originalFile);

%% Read processed

processedFile = fullfile( ...
    "D:\projects\SIH_2026\DR_Screening_SIH\results\preprocessing\preprocessed_APTOS", ...
    imageFiles(1).name);

processed = imread(processedFile);

%% Display

figure;

subplot(1,2,1);

imshow(original);

title("Original APTOS Image");

subplot(1,2,2);

imshow(processed);

title("Preprocessed Image");