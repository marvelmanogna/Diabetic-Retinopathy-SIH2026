clc;
clear;
close all;

% Load original image
img = imread( ...
    "D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS\train_images/64ac539f58cb.png");

% Convert to double
imgDouble = im2double(img);

% Grayscale
gray = rgb2gray(imgDouble);

% Calculate focus score for original
[Gx, Gy] = imgradientxy(gray);

gradientMagnitude = sqrt(Gx.^2 + Gy.^2);

originalScore = var(gradientMagnitude(:));

% Create artificial blur
blurred = imgaussfilt(gray, 5);

% Calculate focus score for blurred image
[Gx2, Gy2] = imgradientxy(blurred);

gradientMagnitude2 = sqrt(Gx2.^2 + Gy2.^2);

blurredScore = var(gradientMagnitude2(:));

% Display
disp("Original focus score:");
disp(originalScore);

disp("Blurred focus score:");
disp(blurredScore);

% Display images
figure;

subplot(1,2,1);
imshow(gray);
title("Original");

subplot(1,2,2);
imshow(blurred);
title("Artificially Blurred");