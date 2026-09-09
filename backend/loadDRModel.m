function [net,classNames,inputSize] = loadDRModel()

    % Find the folder where this function is located
    backendFolder = fileparts(mfilename("fullpath"));

    % Move one level up to project root
    projectRoot = fileparts(backendFolder);

    % Model location
    modelPath = fullfile( ...
        projectRoot, ...
        "results", ...
        "model", ...
        "drModel.mat");

    % Check whether model exists
    if ~isfile(modelPath)

        error( ...
            "Trained DR model was not found here:\n%s\n\nTrain the model first.", ...
            modelPath);

    end

    % Load model
    data = load(modelPath);

    net = data.trainedNet;
    classNames = data.classNames;
    inputSize = data.inputSize;

end