clc;
clear;
close all;

[imds,~] = loadAPTOS();

img = readimage(imds,1);

evidence = detectLesionCandidates(img);

figure;

subplot(1,3,1);

imshow(img);

title("Fundus");

subplot(1,3,2);

imshow(evidence.darkCandidates);

title("Dark Candidates");

subplot(1,3,3);

imshow(evidence.brightCandidates);

title("Bright Candidates");