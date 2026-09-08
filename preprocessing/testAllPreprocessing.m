clc;
clear;
close all;

%% Load image

img = imread("D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS\train_images/77e15f213b04.png");

%% Step 1: Crop

cropped = cropFundus(img);

%% Step 2: Resize

resized = imresize(cropped, [224 224]);

%% Step 3: Illumination normalization

normalized = normalizeIllumination(resized);

%% Step 4: CLAHE

enhanced = applyCLAHE(normalized);

%% Step 5: Mild denoising

finalImage = imgaussfilt(enhanced, 0.5);

%% Display all stages

figure;

subplot(2,3,1);
imshow(img);
title("Original");

subplot(2,3,2);
imshow(cropped);
title("Cropped");

subplot(2,3,3);
imshow(resized);
title("Resized");

subplot(2,3,4);
imshow(normalized);
title("Illumination Normalized");

subplot(2,3,5);
imshow(enhanced);
title("CLAHE");

subplot(2,3,6);
imshow(finalImage);
title("Final Processed");

%% Create output folder

outputFolder = "D:\projects\SIH_2026\DR_Screening_SIH\results/preprocessing";

if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

%% Save images

imwrite(img, fullfile(outputFolder, "original.png"));

imwrite(cropped, fullfile(outputFolder, "cropped.png"));

imwrite(resized, fullfile(outputFolder, "resized.png"));

imwrite(normalized, fullfile(outputFolder, "normalized.png"));

imwrite(enhanced, fullfile(outputFolder, "clahe.png"));

imwrite(finalImage, fullfile(outputFolder, "final_processed.png"));

disp("======================================");
disp("PREPROCESSING TEST COMPLETED");
disp("======================================");

disp("Images saved in:");
disp(outputFolder);