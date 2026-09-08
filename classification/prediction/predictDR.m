function result = predictDR(img,net,classNames)

%% --------------------------------------------------------
% Prepare image
% ---------------------------------------------------------

img = preprocessFundusColor(img);

%% --------------------------------------------------------
% Convert to single
% ---------------------------------------------------------

X = single(img);

%% --------------------------------------------------------
% Predict
% ---------------------------------------------------------

scores = predict(net,X);

%% --------------------------------------------------------
% Convert scores to array
% ---------------------------------------------------------

scores = extractdata(scores);

scores = squeeze(scores);

%% --------------------------------------------------------
% Find highest score
% ---------------------------------------------------------

[maxScore,index] = max(scores);

predictedLabel = classNames(index);

%% --------------------------------------------------------
% Convert to DR grade
% ---------------------------------------------------------

grade = str2double(predictedLabel);

%% --------------------------------------------------------
% Human-readable name
% ---------------------------------------------------------

drNames = [
    "No DR"
    "Mild DR"
    "Moderate DR"
    "Severe DR"
    "Proliferative DR"
    ];

gradeName = drNames(grade+1);

%% --------------------------------------------------------
% Referable DR
% ---------------------------------------------------------

referable = grade >= 2;

%% --------------------------------------------------------
% Store result
% ---------------------------------------------------------

result.grade = grade;

result.gradeName = gradeName;

result.score = maxScore;

result.scores = scores;

result.referable = referable;

end