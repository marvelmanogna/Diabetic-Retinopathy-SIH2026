function [net,classNames,inputSize] = loadDRModel()

modelPath = "D:\projects\SIH_2026\DR_Screening_SIH\results\model/drModel.mat";

if ~isfile(modelPath)

    error("Trained DR model was not found: %s", ...
        modelPath);

end

data = load(modelPath);

net = data.trainedNet;
classNames = data.classNames;
inputSize = data.inputSize;

end