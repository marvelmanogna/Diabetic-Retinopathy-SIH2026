function output = normalizeIllumination(img)

% Convert to grayscale
gray = rgb2gray(img);

% Convert to double
gray = im2double(gray);

% Estimate smooth background illumination
background = imgaussfilt(gray,20);

% Remove illumination variation
normalized = gray ./ (background + eps);

% Normalize intensity to [0,1]
output = mat2gray(normalized);

end