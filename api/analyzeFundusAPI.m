function jsonText = analyzeFundusAPI(imagePath, outputDir)

    % -----------------------------------------------------
    % Check image
    % -----------------------------------------------------
    if ~isfile(imagePath)
        error("Image file not found: " + imagePath);
    end

    % -----------------------------------------------------
    % Create output directory
    % -----------------------------------------------------
    if ~exist(outputDir, "dir")
        mkdir(outputDir);
    end

    % -----------------------------------------------------
    % Read image
    % -----------------------------------------------------
    img = imread(imagePath);

    % -----------------------------------------------------
    % Run complete MATLAB pipeline
    % -----------------------------------------------------
    result = analyzeFundus(img);

    % -----------------------------------------------------
    % Create API response
    % -----------------------------------------------------
    apiResult = struct();
    apiResult.status = string(result.status);

    apiResult.quality = struct( ...
        "status", string(result.quality.status), ...
        "meanBrightness", result.quality.meanBrightness, ...
        "focusScore", result.quality.focusScore, ...
        "fovPercentage", result.quality.fovPercentage ...
    );

    % -----------------------------------------------------
    % QUALITY FAILURE
    % -----------------------------------------------------
    if result.status == "RECAPTURE"
        apiResult.message = string(result.message);
        jsonText = jsonencode(apiResult);
        return;
    end

    % -----------------------------------------------------
    % DR PREDICTION
    % -----------------------------------------------------
    apiResult.prediction = struct( ...
        "grade", result.prediction.grade, ...
        "gradeName", string(result.prediction.gradeName) ...
    );
    
    % Safe check for optional confidence metric
    if isfield(result.prediction, 'confidence')
        apiResult.prediction.confidence = result.prediction.confidence;
    end

    % -----------------------------------------------------
    % LESION SEGMENTATION & VISUAL OUTPUT (Safe Check)
    % -----------------------------------------------------
    if isfield(result, 'segmentation')
        [~, baseName, ~] = fileparts(imagePath);
        maskFilename = fullfile(outputDir, baseName + "_mask.png");
        
        apiResult.segmentation = struct();
        
        if isfield(result.segmentation, 'mask')
            imwrite(result.segmentation.mask, maskFilename);
            apiResult.segmentation.maskPath = string(maskFilename);
        end
        
        if isfield(result.segmentation, 'hemorrhagesCount')
            apiResult.segmentation.hemorrhagesCount = result.segmentation.hemorrhagesCount;
        end
        
        if isfield(result.segmentation, 'exudatesCount')
            apiResult.segmentation.exudatesCount = result.segmentation.exudatesCount;
        end
    end

    % -----------------------------------------------------
    % GENERATE FINAL JSON
    % -----------------------------------------------------
    jsonText = jsonencode(apiResult);

end
