function imds = createProcessedDatastore()

    %% Read labels
    labels = readtable("D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS/train.csv");

    %% Processed folder
    imageFolder = "D:\projects\SIH_2026\DR_Screening_SIH\results\preprocessing\preprocessed_APTOS";

    %% Get IDs
    imageIDs = string(labels.id_code);

    %% Build paths
    imagePaths = strings(height(labels),1);

    for i = 1:height(labels)

        imagePaths(i) = fullfile( ...
            imageFolder, ...
            imageIDs(i) + ".png");

    end

    %% Check
    exists = isfile(imagePaths);

    if ~all(exists)

        error("%d processed images are missing.", ...
            sum(~exists));

    end

    %% Create datastore
    imds = imageDatastore(imagePaths);

    %% Labels
    imds.Labels = categorical(labels.diagnosis);

end