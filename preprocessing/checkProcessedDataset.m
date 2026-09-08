clc;
clear;
close all;

originalFolder = "D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS\train_images";
processedFolder = "D:\projects\SIH_2026\DR_Screening_SIH\results\preprocessing\preprocessed_APTOS";

originalFiles = dir(fullfile(originalFolder,"*.png"));
processedFiles = dir(fullfile(processedFolder,"*.png"));

fprintf("Original images  : %d\n",length(originalFiles));
fprintf("Processed images : %d\n",length(processedFiles));

if length(originalFiles) == length(processedFiles)

    disp("SUCCESS: Image counts match.");

else

    disp("WARNING: Image counts do not match.");

end