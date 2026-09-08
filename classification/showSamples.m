clc;
clear;
close all;

% Load APTOS dataset
[imds, labels] = loadAPTOS();

% Human-readable DR names
drNames = [
    "No DR"
    "Mild DR"
    "Moderate DR"
    "Severe DR"
    "Proliferative DR"
];

% Number of images to display
numSamples = 9;

figure;

for i = 1:numSamples

    % Read image
    img = readimage(imds, i);

    % Get numerical DR grade
    grade = str2double(string(imds.Labels(i)));

    % Convert grade to human-readable name
    gradeName = drNames(grade + 1);

    % Display image
    subplot(3,3,i);
    imshow(img);

    % Display grade and name
    title("Grade " + grade + " - " + gradeName);

end