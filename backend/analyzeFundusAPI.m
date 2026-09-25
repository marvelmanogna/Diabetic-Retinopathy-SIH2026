function jsonText = analyzeFundusAPI(imagePath)

% -----------------------------------------------------
% Check image
% -----------------------------------------------------

if ~isfile(imagePath)
    error("Image file not found: " + imagePath);
end


% -----------------------------------------------------
% Read image
% -----------------------------------------------------

img = imread(imagePath);


% -----------------------------------------------------
% Run your existing pipeline
% -----------------------------------------------------

result = analyzeFundus(img);


% -----------------------------------------------------
% Basic API response
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
% Stop if image needs recapture
% -----------------------------------------------------

if result.status == "RECAPTURE"

    apiResult.message = string(result.message);

    jsonText = jsonencode(apiResult);

    return;

end


% -----------------------------------------------------
% DR prediction
% -----------------------------------------------------

apiResult.prediction = struct( ...
    "grade", result.prediction.grade, ...
    "gradeName", string(result.prediction.gradeName), ...
    "score", result.prediction.score, ...
    "referable", result.prediction.referable ...
    );


% -----------------------------------------------------
% Convert result to JSON
% -----------------------------------------------------

jsonText = jsonencode(apiResult);

end