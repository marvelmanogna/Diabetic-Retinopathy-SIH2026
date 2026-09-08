clc;
clear;
close all;

[imds,~] = loadAPTOS();

img = readimage(imds,1);

result = detectOpticDisc(img);

figure;

imshow(img);

hold on;

if result.found

    plot( ...
        result.centroid(1), ...
        result.centroid(2), ...
        "r+", ...
        "MarkerSize",20, ...
        "LineWidth",3);

    title("Candidate Optic Disc");

else

    title("Optic Disc Not Detected");

end

hold off;