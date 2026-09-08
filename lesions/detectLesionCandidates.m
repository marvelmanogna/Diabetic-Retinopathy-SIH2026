function evidence = detectLesionCandidates(img)

%% Convert image

img = im2double(img);

%% ---------------------------------------------------------
% Red channel
% ---------------------------------------------------------

red = img(:,:,1);

%% ---------------------------------------------------------
% Green channel
% ---------------------------------------------------------

green = img(:,:,2);

%% ---------------------------------------------------------
% Dark candidate regions
% ---------------------------------------------------------

redSmooth = imgaussfilt(red,2);

darkResponse = ...
    mat2gray(1-redSmooth);

darkMask = darkResponse > 0.65;

darkMask = bwareaopen( ...
    darkMask, ...
    10);

%% ---------------------------------------------------------
% Bright candidate regions
% ---------------------------------------------------------

brightResponse = ...
    mat2gray(green);

brightMask = brightResponse > 0.75;

brightMask = bwareaopen( ...
    brightMask, ...
    20);

%% ---------------------------------------------------------
% Vessel mask
% ---------------------------------------------------------

vesselMask = segmentVessels(img);

%% ---------------------------------------------------------
% Remove vessels from bright candidates
% ---------------------------------------------------------

brightMask = brightMask & ~vesselMask;

%% ---------------------------------------------------------
% Store evidence
% ---------------------------------------------------------

evidence.darkCandidates = darkMask;

evidence.brightCandidates = brightMask;

evidence.vesselMask = vesselMask;

evidence.numDarkCandidates = ...
    nnz(darkMask);

evidence.numBrightCandidates = ...
    nnz(brightMask);

end