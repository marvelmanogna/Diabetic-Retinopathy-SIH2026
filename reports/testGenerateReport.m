clc;
clear;
close all;

[imds,~] = loadAPTOS();

img = readimage(imds,1);

result = analyzeFundus(img);

reportText = generateReport(result);

disp(reportText);

if ~exist("D:\projects\SIH_2026\DR_Screening_SIH\reports","dir")
    mkdir("D:\projects\SIH_2026\DR_Screening_SIH\reports");
end

fileID = fopen( ...
    "D:\projects\SIH_2026\DR_Screening_SIH\reports/sample_report.txt", ...
    "w");

fprintf(fileID,"%s",reportText);

fclose(fileID);

disp("Report saved.");