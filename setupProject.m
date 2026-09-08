clc;
clear;
close all;

% Get the project folder
projectFolder = pwd;

% Add project folders to MATLAB path
addpath(genpath(projectFolder));

disp("======================================");
disp(" DR Screening SIH Project Setup");
disp("======================================");

disp("Project folder:");
disp(projectFolder);

disp("Project folders added to MATLAB path.");

disp("Setup complete!");