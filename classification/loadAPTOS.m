function [imds, labels] = loadAPTOS()

    %% Read CSV
    labels = readtable("D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS/train.csv");

    %% Image folder
    imageFolder = "D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS/train_images";

    %% Get image IDs
    imageIDs = string(labels.id_code);

    %% Create image paths
    imagePaths = strings(height(labels),1);

    for i = 1:height(labels)

        filename = imageIDs(i) + ".png";

        imagePaths(i) = fullfile(imageFolder,filename);

    end

    %% Check files
    exists = isfile(imagePaths);

    if ~all(exists)

        missingCount = sum(~exists);

        error("%d images listed in train.csv were not found.", ...
            missingCount);

    end

    %% Create datastore
    imds = imageDatastore(imagePaths);

    %% Assign labels
    imds.Labels = categorical(labels.diagnosis);

end