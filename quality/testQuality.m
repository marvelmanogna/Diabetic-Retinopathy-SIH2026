clc;
clear;
close all;

% Load one APTOS image
img = imread( ...
    "D:\projects\SIH_2026\DR_Screening_SIH\data\APTOS\train_images/64ac539f58cb.png");

% Assess quality
result = assessQuality(img);

% Display results
disp("======================================");
disp("       IMAGE QUALITY RESULT");
disp("======================================");

fprintf("Mean Brightness : %.4f\n", ...
    result.meanBrightness);

fprintf("Focus Score     : %.6f\n", ...
    result.focusScore);

fprintf("FOV Percentage  : %.2f%%\n", ...
    result.fovPercentage);

disp("--------------------------------------");

disp("Brightness OK:");
disp(result.brightnessOK);

disp("Focus OK:");
disp(result.focusOK);

disp("FOV OK:");
disp(result.fovOK);

disp("--------------------------------------");

disp("Final Decision:");
disp(result.status);

disp("Reason(s):");

if isempty(result.reasons)

    disp("No quality problems detected.");

else

    for i = 1:length(result.reasons)
        disp("- " + result.reasons(i));
    end

end

