function result = analyzeFundus(img)

%% =========================================================
% 1. IMAGE QUALITY
% =========================================================

result.quality = assessQuality(img);

%% =========================================================
% 2. STOP IF IMAGE IS UNGRADABLE
% =========================================================

if result.quality.status == "RECAPTURE"

    result.status = "RECAPTURE";

    result.message = ...
        "Image quality is insufficient. Please capture another image.";

    return;

end

%% =========================================================
% 3. LOAD MODEL
% =========================================================

[net,classNames,inputSize] = loadDRModel();

%% =========================================================
% 4. DR PREDICTION
% =========================================================

result.prediction = predictDR( ...
    img, ...
    net, ...
    classNames);

%% =========================================================
% 5. PREPROCESS
% =========================================================

processed = preprocessFundusColor(img);

result.processedImage = processed;

%% =========================================================
% 6. GRAD-CAM
% =========================================================

X = single(processed);

scores = predict(net,X);

scores = extractdata(scores);

scores = squeeze(scores);

[~,classIndex] = max(scores);

result.gradCAM = gradCAM( ...
    net, ...
    X, ...
    classIndex);

%% =========================================================
% 7. VESSEL ANALYSIS
% =========================================================

result.vessels = segmentVessels(img);

%% =========================================================
% 8. OPTIC DISC
% =========================================================

result.opticDisc = detectOpticDisc(img);

%% =========================================================
% 9. LESION CANDIDATES
% =========================================================

result.lesionEvidence = ...
    detectLesionCandidates(img);

%% =========================================================
% 10. FINAL STATUS
% =========================================================

result.status = "ANALYZED";

end