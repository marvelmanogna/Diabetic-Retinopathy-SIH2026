clc;
clear;
close all;

%% ============================================================
%  DIABETIC RETINOPATHY CLASSIFICATION
%  APTOS 2019 + ResNet-18 Transfer Learning
% =============================================================

disp("==============================================");
disp("      DR CLASSIFICATION TRAINING");
disp("==============================================");

%% ------------------------------------------------------------
% 1. Load processed APTOS dataset
% ------------------------------------------------------------

disp("Loading processed APTOS dataset...");

imds = createProcessedDatastore();

fprintf("Total images: %d\n",numel(imds.Files));

%% ------------------------------------------------------------
% 2. Check classes
% ------------------------------------------------------------

disp("Class distribution:");

disp(countEachLabel(imds));

%% ------------------------------------------------------------
% 3. Split dataset
% ------------------------------------------------------------

disp("Splitting dataset...");

[trainDS,valDS,testDS] = splitDataset(imds);

fprintf("Training images   : %d\n",numel(trainDS.Files));
fprintf("Validation images : %d\n",numel(valDS.Files));
fprintf("Testing images    : %d\n",numel(testDS.Files));

%% ------------------------------------------------------------
% 4. Define class names
% ------------------------------------------------------------

classNames = [
    "0"
    "1"
    "2"
    "3"
    "4"
];

numClasses = numel(classNames);

fprintf("Number of classes: %d\n",numClasses);

%% ------------------------------------------------------------
% 5. Load pretrained ResNet-18
% ------------------------------------------------------------

disp("Loading pretrained ResNet-18...");

net = imagePretrainedNetwork( ...
    "resnet18", ...
    NumClasses=numClasses);

disp("ResNet-18 loaded.");

%% ------------------------------------------------------------
% 6. Get input size
% ------------------------------------------------------------

inputSize = net.Layers(1).InputSize;

fprintf("Network input size: %d x %d x %d\n", ...
    inputSize(1), ...
    inputSize(2), ...
    inputSize(3));

%% ------------------------------------------------------------
% 7. Create image augmentation
% ------------------------------------------------------------

disp("Creating augmentation...");

pixelRange = [-10 10];

imageAugmenter = imageDataAugmenter( ...
    RandXReflection=true, ...
    RandXTranslation=pixelRange, ...
    RandYTranslation=pixelRange);

%% ------------------------------------------------------------
% 8. Create augmented datastores
% ------------------------------------------------------------

augTrainDS = augmentedImageDatastore( ...
    inputSize(1:2), ...
    trainDS, ...
    DataAugmentation=imageAugmenter);

augValDS = augmentedImageDatastore( ...
    inputSize(1:2), ...
    valDS);

augTestDS = augmentedImageDatastore( ...
    inputSize(1:2), ...
    testDS);

%% ------------------------------------------------------------
% 9. Training options
% ------------------------------------------------------------

disp("Creating training options...");

options = trainingOptions("adam", ...
    InitialLearnRate=1e-4, ...
    MaxEpochs=8, ...
    MiniBatchSize=32, ...
    ValidationData=augValDS, ...
    ValidationFrequency=50, ...
    Shuffle="every-epoch", ...
    Metrics="accuracy", ...
    Plots="training-progress", ...
    Verbose=true);

%% ------------------------------------------------------------
% 10. Train network
% ------------------------------------------------------------

disp("==============================================");
disp("STARTING TRAINING");
disp("==============================================");

[trainedNet,info] = trainnet( ...
    augTrainDS, ...
    net, ...
    "crossentropy", ...
    options);

disp("==============================================");
disp("TRAINING COMPLETE");
disp("==============================================");

%% ------------------------------------------------------------
% 11. Save trained network
% ------------------------------------------------------------

modelFolder = "D:\projects\SIH_2026\DR_Screening_SIH\results\model";

if ~exist(modelFolder,"dir")
    mkdir(modelFolder);
end

save( ...
    fullfile(modelFolder,"drModel.mat"), ...
    "trainedNet", ...
    "classNames", ...
    "inputSize");

save( ...
    fullfile(modelFolder,"trainingInfo.mat"), ...
    "info");

disp("Model saved successfully.");

fprintf("Saved to: %s\n", ...
    fullfile(modelFolder,"drModel.mat"));