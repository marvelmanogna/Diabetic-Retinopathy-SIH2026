clc;
clear;
close all;

%% Load model

[net,classNames,~] = loadDRModel();

%% Load image

[imds,~] = loadAPTOS();

img = readimage(imds,1);

%% Preprocess

processed = preprocessFundusColor(img);

%% Predict

scores = predict(net,single(processed));

scores = extractdata(scores);

scores = squeeze(scores);

%% Find predicted class

[~,classIndex] = max(scores);

%% Generate Grad-CAM

scoreMap = generateGradCAM( ...
    net, ...
    img, ...
    classIndex);

%% Display

figure;

imshow(img);

hold on;

imagesc(scoreMap);

colormap jet;

colorbar;

alpha(0.45);

title( ...
    "Grad-CAM: " + ...
    classNames(classIndex));

hold off;

%% Save

if ~exist("D:\projects\SIH_2026\DR_Screening_SIH\results\explainability","dir")
    mkdir("D:\projects\SIH_2026\DR_Screening_SIH\results\explainability");
end

saveas( ...
    gcf, ...
    "D:\projects\SIH_2026\DR_Screening_SIH\results\explainability/gradcam_sample.png");