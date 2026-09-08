clc;
clear;
close all;

img = imread( ...
    "D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS\train_images/77e15f213b04.png");

normalized = normalizeIllumination(img);

gray = rgb2gray(img);

figure;

subplot(1,2,1);
imshow(gray);
title("Original Grayscale");

subplot(1,2,2);
imshow(normalized);
title("Illumination Normalized");