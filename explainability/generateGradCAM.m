function scoreMap = generateGradCAM( ...
    net, ...
    img, ...
    classIndex)

%% Preprocess image

processed = preprocessFundusColor(img);

%% Convert to single

X = single(processed);

%% Generate Grad-CAM

scoreMap = gradCAM( ...
    net, ...
    X, ...
    classIndex);

end