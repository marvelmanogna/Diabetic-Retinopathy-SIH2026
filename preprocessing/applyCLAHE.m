function enhanced = applyCLAHE(img)

% Convert image to double
img = im2double(img);

% If RGB, convert to grayscale
if size(img,3) == 3
    img = rgb2gray(img);
end

% Apply CLAHE
enhanced = adapthisteq(img);

end