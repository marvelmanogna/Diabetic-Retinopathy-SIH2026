function result = assessQuality(img)

    % ==========================================
    % CONVERT IMAGE
    % ==========================================

    img = im2double(img);

    % Convert RGB to grayscale
    gray = rgb2gray(img);


    % ==========================================
    % 1. BRIGHTNESS CHECK
    % ==========================================

    meanBrightness = mean(gray(:));

    brightnessOK = ...
        meanBrightness >= 0.20 && ...
        meanBrightness <= 0.80;


    % ==========================================
    % 2. FOCUS / BLUR CHECK
    % ==========================================

    [Gx, Gy] = imgradientxy(gray);

    gradientMagnitude = sqrt(Gx.^2 + Gy.^2);

    focusScore = var(gradientMagnitude(:));

    % Initial prototype threshold
    focusOK = focusScore > 0.001;


    % ==========================================
    % 3. FIELD OF VIEW CHECK
    % ==========================================

    retinaMask = gray > 0.05;

    fovPercentage = ...
        100 * nnz(retinaMask) / numel(retinaMask);

    % Initial prototype threshold
    fovOK = fovPercentage > 20;


    % ==========================================
    % 4. GENERATE QUALITY REASONS
    % ==========================================

    reasons = strings(0);

    % Check brightness
    if ~brightnessOK

        if meanBrightness < 0.20

            reasons(end+1) = "Image is too dark";

        elseif meanBrightness > 0.80

            reasons(end+1) = "Image is too bright";

        end

    end


    % Check focus
    if ~focusOK

        reasons(end+1) = "Image may be blurred";

    end


    % Check field of view
    if ~fovOK

        reasons(end+1) = ...
            "Insufficient retinal field of view";

    end


        % ==========================================
    % QUALITY DECISION
    % ==========================================

    brightnessOK = ...
        meanBrightness >= 0.20 && ...
        meanBrightness <= 0.80;

    focusOK = focusScore > 0.001;

    fovOK = fovPercentage > 20;

    % ==========================================
    % GENERATE REASONS
    % ==========================================

    reasons = strings(0);

    if ~brightnessOK

        if meanBrightness < 0.20
            reasons(end+1) = "Image is too dark";
        else
            reasons(end+1) = "Image is too bright";
        end

    end

    if ~focusOK
        reasons(end+1) = "Image may be blurred";
    end

    if ~fovOK
        reasons(end+1) = "Insufficient retinal field of view";
    end

    % ==========================================
    % FINAL DECISION
    % ==========================================

    if brightnessOK && focusOK && fovOK
        status = "ACCEPT";
    else
        status = "RECAPTURE";
    end


    % ==========================================
    % 6. STORE RESULTS
    % ==========================================

    result.meanBrightness = meanBrightness;

    result.focusScore = focusScore;

    result.fovPercentage = fovPercentage;

    result.brightnessOK = brightnessOK;

    result.focusOK = focusOK;

    result.fovOK = fovOK;

    result.status = status;

    result.reasons = reasons;

end