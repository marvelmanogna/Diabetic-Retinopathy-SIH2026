clc;
clear;
close all;

img = imread( ...
    "D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS\train_images/77e15f213b04.png");

gray = rgb2gray(img);

enhanced = applyCLAHE(gray);

figure;

subplot(1,2,1);
imshow(gray);
title("Before CLAHE");

subplot(1,2,2);
imshow(enhanced);
title("After CLAHE");

denoised = imgaussfilt(enhanced,0.5);