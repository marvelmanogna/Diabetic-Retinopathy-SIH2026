clc;
clear;
close all;

[imds,~] = loadAPTOS();

img = readimage(imds,1);

processed = preprocessFundusColor(img);

figure;

subplot(1,2,1);
imshow(img);
title("Original");

subplot(1,2,2);
imshow(processed);
title("Processed");

disp("Processed size:");

disp(size(processed));

disp("Processed class:");

disp(class(processed));