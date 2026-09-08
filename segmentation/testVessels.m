clc;
clear;
close all;

[imds,~] = loadAPTOS();

img = readimage(imds,1);

vesselMask = segmentVessels(img);

figure;

subplot(1,2,1);

imshow(img);

title("Original Fundus");

subplot(1,2,2);

imshow(vesselMask);

title("Candidate Vessel Mask");

if ~exist("D:\projects\SIH_2026\DR_Screening_SIH\segmentation","dir")
    mkdir("D:\projects\SIH_2026\DR_Screening_SIH\segmentation");
end

saveas( ...
    gcf, ...
    "D:\projects\SIH_2026\DR_Screening_SIH\segmentation/vessel_sample.png");