clc;
clear;
close all;

inputFolder = "D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS\train_images";
outputFolder = "D:\projects\SIH_2026\DR_Screening_SIH\results\preprocessing\preprocessed_APTOS";

if ~exist(outputFolder,"dir")
    mkdir(outputFolder);
end

files = dir(fullfile(inputFolder,"*.png"));

numImages = length(files);

fprintf("Found %d images.\n",numImages);

successCount = 0;
failedCount = 0;

for i = 1:numImages

    try

        filename = files(i).name;

        inputPath = fullfile(inputFolder,filename);

        outputPath = fullfile(outputFolder,filename);

        img = imread(inputPath);

        processed = preprocessFundusColor(img);

        imwrite(processed,outputPath);

        successCount = successCount + 1;

        if mod(i,100) == 0
            fprintf("Processed %d / %d\n",i,numImages);
        end

    catch ME

        failedCount = failedCount + 1;

        fprintf("FAILED: %s\n",files(i).name);

        fprintf("%s\n",ME.message);

    end

end

fprintf("\n=================================\n");
fprintf("PROCESSING COMPLETE\n");
fprintf("=================================\n");

fprintf("Total : %d\n",numImages);
fprintf("Success : %d\n",successCount);
fprintf("Failed : %d\n",failedCount);