clc;
clear;
close all;

% Load one APTOS image
img = imread("D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS\train_images/0d9a9896f801.png");

% Display image
figure;
imshow(img);
title("APTOS Fundus Image");

% Display information
disp("Image size:");
disp(size(img));

disp("Image data type:");
disp(class(img));

% Convert to grayscale
grayImg = rgb2gray(img);

figure;
imshow(grayImg);
title("Grayscale Image");