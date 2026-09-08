function result = detectOpticDisc(img)

%% Convert to double

img = im2double(img);

%% Green channel

green = img(:,:,2);

%% Smooth

smoothImage = imgaussfilt(green,5);

%% Threshold bright regions

threshold = graythresh(smoothImage);

brightMask = smoothImage > threshold;

%% Remove small objects

brightMask = bwareaopen( ...
    brightMask, ...
    200);

%% Region properties

props = regionprops( ...
    brightMask, ...
    "Area", ...
    "Centroid", ...
    "BoundingBox");

if isempty(props)

    result.found = false;

    result.mask = false(size(green));

    result.centroid = [NaN NaN];

    return;

end

%% Select largest candidate

areas = [props.Area];

[~,index] = max(areas);

%% Create mask

mask = false(size(green));

bbox = props(index).BoundingBox;

x = max(1,floor(bbox(1)));

y = max(1,floor(bbox(2)));

w = floor(bbox(3));

h = floor(bbox(4));

x2 = min(size(mask,2),x+w);

y2 = min(size(mask,1),y+h);

mask(y:y2,x:x2) = ...
    brightMask(y:y2,x:x2);

%% Output

result.found = true;

result.mask = mask;

result.centroid = props(index).Centroid;

end