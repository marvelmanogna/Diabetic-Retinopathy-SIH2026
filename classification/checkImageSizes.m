clc;
clear;
close all;

[imds,~] = loadAPTOS();

img = readimage(imds,1);

disp("Image size:");

disp(size(img));

disp("Image class:");

disp(class(img));