function result = assessQuality(img)

    % =========================================================
    % IMAGE QUALITY ASSESSMENT
    % =========================================================

    % Check that an image was supplied
    if nargin < 1
        error("assessQuality requires an input image.");
    end


    % =========================================================
    % 1. CONVERT IMAGE TO DOUBLE
    % =========================================================

    img = im2double(img);


    % =========================================================
    % 2. CONVERT TO GRAYSCALE
    % =========================================================

    if size(img,3) == 3

        gray = rgb2gray(img);

    else

        gray = img;

    end


    % =========================================================
    % 3. BRIGHTNESS CHECK
    % =========================================================

    meanBrightness = mean(gray(:));

    brightnessOK = ...
        meanBrightness >= 0.20 && ...
        meanBrightness <= 0.80;


    % =========================================================
    % 4. FOCUS / BLUR CHECK
    % =========================================================

    [Gx,Gy] = imgradientxy(gray);

    gradientMagnitude = ...
        sqrt(Gx.^2 + Gy.^2);

    focusScore = ...
        var(gradientMagnitude(:));

    focusOK = focusScore > 0.001;


    % =========================================================
    % 5. FIELD OF VIEW CHECK
    % =========================================================

    retinaMask = gray > 0.05;

    fovPercentage = ...
        100 * nnz(retinaMask) / numel(retinaMask);

    fovOK = fovPercentage > 20;


    % =========================================================
    % 6. COLLECT REASONS
    % =========================================================

    reasons = strings(0);


    if ~brightnessOK

        if meanBrightness < 0.20

            reasons(end+1) = ...
                "Image is too dark";

        elseif meanBrightness > 0.80

            reasons(end+1) = ...
                "Image is too bright";

        end

    end


    if ~focusOK

        reasons(end+1) = ...
            "Image may be blurred";

    end


    if ~fovOK

        reasons(end+1) = ...
            "Insufficient retinal field of view";

    end


    % =========================================================
    % 7. FINAL DECISION
    % =========================================================

    if brightnessOK && focusOK && fovOK

        status = "ACCEPT";

    else

        status = "RECAPTURE";

    end


    % =========================================================
    % 8. CREATE RESULT STRUCTURE
    % =========================================================

    result.meanBrightness = meanBrightness;

    result.focusScore = focusScore;

    result.fovPercentage = fovPercentage;

    result.brightnessOK = brightnessOK;

    result.focusOK = focusOK;

    result.fovOK = fovOK;

    result.status = status;

    result.reasons = reasons;

end