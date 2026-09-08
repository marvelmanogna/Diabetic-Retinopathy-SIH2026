clc;
clear;
close all;

processedFiles = dir("D:\projects\SIH_2026\DR_Screening_SIH\results\preprocessing\preprocessed_APTOS/*.png");

wrongSize = 0;

for i = 1:length(processedFiles)

    filePath = fullfile( ...
        processedFiles(i).folder, ...
        processedFiles(i).name);

    img = imread(filePath);

    imageSize = size(img);

    height = imageSize(1);
    width = imageSize(2);

    if height ~= 224 || width ~= 224

        wrongSize = wrongSize + 1;

        fprintf( ...
            "Wrong size: %s -> %d x %d\n", ...
            processedFiles(i).name, ...
            height, ...
            width);

    end

end

disp("======================================");
disp("IMAGE DIMENSION CHECK");
disp("======================================");

fprintf("Total processed images : %d\n", ...
    length(processedFiles));

fprintf("Wrong-size images      : %d\n", ...
    wrongSize);

if wrongSize == 0

    disp("SUCCESS: All images are 224 x 224.");

else

    disp("Some images have incorrect dimensions.");

end