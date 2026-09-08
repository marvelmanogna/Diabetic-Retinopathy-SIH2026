clc;
clear;
close all;

%% Load processed dataset

processedFolder = "D:\projects\SIH_2026\DR_Screening_SIH\results\preprocessing\preprocessed_APTOS";

imds = imageDatastore( ...
    processedFolder, ...
    "FileExtensions",".png");

%% Load CSV

labels = readtable("D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS/train.csv");

%% Create labels

diagnosis = zeros(numel(imds.Files),1);

for i = 1:numel(imds.Files)

    [~,name,~] = fileparts(imds.Files{i});

        idx = find( ...
        string(labels{:,1}) == string(name), ...
        1);


    if isempty(idx)

        error("Label not found for: " + string(name));

    end

    diagnosis(i) = labels.diagnosis(idx);

end

imds.Labels = categorical(diagnosis);

%% Names of DR grades

drNames = [ ...
    "No DR", ...
    "Mild DR", ...
    "Moderate DR", ...
    "Severe DR", ...
    "Proliferative DR"];

%% Display 9 samples

numSamples = min(9,numel(imds.Files));

figure;

for i = 1:numSamples

    img = readimage(imds,i);

    grade = str2double(string(imds.Labels(i)));

    subplot(3,3,i);

    imshow(img);

    title( ...
        "Grade " + grade + ...
        " - " + drNames(grade+1));

end