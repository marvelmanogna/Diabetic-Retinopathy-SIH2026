function output = preprocessFundus(img)

    % Convert input to double
    img = im2double(img);

    % Step 1: Crop black borders
    cropped = cropFundus(img);

    % Step 2: Resize
    resized = imresize(cropped,[224 224]);

    % Step 3: Illumination normalization
    normalized = normalizeIllumination(resized);

    % Step 4: CLAHE
    enhanced = applyCLAHE(normalized);

    % Step 5: Mild denoising
    output = imgaussfilt(enhanced,0.5);

end