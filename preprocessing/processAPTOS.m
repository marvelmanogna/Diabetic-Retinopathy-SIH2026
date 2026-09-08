clc;
clear;
close all;

%% =========================================
%  APTOS AUTOMATIC PREPROCESSING
%  SIH 2026 - Diabetic Retinopathy Project
% ==========================================

disp("======================================");
disp("   APTOS PREPROCESSING PIPELINE");
disp("======================================");

%% Step 1: Define folders

inputFolder = "D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS\train_images";

outputFolder = "D:\projects\SIH_2026\DR_Screening_SIH\results\preprocessing\preprocessed_APTOS";

%% Step 2: Check input folder

if ~isfolder(inputFolder)

    error("APTOS train_images folder was not found.");

end

disp("Input folder found:");
disp(inputFolder);

%% Step 3: Create output folder

if ~isfolder(outputFolder)

    mkdir(outputFolder);

end

disp("Output folder:");
disp(outputFolder);

%% Step 4: Find all PNG images

imageFiles = dir(fullfile(inputFolder,"*.png"));

numImages = length(imageFiles);

fprintf("\nNumber of images found: %d\n",numImages);

if numImages == 0

    error("No PNG images were found in the APTOS train_images folder.");

end

%% Step 5: Process images

fprintf("\nStarting preprocessing...\n\n");

successful = 0;
failed = 0;

for i = 1:numImages

    try

        %% Read image

        inputFile = fullfile( ...
            imageFiles(i).folder, ...
            imageFiles(i).name);

        img = imread(inputFile);

        %% Preprocess image

        processed = preprocessFundus(img);

        %% Create output filename

        outputFile = fullfile( ...
            outputFolder, ...
            imageFiles(i).name);

        %% Save processed image

        imwrite(processed,outputFile);

        successful = successful + 1;

        %% Display progress

        fprintf( ...
            "Processed %d / %d : %s\n", ...
            i, ...
            numImages, ...
            imageFiles(i).name);

    catch ME

        failed = failed + 1;

        fprintf("\nERROR processing %s\n", ...
            imageFiles(i).name);

        fprintf("Reason: %s\n\n", ...
            ME.message);

    end

end

%% Step 6: Final summary

disp("======================================");
disp("   PREPROCESSING COMPLETED");
disp("======================================");

fprintf("Total images found     : %d\n",numImages);
fprintf("Successfully processed : %d\n",successful);
fprintf("Failed images          : %d\n",failed);

fprintf("\nOutput folder:\n%s\n",outputFolder);

disp("======================================");