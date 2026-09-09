function setupProject()

    clc;

    projectRoot = fileparts(mfilename("fullpath"));

    addpath(genpath(projectRoot));

    fprintf("\n");
    fprintf("============================================\n");
    fprintf("       DR SCREENING SIH PROJECT\n");
    fprintf("============================================\n");
    fprintf("Project root:\n%s\n\n", projectRoot);

    disp("Project folders added to MATLAB path.");

    fprintf("\nImportant functions:\n");

    fprintf("assessQuality:\n");
    disp(which("assessQuality"));

    fprintf("analyzeFundus:\n");
    disp(which("analyzeFundus"));

    fprintf("predictDR:\n");
    disp(which("predictDR"));

    fprintf("generateReport:\n");
    disp(which("generateReport"));

    fprintf("\nSetup complete.\n");

end