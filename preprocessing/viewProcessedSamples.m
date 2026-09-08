clc;
clear;
close all;

%% Get original images

imageFiles = dir("D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS\train_images/*.png");

numSamples = min(9,length(imageFiles));

figure;

for i = 1:numSamples

    %% Original image

    originalFile = fullfile( ...
        imageFiles(i).folder, ...
        imageFiles(i).name);

    original = imread(originalFile);

    %% Processed image

    processedFile = fullfile( ...
        "D:\projects\SIH_2026\DR_Screening_SIH\results\preprocessing\preprocessed_APTOS", ...
        imageFiles(i).name);

    processed = imread(processedFile);

    %% Display original

    subplot(3,6,2*i-1);

    imshow(original);

    title("Original "+i);

    %% Display processed

    subplot(3,6,2*i);

    imshow(processed);

    title("Processed "+i);

end