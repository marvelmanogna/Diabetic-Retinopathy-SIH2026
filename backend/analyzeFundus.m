function result = analyzeFundus(img)

    % =========================================================
    % COMPLETE FUNDUS IMAGE ANALYSIS
    % =========================================================

    % ---------------------------------------------------------
    % 1. IMAGE QUALITY
    % ---------------------------------------------------------

    result.quality = assessQuality(img);


    % ---------------------------------------------------------
    % 2. STOP IF IMAGE QUALITY IS POOR
    % ---------------------------------------------------------

    if result.quality.status == "RECAPTURE"

        result.status = "RECAPTURE";

        result.message = ...
            "Image quality is insufficient. Please capture another image.";

        return;

    end


    % ---------------------------------------------------------
    % 3. LOAD AI MODEL
    % ---------------------------------------------------------

    [net,classNames,inputSize] = loadDRModel();


    % ---------------------------------------------------------
    % 4. DR CLASSIFICATION
    % ---------------------------------------------------------

    result.prediction = ...
        predictDR(img,net,classNames);


    % ---------------------------------------------------------
    % 5. PREPROCESS IMAGE
    % ---------------------------------------------------------

    processed = preprocessFundusColor(img);

    result.processedImage = processed;


    % ---------------------------------------------------------
    % 6. GRAD-CAM
    % ---------------------------------------------------------

    X = single(processed);

    scores = predict(net,X);

    scores = extractdata(scores);

    scores = squeeze(scores);

    [~,classIndex] = max(scores);

    result.gradCAM = ...
        gradCAM(net,X,classIndex);


    % ---------------------------------------------------------
    % 7. VESSEL SEGMENTATION
    % ---------------------------------------------------------

    result.vessels = ...
        segmentVessels(img);


    % ---------------------------------------------------------
    % 8. OPTIC DISC
    % ---------------------------------------------------------

    result.opticDisc = ...
        detectOpticDisc(img);


    % ---------------------------------------------------------
    % 9. LESION CANDIDATES
    % ---------------------------------------------------------

    result.lesionEvidence = ...
        detectLesionCandidates(img);


    % ---------------------------------------------------------
    % 10. FINAL STATUS
    % ---------------------------------------------------------

    result.status = "ANALYZED";

end