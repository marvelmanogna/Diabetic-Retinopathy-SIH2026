clc;
clear;
close all;

img = imread( ...
    "D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS\train_images/77e15f213b04.png");

cropped = cropFundus(img);

figure;

subplot(1,2,1);
imshow(img);
title("Original");

subplot(1,2,2);
imshow(cropped);
title("Cropped");

resized = imresize(cropped,[224 224]);
figure;
imshow(resized);
title("224 x 224");
size(resized)