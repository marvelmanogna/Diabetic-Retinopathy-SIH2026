clc;
clear;
close all;

disp("======================================");
disp("       REPORT GENERATION TEST");
disp("======================================");

% Create sample quality result
result.quality.status = "ACCEPT";
result.quality.meanBrightness = 0.45;
result.quality.focusScore = 0.0032;
result.quality.fovPercentage = 78.5;


% Create sample DR prediction
result.prediction.grade = 2;
result.prediction.gradeName = "Moderate DR";
result.prediction.score = 0.87;
result.prediction.referable = true;


% Sample optic disc result
result.opticDisc.found = true;


% Sample lesion evidence
result.lesionEvidence.numDarkCandidates = 25;
result.lesionEvidence.numBrightCandidates = 14;


% Generate report
reportText = generateReport(result);


% Display report
disp(reportText);


% Create results folder
reportFolder = ...
    "D:\projects\SIH_2026\DR_Screening_SIH\reports";

if ~exist(reportFolder,"dir")
    mkdir(reportFolder);
end


% Save report
reportFile = ...
    fullfile(reportFolder,"sample_report.txt");

fid = fopen(reportFile,"w");

fprintf(fid,"%s",reportText);

fclose(fid);


disp("--------------------------------------");
fprintf("Report saved to:\n%s\n",reportFile);
disp("--------------------------------------");
disp("REPORT TEST COMPLETE");