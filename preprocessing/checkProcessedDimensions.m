clc;
clear;
close all;

folder = "D:\projects\SIH_2026\DR_Screening_SIH\results\preprocessing\preprocessed_APTOS";

files = dir(fullfile(folder,"*.png"));

badImages = 0;

for i = 1:length(files)

    img = imread(fullfile(folder,files(i).name));

    s = size(img);

    if length(s) ~= 3 || s(1) ~= 224 || s(2) ~= 224

        badImages = badImages + 1;

        fprintf("BAD: %s\n",files(i).name);

    end

end

fprintf("\nBad images: %d\n",badImages);

if badImages == 0
    disp("All processed images are correct.");
end