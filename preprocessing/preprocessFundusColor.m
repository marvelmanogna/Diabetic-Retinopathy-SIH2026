function output = preprocessFundusColor(img)

    img = im2double(img);

    %% Ensure RGB
    if size(img,3) == 1
        img = repmat(img,[1 1 3]);
    end

    %% Crop black borders
    cropped = cropFundus(img);

    %% Resize
    resized = imresize(cropped,[224 224]);

    %% RGB -> LAB
    lab = rgb2lab(resized);

    %% L channel
    L = lab(:,:,1);

    %% Normalize
    L = mat2gray(L);

    %% CLAHE
    L = adapthisteq(L);

    %% Restore
    lab(:,:,1) = L * 100;

    %% LAB -> RGB
    enhanced = lab2rgb(lab);

    %% Denoising
    output = imgaussfilt(enhanced,0.5);

end