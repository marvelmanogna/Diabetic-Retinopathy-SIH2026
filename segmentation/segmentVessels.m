function vesselMask = segmentVessels(img)

%% Convert to double

img = im2double(img);

%% Green channel

green = img(:,:,2);

%% Improve contrast

greenEnhanced = adapthisteq(green);

%% Estimate background

background = imgaussfilt( ...
    greenEnhanced, ...
    10);

%% Subtract background

vesselResponse = ...
    background - greenEnhanced;

%% Normalize

vesselResponse = mat2gray(vesselResponse);

%% Threshold

vesselMask = vesselResponse > 0.45;

%% Remove small objects

vesselMask = bwareaopen( ...
    vesselMask, ...
    20);

%% Morphological cleanup

vesselMask = imclose( ...
    vesselMask, ...
    strel("disk",1));

end