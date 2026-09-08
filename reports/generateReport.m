function reportText = generateReport(result)

%% Header

reportText = "";

reportText = reportText + ...
    "DIABETIC RETINOPATHY SCREENING REPORT" + newline;

reportText = reportText + ...
    "========================================" + newline;

%% Quality

reportText = reportText + ...
    "IMAGE QUALITY" + newline;

reportText = reportText + ...
    "Status: " + ...
    string(result.quality.status) + newline;

%% DR

reportText = reportText + newline + ...
    "DR CLASSIFICATION" + newline;

reportText = reportText + ...
    "Grade: " + ...
    string(result.prediction.grade) + newline;

reportText = reportText + ...
    "Category: " + ...
    result.prediction.gradeName + newline;

%% Referable

reportText = reportText + newline + ...
    "REFERABLE DR" + newline;

if result.prediction.referable

    reportText = reportText + ...
        "YES - Human review recommended." + newline;

else

    reportText = reportText + ...
        "NO" + newline;

end

%% Model score

reportText = reportText + newline + ...
    "MODEL SCORE" + newline;

reportText = reportText + ...
    sprintf("%.4f\n", ...
    result.prediction.score);

%% Evidence

reportText = reportText + newline + ...
    "EXPLAINABILITY" + newline;

reportText = reportText + ...
    "Grad-CAM generated: YES" + newline;

reportText = reportText + newline + ...
    "STRUCTURAL EVIDENCE" + newline;

if result.opticDisc.found

    reportText = reportText + ...
        "Candidate optic disc detected." + newline;

else

    reportText = reportText + ...
        "Optic disc not detected." + newline;

end

%% Disclaimer

reportText = reportText + newline + ...
    "DISCLAIMER" + newline;

reportText = reportText + ...
    "This software is a research prototype for " + ...
    "screening support and is not a medical diagnostic device." + newline;

reportText = reportText + ...
    "Results should be reviewed by a qualified healthcare professional." + newline;

end