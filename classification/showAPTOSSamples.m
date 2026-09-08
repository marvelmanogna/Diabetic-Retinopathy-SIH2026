clc;
clear;
close all;

[imds,~] = loadAPTOS();

drNames = [
    "No DR"
    "Mild DR"
    "Moderate DR"
    "Severe DR"
    "Proliferative DR"
    ];

rng(1);

indices = randperm(numel(imds.Files),9);

figure;

for i = 1:9

    img = readimage(imds,indices(i));

    grade = str2double(string(imds.Labels(indices(i))));

    subplot(3,3,i);

    imshow(img);

    title("Grade " + grade + " - " + drNames(grade+1));

end