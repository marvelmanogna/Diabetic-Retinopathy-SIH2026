function cropped = cropFundus(img)

% Convert image to grayscale
gray = rgb2gray(img);

% Create approximate retinal mask
mask = gray > 0.05;

% Find connected regions
props = regionprops(mask, ...
    "BoundingBox", "Area");

% If no region is found, return original
if isempty(props)

    cropped = img;
    return;

end

% Find largest region
areas = [props.Area];

[~, idx] = max(areas);

% Get bounding box
bbox = props(idx).BoundingBox;

% Crop image
cropped = imcrop(img, bbox);

end