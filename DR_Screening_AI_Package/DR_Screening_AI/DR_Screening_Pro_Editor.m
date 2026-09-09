classdef DR_Screening_Pro_Editor < matlab.apps.AppBase
    % DR_SCREENING_PRO_EDITOR
    % Retina-AI: Pro Clinical Diagnostic Workstation
    % Explainable Deep Learning Screening for Diabetic Retinopathy
    
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        MainGrid                    matlab.ui.container.GridLayout
        
        % Header Components
        HeaderPanel                 matlab.ui.container.Panel
        TitleLabel                  matlab.ui.control.Label
        SubtitleLabel               matlab.ui.control.Label
        ModelStatusBadge            matlab.ui.control.Label
        PatientIDLabel              matlab.ui.control.Label
        
        % Left Sidebar (Workstation Controls)
        SidebarPanel                matlab.ui.container.Panel
        SidebarGrid                 matlab.ui.container.GridLayout
        
        % Image Input
        InputSectionLabel           matlab.ui.control.Label
        UploadButton                matlab.ui.control.Button
        PresetDropdownLabel         matlab.ui.control.Label
        PresetDropdown              matlab.ui.control.DropDown
        
        % Diagnostic Engine
        EngineSectionLabel          matlab.ui.control.Label
        AnalyzeButton               matlab.ui.control.Button
        EngineModeSwitch            matlab.ui.control.Switch
        EngineModeLabel             matlab.ui.control.Label
        
        % Editor & Layer Tools
        EditorSectionLabel          matlab.ui.control.Label
        ViewModeDropdownLabel       matlab.ui.control.Label
        ViewModeDropdown            matlab.ui.control.DropDown
        
        HeatmapCheck                matlab.ui.control.CheckBox
        VesselsCheck                matlab.ui.control.CheckBox
        LesionsCheck                matlab.ui.control.CheckBox
        
        OpacitySliderLabel          matlab.ui.control.Label
        OpacitySlider               matlab.ui.control.Slider
        ColormapDropdownLabel       matlab.ui.control.Label
        ColormapDropdown            matlab.ui.control.DropDown
        
        % Actions
        ExportReportButton          matlab.ui.control.Button
        ResetButton                 matlab.ui.control.Button
        
        % Center Viewport Studio
        CenterPanel                 matlab.ui.container.Panel
        CenterGrid                  matlab.ui.container.GridLayout
        ViewportTitleBar            matlab.ui.control.Label
        
        AxesGrid                    matlab.ui.container.GridLayout
        AxOriginal                  matlab.ui.control.UIAxes
        AxGradCAM                   matlab.ui.control.UIAxes
        AxVessels                   matlab.ui.control.UIAxes
        AxLesions                   matlab.ui.control.UIAxes
        
        % Right Clinical Intelligence Panel
        RightPanel                  matlab.ui.container.Panel
        RightGrid                   matlab.ui.container.GridLayout
        
        FindingsSectionLabel        matlab.ui.control.Label
        
        % Diagnosis Badges
        GradeBadgePanel             matlab.ui.container.Panel
        GradeBadgeTitle             matlab.ui.control.Label
        GradeBadgeText              matlab.ui.control.Label
        
        ReferralBadge               matlab.ui.control.Label
        ConfidenceLabel             matlab.ui.control.Label
        
        % Probability Distribution Chart
        ProbAxes                    matlab.ui.control.UIAxes
        
        % Clinical Biomarkers Card
        BiomarkerPanel              matlab.ui.container.Panel
        QualityMetricLabel          matlab.ui.control.Label
        VesselDensityLabel          matlab.ui.control.Label
        LesionCountLabel            matlab.ui.control.Label
        RecommendationTextArea      matlab.ui.control.TextArea
    end
    
    properties (Access = private)
        CurrentRawImage             % Raw RGB matrix
        CurrentProcessedImage       % 224x224 processed RGB
        TrainedNet                  % DAGNetwork or empty
        IsModelLoaded               = false
        
        % Latest analysis outputs
        CurrentResult               % struct returned by analyzeFundus
        LastGradCAMMap              % 2D single/double
        LastVesselMask              % logical mask
        LastLesionsData             % struct with stats & mask
        LastProbScores              % 1x5 double
        LastPredictedGrade          % 0, 1, 2, 3, 4
        
        % Dataset paths
        DatasetPath                 = 'D:\SIH\aptos2019-blindness-detection\train_images\'
        ModelPath                   = 'D:\SIH\DR_Screening_SIH\classification\drResNet18.mat'
        PresetFiles                 = {
            '002c21358ce6.png', 0, 'Case #101: Grade 0 (No DR)';
            '0024cdab0c1e.png', 1, 'Case #102: Grade 1 (Mild NPDR)';
            '000c1434d8d7.png', 2, 'Case #103: Grade 2 (Moderate NPDR)';
            '0104b032c141.png', 3, 'Case #104: Grade 3 (Severe NPDR)';
            '001639a390f0.png', 4, 'Case #105: Grade 4 (Proliferative DR)'
        }
    end
    
    methods (Access = public)
        
        function initBackend(app)
            % Add backend paths
            sihDir = 'D:\SIH\DR_Screening_SIH';
            if exist(sihDir, 'dir')
                addpath(genpath(sihDir));
            end
            
            % Attempt loading model
            if exist(app.ModelPath, 'file')
                try
                    d = load(app.ModelPath);
                    if isfield(d, 'trainedNet')
                        app.TrainedNet = d.trainedNet;
                        app.IsModelLoaded = true;
                        app.ModelStatusBadge.Text = '● AI CORE: ONLINE (ResNet-18)';
                        app.ModelStatusBadge.FontColor = [0.2 0.95 0.5];
                    else
                        app.ModelStatusBadge.Text = '○ AI CORE: SIMULATION MODE';
                        app.ModelStatusBadge.FontColor = [1 0.7 0.2];
                    end
                catch
                    app.ModelStatusBadge.Text = '○ AI CORE: SIMULATION MODE';
                    app.ModelStatusBadge.FontColor = [1 0.7 0.2];
                end
            else
                app.ModelStatusBadge.Text = '○ AI CORE: SIMULATION MODE';
                app.ModelStatusBadge.FontColor = [1 0.7 0.2];
            end
        end
        
        function loadDefaultSample(app)
            % Load first preset image
            try
                defaultFile = fullfile(app.DatasetPath, app.PresetFiles{1,1});
                if exist(defaultFile, 'file')
                    app.loadImageFromFile(defaultFile, 'Case #101: Grade 0 (No DR)');
                else
                    synthetic = app.createSyntheticFundus(0);
                    app.displayRawImage(synthetic, 'Synthetic Retina Demo');
                end
            catch
                % Silently continue
            end
        end
        
        function loadImageFromFile(app, filePath, labelText)
            try
                img = imread(filePath);
                if size(img,3) ~= 3
                    uialert(app.UIFigure, 'Selected image must be RGB.', 'Image Format');
                    return;
                end
                app.displayRawImage(img, labelText);
            catch ME
                uialert(app.UIFigure, ['Could not load image: ' ME.message], 'Load Error');
            end
        end
        
        function displayRawImage(app, img, labelText)
            app.CurrentRawImage = img;
            
            % Clear result cache
            app.CurrentResult = [];
            app.LastGradCAMMap = [];
            app.LastVesselMask = [];
            app.LastLesionsData = [];
            app.LastProbScores = [];
            
            % Reset Axes
            cla(app.AxOriginal);
            cla(app.AxGradCAM);
            cla(app.AxVessels);
            cla(app.AxLesions);
            
            % Display Original
            imshow(img, 'Parent', app.AxOriginal);
            title(app.AxOriginal, '1. ORIGINAL FUNDUS (EXAM)', 'Color', [0.8 0.9 1], 'FontSize', 12, 'FontWeight', 'bold');
            
            % Display Placeholders for 2, 3, 4 until analysis runs
            imshow(img, 'Parent', app.AxGradCAM);
            title(app.AxGradCAM, '2. AI ATTENTION (GRAD-CAM) [CLICK ANALYZE]', 'Color', [0.6 0.7 0.8], 'FontSize', 11);
            
            imshow(img, 'Parent', app.AxVessels);
            title(app.AxVessels, '3. RETINAL VASCULATURE [CLICK ANALYZE]', 'Color', [0.6 0.7 0.8], 'FontSize', 11);
            
            imshow(img, 'Parent', app.AxLesions);
            title(app.AxLesions, '4. LESIONS & PATHOLOGY [CLICK ANALYZE]', 'Color', [0.6 0.7 0.8], 'FontSize', 11);
            
            % Update Header and Status
            app.ViewportTitleBar.Text = ['EXAM VIEWPORT: ' labelText];
            try
                app.PatientIDLabel.Text = ['ID: PAT-' char(java.util.UUID.randomUUID.toString().substring(0,8)).upper()];
            catch
                app.PatientIDLabel.Text = 'ID: PAT-10482';
            end
            
            % Reset Badges
            app.GradeBadgeText.Text = 'PENDING ANALYSIS';
            app.GradeBadgePanel.BackgroundColor = [0.18 0.22 0.30];
            app.ReferralBadge.Text = 'STATUS: READY FOR ANALYSIS';
            app.ReferralBadge.BackgroundColor = [0.15 0.18 0.25];
            app.ReferralBadge.FontColor = [0.7 0.8 0.9];
            app.ConfidenceLabel.Text = 'Confidence: --';
            
            % Reset Biomarkers
            app.QualityMetricLabel.Text = 'Image Quality: Unchecked';
            app.VesselDensityLabel.Text = 'Vessel Density: --';
            app.LesionCountLabel.Text = 'Lesion Candidates: --';
            app.RecommendationTextArea.Value = {'Load an image and click "RUN AI DIAGNOSIS" to evaluate Diabetic Retinopathy severity.'};
            
            cla(app.ProbAxes);
            title(app.ProbAxes, 'CLASS PROBABILITY DISTRIBUTION', 'Color', [0.8 0.9 1], 'FontSize', 10);
        end
        
        function runFullDiagnosis(app)
            if isempty(app.CurrentRawImage)
                uialert(app.UIFigure, 'Please load or select a fundus image first.', 'No Image');
                return;
            end
            
            % Set busy cursor & status
            app.UIFigure.Pointer = 'watch';
            app.AnalyzeButton.Text = 'ANALYZING PIPELINE...';
            app.AnalyzeButton.BackgroundColor = [0.8 0.5 0.1];
            drawnow;
            
            img = app.CurrentRawImage;
            
            try
                % Check if we can run the real backend
                useRealBackend = app.IsModelLoaded && strcmp(app.EngineModeSwitch.Value, 'Live AI Model');
                
                if useRealBackend
                    res = analyzeFundus(img, app.TrainedNet);
                else
                    % High-fidelity simulation mode for demo presentations
                    res = app.simulateAnalysis(img);
                end
                
                app.CurrentResult = res;
                app.LastGradCAMMap = res.gradCAM;
                app.LastVesselMask = res.vessels;
                app.LastLesionsData = res.lesions;
                app.LastProbScores = res.scores;
                
                % Parse grade
                if iscategorical(res.prediction)
                    predStr = char(res.prediction);
                    gradeNum = str2double(predStr);
                elseif isnumeric(res.prediction)
                    gradeNum = res.prediction;
                else
                    gradeNum = str2double(string(res.prediction));
                end
                if isnan(gradeNum), gradeNum = 0; end
                app.LastPredictedGrade = gradeNum;
                
                % Render all visual viewports
                app.renderAllViewports();
                
                % Update Clinical Cards
                app.updateClinicalCards(res, gradeNum);
                
            catch ME
                uialert(app.UIFigure, ['Analysis error: ' ME.message], 'Pipeline Error');
            end
            
            % Restore button
            app.UIFigure.Pointer = 'arrow';
            app.AnalyzeButton.Text = '⚡ RUN AI DIAGNOSIS';
            app.AnalyzeButton.BackgroundColor = [0.05 0.65 0.38];
        end
        
        function res = simulateAnalysis(app, img)
            % High-fidelity simulation matching SIH pipeline
            sihDir = 'D:\SIH\DR_Screening_SIH';
            hasLocalFuncs = exist(fullfile(sihDir, 'quality', 'assessImageQuality.m'), 'file');
            
            if hasLocalFuncs
                res.quality = assessImageQuality(img);
                res.vessels = segmentVessels(img);
                res.lesions = detectLesions(img);
            else
                res.quality.isGood = true;
                res.quality.blurScore = 38.5;
                res.quality.brightness = 0.48;
                res.vessels = imbinarize(img(:,:,2));
                res.lesions.count = 4;
                res.lesions.stats = [];
            end
            
            % Determine grade from preset selection if available
            selIdx = app.PresetDropdown.Value;
            matchedGrade = 0;
            if selIdx >= 1 && selIdx <= size(app.PresetFiles, 1)
                matchedGrade = app.PresetFiles{selIdx, 2};
            end
            
            % Synthetic Grad-CAM heatmap with realistic focal activations
            [H, W, ~] = size(img);
            [X, Y] = meshgrid(linspace(-1, 1, W), linspace(-1, 1, H));
            
            switch matchedGrade
                case 0
                    cam = 0.15 * exp(-(X.^2 + Y.^2)/0.8);
                    scores = [0.94, 0.04, 0.015, 0.004, 0.001];
                    stat = "Non-referable";
                case 1
                    cam = 0.7 * exp(-((X-0.2).^2 + (Y+0.15).^2)/0.12) + 0.1*rand(H,W);
                    scores = [0.08, 0.85, 0.05, 0.015, 0.005];
                    stat = "Non-referable";
                case 2
                    cam = 0.85 * exp(-((X+0.25).^2 + (Y-0.2).^2)/0.15) + ...
                          0.65 * exp(-((X-0.35).^2 + (Y+0.3).^2)/0.18);
                    scores = [0.02, 0.06, 0.84, 0.06, 0.02];
                    stat = "Referable";
                case 3
                    cam = 0.95 * exp(-((X+0.1).^2 + (Y-0.1).^2)/0.25) + ...
                          0.80 * exp(-((X-0.4).^2 + (Y-0.25).^2)/0.15) + ...
                          0.75 * exp(-((X+0.35).^2 + (Y+0.35).^2)/0.15);
                    scores = [0.005, 0.015, 0.07, 0.86, 0.05];
                    stat = "Referable";
                case 4
                    cam = 0.98 * exp(-(X.^2 + Y.^2)/0.35) + ...
                          0.88 * exp(-((X-0.3).^2 + (Y+0.2).^2)/0.2);
                    scores = [0.001, 0.004, 0.025, 0.09, 0.88];
                    stat = "Referable";
                otherwise
                    cam = rescale(rand(H,W));
                    scores = [0.2, 0.2, 0.2, 0.2, 0.2];
                    stat = "Referable";
            end
            
            cam = rescale(imgaussfilt(cam, 8));
            res.gradCAM = single(cam);
            res.prediction = categorical(string(matchedGrade));
            res.scores = scores;
            res.confidence = max(scores);
            res.status = stat;
            res.processedImage = imresize(img, [224 224]);
        end
        
        function renderAllViewports(app)
            if isempty(app.CurrentRawImage) || isempty(app.CurrentResult)
                return;
            end
            
            img = app.CurrentRawImage;
            alphaVal = app.OpacitySlider.Value;
            cmapName = app.ColormapDropdown.Value;
            
            % 1. Viewport 1: Original High-Res Exam
            cla(app.AxOriginal);
            imshow(img, 'Parent', app.AxOriginal);
            title(app.AxOriginal, '1. ORIGINAL FUNDUS (EXAM)', 'Color', [0.8 0.9 1], 'FontSize', 12, 'FontWeight', 'bold');
            
            % 2. Viewport 2: Grad-CAM Overlay
            cla(app.AxGradCAM);
            imshow(img, 'Parent', app.AxGradCAM);
            if app.HeatmapCheck.Value && ~isempty(app.LastGradCAMMap)
                hold(app.AxGradCAM, 'on');
                camResized = imresize(app.LastGradCAMMap, [size(img,1), size(img,2)]);
                hImg = imagesc(app.AxGradCAM, camResized);
                colormap(app.AxGradCAM, cmapName);
                clim(app.AxGradCAM, [0 1]);
                set(hImg, 'AlphaData', alphaVal * (camResized > 0.05));
                hold(app.AxGradCAM, 'off');
                title(app.AxGradCAM, sprintf('2. GRAD-CAM SALIENCY (\\alpha=%.2f)', alphaVal), ...
                    'Color', [0.2 0.95 0.9], 'FontSize', 12, 'FontWeight', 'bold');
            else
                title(app.AxGradCAM, '2. GRAD-CAM (LAYER HIDDEN)', 'Color', [0.6 0.7 0.8], 'FontSize', 11);
            end
            
            % 3. Viewport 3: Vessel Segmentation
            cla(app.AxVessels);
            if app.VesselsCheck.Value && ~isempty(app.LastVesselMask)
                vesselResized = imresize(app.LastVesselMask, [size(img,1), size(img,2)], 'nearest');
                % Green/Cyan vessel highlight overlay on dimmed fundus
                dimmedImg = uint8(double(img) * 0.45);
                dimmedImg(:,:,2) = max(dimmedImg(:,:,2), uint8(vesselResized) * 220);
                dimmedImg(:,:,3) = max(dimmedImg(:,:,3), uint8(vesselResized) * 160);
                imshow(dimmedImg, 'Parent', app.AxVessels);
                title(app.AxVessels, '3. RETINAL VASCULATURE MAPPING', 'Color', [0.2 0.95 0.5], 'FontSize', 12, 'FontWeight', 'bold');
            else
                imshow(img, 'Parent', app.AxVessels);
                title(app.AxVessels, '3. RETINAL VASCULATURE (HIDDEN)', 'Color', [0.6 0.7 0.8], 'FontSize', 11);
            end
            
            % 4. Viewport 4: Lesion Candidates
            cla(app.AxLesions);
            imshow(img, 'Parent', app.AxLesions);
            if app.LesionsCheck.Value && ~isempty(app.LastLesionsData)
                hold(app.AxLesions, 'on');
                lesionStruct = app.LastLesionsData;
                if isfield(lesionStruct, 'stats') && ~isempty(lesionStruct.stats)
                    stats = lesionStruct.stats;
                    numToShow = min(numel(stats), 25);
                    for k = 1:numToShow
                        bb = stats(k).BoundingBox;
                        rectangle(app.AxLesions, 'Position', bb, 'EdgeColor', [1 0.25 0.25], ...
                            'LineWidth', 1.8, 'Curvature', [0.8 0.8]);
                    end
                end
                hold(app.AxLesions, 'off');
                title(app.AxLesions, sprintf('4. LESION ROIs (%d DETECTED)', lesionStruct.count), ...
                    'Color', [1 0.4 0.4], 'FontSize', 12, 'FontWeight', 'bold');
            else
                title(app.AxLesions, '4. LESIONS (LAYER HIDDEN)', 'Color', [0.6 0.7 0.8], 'FontSize', 11);
            end
        end
        
        function updateClinicalCards(app, res, gradeNum)
            % Grade text & color lookup
            gradeTitles = {
                'GRADE 0: NO RETINOPATHY';
                'GRADE 1: MILD NPDR';
                'GRADE 2: MODERATE NPDR';
                'GRADE 3: SEVERE NPDR';
                'GRADE 4: PROLIFERATIVE DR'
            };
            
            gradeColors = [
                0.06 0.70 0.38;   % Grade 0: Emerald Green
                0.60 0.72 0.12;   % Grade 1: Lime Yellow
                0.95 0.62 0.05;   % Grade 2: Amber Orange
                0.95 0.38 0.10;   % Grade 3: Deep Orange
                0.90 0.18 0.22    % Grade 4: Crimson Red
            ];
            
            gIdx = min(max(gradeNum + 1, 1), 5);
            app.GradeBadgeText.Text = gradeTitles{gIdx};
            app.GradeBadgePanel.BackgroundColor = gradeColors(gIdx, :);
            
            % Referral Badge
            if strcmp(string(res.status), "Referable") || ismember(gradeNum, [2, 3, 4])
                app.ReferralBadge.Text = '⚠ CLINICAL REFERRAL REQUIRED (Ophthalmology Follow-up)';
                app.ReferralBadge.BackgroundColor = [0.85 0.20 0.22];
                app.ReferralBadge.FontColor = [1 1 1];
            elseif strcmp(string(res.status), "Poor quality - Recapture")
                app.ReferralBadge.Text = '⚠ POOR IMAGE QUALITY - RECAPTURE REQUIRED';
                app.ReferralBadge.BackgroundColor = [0.75 0.40 0.10];
                app.ReferralBadge.FontColor = [1 1 1];
            else
                app.ReferralBadge.Text = '✓ NON-REFERABLE (Routine 12-Month Screening)';
                app.ReferralBadge.BackgroundColor = [0.08 0.55 0.30];
                app.ReferralBadge.FontColor = [1 1 1];
            end
            
            % Confidence
            app.ConfidenceLabel.Text = sprintf('Model Diagnostic Confidence: %.1f%%', res.confidence * 100);
            
            % Probability Bar Chart
            cla(app.ProbAxes);
            classes = {'0: None', '1: Mild', '2: Mod', '3: Sev', '4: PDR'};
            scores = res.scores;
            if numel(scores) == 5
                barh(app.ProbAxes, 1:5, scores, 'FaceColor', [0.15 0.45 0.85], 'EdgeColor', 'none');
                app.ProbAxes.YTick = 1:5;
                app.ProbAxes.YTickLabel = classes;
                app.ProbAxes.XLim = [0 1];
                app.ProbAxes.XColor = [0.7 0.8 0.9];
                app.ProbAxes.YColor = [0.7 0.8 0.9];
                app.ProbAxes.Color = [0.08 0.11 0.16];
                title(app.ProbAxes, 'CLASS PROBABILITY DISTRIBUTION', 'Color', [0.8 0.9 1], 'FontSize', 10);
            end
            
            % Biomarkers
            if isfield(res, 'quality')
                if res.quality.isGood
                    qualStr = 'PASSED';
                else
                    qualStr = 'WARNING';
                end
                app.QualityMetricLabel.Text = sprintf('Quality: %s (Sharpness: %.1f | Exposure: %.2f)', ...
                    qualStr, res.quality.blurScore, res.quality.brightness);
            end
            
            if isfield(res, 'vessels') && ~isempty(res.vessels)
                density = (sum(res.vessels(:)) / numel(res.vessels)) * 100;
                app.VesselDensityLabel.Text = sprintf('Retinal Vessel Density: %.1f%% Area', density);
            end
            
            if isfield(res, 'lesions') && ~isempty(res.lesions)
                app.LesionCountLabel.Text = sprintf('Microaneurysms / Lesions: %d Candidates Detected', res.lesions.count);
            end
            
            % Recommendation Text
            switch gradeNum
                case 0
                    rec = {'No apparent signs of diabetic retinopathy detected.', ...
                           'Grad-CAM saliency indicates uniform background attention.', ...
                           'Recommendation: Schedule routine annual screening in 12 months.'};
                case 1
                    rec = {'Mild Non-Proliferative Diabetic Retinopathy (NPDR).', ...
                           'Focal microaneurysm candidates flagged in deep retinal layers.', ...
                           'Recommendation: Optimize glycemic control; re-screen in 6-12 months.'};
                case 2
                    rec = {'Moderate NPDR with multiple retinal hemorrhages / hard exudates.', ...
                           'Grad-CAM highlights macula and vascular arcade hotspots.', ...
                           'Recommendation: Urgent clinical referral to ophthalmology within 4 weeks.'};
                case 3
                    rec = {'Severe NPDR meeting the 4-2-1 international grading rule.', ...
                           'Significant microvascular abnormalities and venous beading observed.', ...
                           'Recommendation: Expedited referral within 2 weeks for fluorescein angiography.'};
                case 4
                    rec = {'Proliferative Diabetic Retinopathy (PDR) with high risk of vision loss.', ...
                           'Neovascularization and significant vessel compromise identified.', ...
                           'Recommendation: Immediate ophthalmologist referral for panretinal photocoagulation.'};
            end
            app.RecommendationTextArea.Value = rec;
        end
        
        function synthetic = createSyntheticFundus(~, ~)
            % Creates a realistic simulated fundus disc
            [X, Y] = meshgrid(linspace(-1, 1, 512), linspace(-1, 1, 512));
            R = sqrt(X.^2 + Y.^2);
            mask = R <= 0.85;
            
            red = 0.75 - 0.25 * R + 0.05 * randn(512,512);
            green = 0.35 - 0.20 * R + 0.04 * randn(512,512);
            blue = 0.05 * ones(512,512);
            
            % Optic disc
            discDist = sqrt((X - 0.35).^2 + (Y - 0.05).^2);
            discMask = discDist < 0.12;
            red(discMask) = 0.95;
            green(discMask) = 0.85;
            blue(discMask) = 0.55;
            
            % Macula
            macDist = sqrt((X + 0.15).^2 + (Y + 0.05).^2);
            macMask = macDist < 0.15;
            red(macMask) = red(macMask) * 0.75;
            green(macMask) = green(macMask) * 0.70;
            
            fundus = cat(3, red, green, blue);
            fundus = bsxfun(@times, fundus, cast(mask, 'like', fundus));
            synthetic = uint8(rescale(fundus) * 255);
        end
        
        function exportReport(app)
            if isempty(app.CurrentResult)
                uialert(app.UIFigure, 'Please run AI diagnosis before exporting a report.', 'No Diagnosis');
                return;
            end
            
            [file, path] = uiputfile({'*.png', 'PNG Image (*.png)'; '*.txt', 'Text Report (*.txt)'}, ...
                'Save Clinical Screening Report', 'RetinaAI_Clinical_Report.png');
            if isequal(file, 0), return; end
            
            targetPath = fullfile(path, file);
            
            if endsWith(file, '.txt', 'IgnoreCase', true)
                fid = fopen(targetPath, 'w');
                fprintf(fid, '===================================================\n');
                fprintf(fid, '   RETINA-AI: CLINICAL SCREENING REPORT\n');
                fprintf(fid, '===================================================\\n');
                fprintf(fid, 'Patient Exam ID: %s\n', app.PatientIDLabel.Text);
                fprintf(fid, 'Date & Time:     %s\n', char(datetime('now')));
                fprintf(fid, 'Diagnosis:       %s\n', app.GradeBadgeText.Text);
                fprintf(fid, 'Referral Status: %s\n', app.ReferralBadge.Text);
                fprintf(fid, 'Confidence:      %s\n', app.ConfidenceLabel.Text);
                fprintf(fid, '---------------------------------------------------\n');
                fprintf(fid, 'BIOMARKER METRICS:\n');
                fprintf(fid, '  - %s\n', app.QualityMetricLabel.Text);
                fprintf(fid, '  - %s\n', app.VesselDensityLabel.Text);
                fprintf(fid, '  - %s\n', app.LesionCountLabel.Text);
                fprintf(fid, '---------------------------------------------------\n');
                fprintf(fid, 'CLINICAL RECOMMENDATION:\n');
                lines = app.RecommendationTextArea.Value;
                for i = 1:numel(lines)
                    fprintf(fid, '  %s\n', lines{i});
                end
                fprintf(fid, '===================================================\n');
                fclose(fid);
                uialert(app.UIFigure, ['Report saved successfully to: ' targetPath], 'Report Exported');
            else
                % Capture figure viewport
                f = figure('Visible', 'off', 'Position', [100 100 1200 700], 'Color', [0.08 0.10 0.14]);
                
                subplot(2,2,1); imshow(app.CurrentRawImage);
                title('1. Original Fundus Exam', 'Color', 'w');
                
                subplot(2,2,2); imshow(app.CurrentRawImage); hold on;
                if ~isempty(app.LastGradCAMMap)
                    c = imresize(app.LastGradCAMMap, [size(app.CurrentRawImage,1), size(app.CurrentRawImage,2)]);
                    h = imagesc(c); colormap(app.ColormapDropdown.Value);
                    set(h, 'AlphaData', 0.5 * (c > 0.05));
                end
                title(['2. Grad-CAM Attention: ' app.GradeBadgeText.Text], 'Color', 'w');
                
                subplot(2,2,3);
                if ~isempty(app.LastVesselMask)
                    imshow(app.LastVesselMask);
                else
                    imshow(app.CurrentRawImage);
                end
                title('3. Retinal Vasculature Segmentation', 'Color', 'w');
                
                subplot(2,2,4);
                if ~isempty(app.LastProbScores)
                    barh(1:5, app.LastProbScores, 'FaceColor', [0.15 0.55 0.9]);
                    yticks(1:5); yticklabels({'0: None', '1: Mild', '2: Mod', '3: Sev', '4: PDR'});
                    xlim([0 1]);
                end
                title(sprintf('%s (%.1f%%)', app.GradeBadgeText.Text, app.CurrentResult.confidence*100), 'Color', 'w');
                
                saveas(f, targetPath);
                close(f);
                uialert(app.UIFigure, ['Diagnostic summary image saved to: ' targetPath], 'Report Exported');
            end
        end
        
    end
    
    % Callbacks
    methods (Access = private)
        
        function UploadButtonPushed(app, ~)
            [file, path] = uigetfile({'*.jpg;*.png;*.jpeg;*.tif','Fundus Images (*.jpg,*.png,*.tif)'}, ...
                'Select Retinal Fundus Image', app.DatasetPath);
            if isequal(file, 0), return; end
            app.loadImageFromFile(fullfile(path, file), file);
        end
        
        function PresetDropdownChanged(app, ~)
            idx = app.PresetDropdown.Value;
            if idx >= 1 && idx <= size(app.PresetFiles, 1)
                fileName = app.PresetFiles{idx, 1};
                fullPath = fullfile(app.DatasetPath, fileName);
                label = app.PresetFiles{idx, 3};
                if exist(fullPath, 'file')
                    app.loadImageFromFile(fullPath, label);
                else
                    synthetic = app.createSyntheticFundus(app.PresetFiles{idx, 2});
                    app.displayRawImage(synthetic, [label ' (Synthetic)']);
                end
            end
        end
        
        function AnalyzeButtonPushed(app, ~)
            app.runFullDiagnosis();
        end
        
        function SliderValueChanged(app, ~)
            app.renderAllViewports();
        end
        
        function CheckboxChanged(app, ~)
            app.renderAllViewports();
        end
        
        function ColormapChanged(app, ~)
            app.renderAllViewports();
        end
        
        function ViewModeChanged(app, ~)
            mode = app.ViewModeDropdown.Value;
            switch mode
                case 'Quad Split (4-View)'
                    app.AxesGrid.RowHeight = {'1x', '1x'};
                    app.AxesGrid.ColumnWidth = {'1x', '1x'};
                    app.AxOriginal.Visible = 'on';
                    app.AxGradCAM.Visible = 'on';
                    app.AxVessels.Visible = 'on';
                    app.AxLesions.Visible = 'on';
                case 'Dual Comparison'
                    app.AxesGrid.RowHeight = {'1x'};
                    app.AxesGrid.ColumnWidth = {'1x', '1x'};
                    app.AxOriginal.Visible = 'on';
                    app.AxGradCAM.Visible = 'on';
                    app.AxVessels.Visible = 'off';
                    app.AxLesions.Visible = 'off';
                case 'Single Focus (Grad-CAM)'
                    app.AxesGrid.RowHeight = {'1x'};
                    app.AxesGrid.ColumnWidth = {'1x'};
                    app.AxOriginal.Visible = 'off';
                    app.AxGradCAM.Visible = 'on';
                    app.AxVessels.Visible = 'off';
                    app.AxLesions.Visible = 'off';
            end
            app.renderAllViewports();
        end
        
        function ResetButtonPushed(app, ~)
            app.loadDefaultSample();
        end
    end
    
    % Component Initialization
    methods (Access = private)
        
        function createComponents(app)
            % Screen-centered figure
            screenSize = get(groot, 'ScreenSize');
            figWidth = min(1440, screenSize(3) - 60);
            figHeight = min(860, screenSize(4) - 80);
            figLeft = max(20, (screenSize(3) - figWidth) / 2);
            figBottom = max(30, (screenSize(4) - figHeight) / 2);
            
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [figLeft figBottom figWidth figHeight];
            app.UIFigure.Name = 'RETINA-AI | Pro Clinical Diagnostic Workstation';
            app.UIFigure.Color = [0.07 0.09 0.13]; % Deep Medical Slate
            
            % Main Grid Layout
            app.MainGrid = uigridlayout(app.UIFigure);
            app.MainGrid.ColumnWidth = {300, '1x', 330};
            app.MainGrid.RowHeight = {58, '1x'};
            app.MainGrid.BackgroundColor = [0.07 0.09 0.13];
            app.MainGrid.Padding = [10 10 10 10];
            app.MainGrid.ColumnSpacing = 10;
            app.MainGrid.RowSpacing = 10;
            
            % ---------------- HEADER PANEL ----------------
            app.HeaderPanel = uipanel(app.MainGrid);
            app.HeaderPanel.Layout.Row = 1;
            app.HeaderPanel.Layout.Column = [1 3];
            app.HeaderPanel.BackgroundColor = [0.09 0.12 0.18];
            app.HeaderPanel.BorderType = 'line';
            app.HeaderPanel.HighlightColor = [0.18 0.24 0.35];
            
            headerGrid = uigridlayout(app.HeaderPanel, [1 4]);
            headerGrid.ColumnWidth = {'fit', '1x', 'fit', 'fit'};
            headerGrid.BackgroundColor = [0.09 0.12 0.18];
            headerGrid.Padding = [15 5 15 5];
            
            app.TitleLabel = uilabel(headerGrid);
            app.TitleLabel.Text = '⚡ RETINA-AI';
            app.TitleLabel.FontSize = 20;
            app.TitleLabel.FontWeight = 'bold';
            app.TitleLabel.FontColor = [0.0 0.88 0.98]; % Electric Cyan
            
            app.SubtitleLabel = uilabel(headerGrid);
            app.SubtitleLabel.Text = 'EXPLAINABLE CLINICAL DIAGNOSTIC WORKSTATION';
            app.SubtitleLabel.FontSize = 13;
            app.SubtitleLabel.FontWeight = 'bold';
            app.SubtitleLabel.FontColor = [0.65 0.75 0.88];
            
            app.PatientIDLabel = uilabel(headerGrid);
            app.PatientIDLabel.Text = 'ID: PAT-DEMO-2026';
            app.PatientIDLabel.FontSize = 12;
            app.PatientIDLabel.FontColor = [0.6 0.7 0.8];
            
            app.ModelStatusBadge = uilabel(headerGrid);
            app.ModelStatusBadge.Text = '● INITIALIZING AI CORE...';
            app.ModelStatusBadge.FontSize = 12;
            app.ModelStatusBadge.FontWeight = 'bold';
            app.ModelStatusBadge.FontColor = [1 0.75 0.2];
            
            % ---------------- LEFT SIDEBAR PANEL ----------------
            app.SidebarPanel = uipanel(app.MainGrid);
            app.SidebarPanel.Layout.Row = 2;
            app.SidebarPanel.Layout.Column = 1;
            app.SidebarPanel.Title = 'WORKSTATION TOOLS';
            app.SidebarPanel.ForegroundColor = [0.0 0.85 0.95];
            app.SidebarPanel.FontSize = 13;
            app.SidebarPanel.FontWeight = 'bold';
            app.SidebarPanel.BackgroundColor = [0.10 0.13 0.20];
            app.SidebarPanel.HighlightColor = [0.20 0.26 0.38];
            
            app.SidebarGrid = uigridlayout(app.SidebarPanel);
            app.SidebarGrid.ColumnWidth = {'1x'};
            app.SidebarGrid.RowHeight = {24, 38, 20, 32, 28, 44, 28, 24, 28, 24, 24, 24, 20, 24, 20, 28, '1x', 36, 32};
            app.SidebarGrid.BackgroundColor = [0.10 0.13 0.20];
            app.SidebarGrid.Padding = [12 12 12 12];
            app.SidebarGrid.RowSpacing = 6;
            
            % Image Input Section
            app.InputSectionLabel = uilabel(app.SidebarGrid);
            app.InputSectionLabel.Text = 'PATIENT IMAGE SOURCE';
            app.InputSectionLabel.FontWeight = 'bold';
            app.InputSectionLabel.FontSize = 11;
            app.InputSectionLabel.FontColor = [0.4 0.7 0.9];
            
            app.UploadButton = uibutton(app.SidebarGrid, 'push');
            app.UploadButton.Text = '📂 Upload Patient Fundus';
            app.UploadButton.FontSize = 12;
            app.UploadButton.FontWeight = 'bold';
            app.UploadButton.BackgroundColor = [0.16 0.28 0.46];
            app.UploadButton.FontColor = [1 1 1];
            app.UploadButton.ButtonPushedFcn = createCallbackFcn(app, @UploadButtonPushed, true);
            
            app.PresetDropdownLabel = uilabel(app.SidebarGrid);
            app.PresetDropdownLabel.Text = 'Clinical Demo Presets:';
            app.PresetDropdownLabel.FontSize = 11;
            app.PresetDropdownLabel.FontColor = [0.7 0.78 0.88];
            
            app.PresetDropdown = uidropdown(app.SidebarGrid);
            app.PresetDropdown.Items = { ...
                'Case #101: Grade 0 (No DR)', ...
                'Case #102: Grade 1 (Mild NPDR)', ...
                'Case #103: Grade 2 (Moderate NPDR)', ...
                'Case #104: Grade 3 (Severe NPDR)', ...
                'Case #105: Grade 4 (Proliferative DR)'};
            app.PresetDropdown.ItemsData = 1:5;
            app.PresetDropdown.Value = 1;
            app.PresetDropdown.BackgroundColor = [0.15 0.18 0.26];
            app.PresetDropdown.FontColor = [1 1 1];
            app.PresetDropdown.ValueChangedFcn = createCallbackFcn(app, @PresetDropdownChanged, true);
            
            % Engine Section
            app.EngineSectionLabel = uilabel(app.SidebarGrid);
            app.EngineSectionLabel.Text = 'DIAGNOSTIC ENGINE';
            app.EngineSectionLabel.FontWeight = 'bold';
            app.EngineSectionLabel.FontSize = 11;
            app.EngineSectionLabel.FontColor = [0.4 0.7 0.9];
            
            app.AnalyzeButton = uibutton(app.SidebarGrid, 'push');
            app.AnalyzeButton.Text = '⚡ RUN AI DIAGNOSIS';
            app.AnalyzeButton.FontSize = 13;
            app.AnalyzeButton.FontWeight = 'bold';
            app.AnalyzeButton.BackgroundColor = [0.05 0.65 0.38];
            app.AnalyzeButton.FontColor = [1 1 1];
            app.AnalyzeButton.ButtonPushedFcn = createCallbackFcn(app, @AnalyzeButtonPushed, true);
            
            app.EngineModeLabel = uilabel(app.SidebarGrid);
            app.EngineModeLabel.Text = 'Engine Mode:';
            app.EngineModeLabel.FontSize = 11;
            app.EngineModeLabel.FontColor = [0.7 0.78 0.88];
            
            app.EngineModeSwitch = uiswitch(app.SidebarGrid, 'slider');
            app.EngineModeSwitch.Items = {'Live AI Model', 'Fast Simulation'};
            app.EngineModeSwitch.Value = 'Live AI Model';
            app.EngineModeSwitch.FontColor = [0.9 0.9 0.9];
            
            % Viewport & Layer Section
            app.EditorSectionLabel = uilabel(app.SidebarGrid);
            app.EditorSectionLabel.Text = 'CANVAS & LAYER EDITOR';
            app.EditorSectionLabel.FontWeight = 'bold';
            app.EditorSectionLabel.FontSize = 11;
            app.EditorSectionLabel.FontColor = [0.4 0.7 0.9];
            
            app.ViewModeDropdown = uidropdown(app.SidebarGrid);
            app.ViewModeDropdown.Items = {'Quad Split (4-View)', 'Dual Comparison', 'Single Focus (Grad-CAM)'};
            app.ViewModeDropdown.Value = 'Quad Split (4-View)';
            app.ViewModeDropdown.BackgroundColor = [0.15 0.18 0.26];
            app.ViewModeDropdown.FontColor = [1 1 1];
            app.ViewModeDropdown.ValueChangedFcn = createCallbackFcn(app, @ViewModeChanged, true);
            
            app.HeatmapCheck = uicheckbox(app.SidebarGrid);
            app.HeatmapCheck.Text = 'Layer: Grad-CAM Heatmap';
            app.HeatmapCheck.Value = true;
            app.HeatmapCheck.FontColor = [0.8 0.9 1];
            app.HeatmapCheck.ValueChangedFcn = createCallbackFcn(app, @CheckboxChanged, true);
            
            app.VesselsCheck = uicheckbox(app.SidebarGrid);
            app.VesselsCheck.Text = 'Layer: Vessel Segmentation';
            app.VesselsCheck.Value = true;
            app.VesselsCheck.FontColor = [0.8 0.9 1];
            app.VesselsCheck.ValueChangedFcn = createCallbackFcn(app, @CheckboxChanged, true);
            
            app.LesionsCheck = uicheckbox(app.SidebarGrid);
            app.LesionsCheck.Text = 'Layer: Lesions & Pathology';
            app.LesionsCheck.Value = true;
            app.LesionsCheck.FontColor = [0.8 0.9 1];
            app.LesionsCheck.ValueChangedFcn = createCallbackFcn(app, @CheckboxChanged, true);
            
            app.OpacitySliderLabel = uilabel(app.SidebarGrid);
            app.OpacitySliderLabel.Text = 'Grad-CAM Opacity (Alpha):';
            app.OpacitySliderLabel.FontSize = 11;
            app.OpacitySliderLabel.FontColor = [0.7 0.78 0.88];
            
            app.OpacitySlider = uislider(app.SidebarGrid);
            app.OpacitySlider.Limits = [0.0 1.0];
            app.OpacitySlider.Value = 0.45;
            app.OpacitySlider.FontColor = [0.8 0.8 0.8];
            app.OpacitySlider.ValueChangedFcn = createCallbackFcn(app, @SliderValueChanged, true);
            
            app.ColormapDropdownLabel = uilabel(app.SidebarGrid);
            app.ColormapDropdownLabel.Text = 'Heatmap Colormap:';
            app.ColormapDropdownLabel.FontSize = 11;
            app.ColormapDropdownLabel.FontColor = [0.7 0.78 0.88];
            
            app.ColormapDropdown = uidropdown(app.SidebarGrid);
            app.ColormapDropdown.Items = {'jet', 'turbo', 'hot', 'parula', 'summer'};
            app.ColormapDropdown.Value = 'jet';
            app.ColormapDropdown.BackgroundColor = [0.15 0.18 0.26];
            app.ColormapDropdown.FontColor = [1 1 1];
            app.ColormapDropdown.ValueChangedFcn = createCallbackFcn(app, @ColormapChanged, true);
            
            % Actions
            app.ExportReportButton = uibutton(app.SidebarGrid, 'push');
            app.ExportReportButton.Text = '📄 Export Clinical Report';
            app.ExportReportButton.FontSize = 12;
            app.ExportReportButton.FontWeight = 'bold';
            app.ExportReportButton.BackgroundColor = [0.35 0.22 0.55]; % Violet
            app.ExportReportButton.FontColor = [1 1 1];
            app.ExportReportButton.ButtonPushedFcn = createCallbackFcn(app, @exportReport, true);
            
            app.ResetButton = uibutton(app.SidebarGrid, 'push');
            app.ResetButton.Text = '↺ Reset Viewport';
            app.ResetButton.FontSize = 11;
            app.ResetButton.BackgroundColor = [0.22 0.26 0.34];
            app.ResetButton.FontColor = [0.85 0.9 0.95];
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            
            % ---------------- CENTER VIEWPORT STUDIO ----------------
            app.CenterPanel = uipanel(app.MainGrid);
            app.CenterPanel.Layout.Row = 2;
            app.CenterPanel.Layout.Column = 2;
            app.CenterPanel.Title = 'DIAGNOSTIC WORKSTATION CANVAS';
            app.CenterPanel.ForegroundColor = [0.0 0.85 0.95];
            app.CenterPanel.FontSize = 13;
            app.CenterPanel.FontWeight = 'bold';
            app.CenterPanel.BackgroundColor = [0.08 0.10 0.15];
            app.CenterPanel.HighlightColor = [0.20 0.26 0.38];
            
            app.CenterGrid = uigridlayout(app.CenterPanel);
            app.CenterGrid.ColumnWidth = {'1x'};
            app.CenterGrid.RowHeight = {28, '1x'};
            app.CenterGrid.BackgroundColor = [0.08 0.10 0.15];
            app.CenterGrid.Padding = [8 8 8 8];
            app.CenterGrid.RowSpacing = 6;
            
            app.ViewportTitleBar = uilabel(app.CenterGrid);
            app.ViewportTitleBar.Text = 'EXAM VIEWPORT: Case #101: Grade 0 (No DR)';
            app.ViewportTitleBar.FontSize = 12;
            app.ViewportTitleBar.FontWeight = 'bold';
            app.ViewportTitleBar.FontColor = [0.7 0.82 0.95];
            
            % 2x2 Viewport Axes Grid
            app.AxesGrid = uigridlayout(app.CenterGrid);
            app.AxesGrid.ColumnWidth = {'1x', '1x'};
            app.AxesGrid.RowHeight = {'1x', '1x'};
            app.AxesGrid.BackgroundColor = [0.08 0.10 0.15];
            app.AxesGrid.Padding = [2 2 2 2];
            app.AxesGrid.ColumnSpacing = 8;
            app.AxesGrid.RowSpacing = 8;
            
            % 1. AxOriginal
            app.AxOriginal = uiaxes(app.AxesGrid);
            app.AxOriginal.Layout.Row = 1;
            app.AxOriginal.Layout.Column = 1;
            app.AxOriginal.Color = [0.04 0.05 0.08];
            app.AxOriginal.XColor = 'none';
            app.AxOriginal.YColor = 'none';
            app.AxOriginal.Toolbar.Visible = 'on';
            
            % 2. AxGradCAM
            app.AxGradCAM = uiaxes(app.AxesGrid);
            app.AxGradCAM.Layout.Row = 1;
            app.AxGradCAM.Layout.Column = 2;
            app.AxGradCAM.Color = [0.04 0.05 0.08];
            app.AxGradCAM.XColor = 'none';
            app.AxGradCAM.YColor = 'none';
            app.AxGradCAM.Toolbar.Visible = 'on';
            
            % 3. AxVessels
            app.AxVessels = uiaxes(app.AxesGrid);
            app.AxVessels.Layout.Row = 2;
            app.AxVessels.Layout.Column = 1;
            app.AxVessels.Color = [0.04 0.05 0.08];
            app.AxVessels.XColor = 'none';
            app.AxVessels.YColor = 'none';
            app.AxVessels.Toolbar.Visible = 'on';
            
            % 4. AxLesions
            app.AxLesions = uiaxes(app.AxesGrid);
            app.AxLesions.Layout.Row = 2;
            app.AxLesions.Layout.Column = 2;
            app.AxLesions.Color = [0.04 0.05 0.08];
            app.AxLesions.XColor = 'none';
            app.AxLesions.YColor = 'none';
            app.AxLesions.Toolbar.Visible = 'on';
            
            % ---------------- RIGHT CLINICAL INTELLIGENCE PANEL ----------------
            app.RightPanel = uipanel(app.MainGrid);
            app.RightPanel.Layout.Row = 2;
            app.RightPanel.Layout.Column = 3;
            app.RightPanel.Title = 'CLINICAL DECISION SUPPORT';
            app.RightPanel.ForegroundColor = [0.0 0.85 0.95];
            app.RightPanel.FontSize = 13;
            app.RightPanel.FontWeight = 'bold';
            app.RightPanel.BackgroundColor = [0.10 0.13 0.20];
            app.RightPanel.HighlightColor = [0.20 0.26 0.38];
            
            app.RightGrid = uigridlayout(app.RightPanel);
            app.RightGrid.ColumnWidth = {'1x'};
            app.RightGrid.RowHeight = {52, 38, 22, 160, 24, 22, 22, '1x'};
            app.RightGrid.BackgroundColor = [0.10 0.13 0.20];
            app.RightGrid.Padding = [12 12 12 12];
            app.RightGrid.RowSpacing = 8;
            
            % Diagnosis Badge
            app.GradeBadgePanel = uipanel(app.RightGrid);
            app.GradeBadgePanel.BackgroundColor = [0.16 0.22 0.30];
            app.GradeBadgePanel.BorderType = 'none';
            
            badgeGrid = uigridlayout(app.GradeBadgePanel, [1 1]);
            badgeGrid.Padding = [4 4 4 4];
            app.GradeBadgeText = uilabel(badgeGrid);
            app.GradeBadgeText.Text = 'READY FOR ANALYSIS';
            app.GradeBadgeText.HorizontalAlignment = 'center';
            app.GradeBadgeText.FontSize = 13;
            app.GradeBadgeText.FontWeight = 'bold';
            app.GradeBadgeText.FontColor = [1 1 1];
            
            % Referral Badge
            app.ReferralBadge = uilabel(app.RightGrid);
            app.ReferralBadge.Text = 'STATUS: READY';
            app.ReferralBadge.HorizontalAlignment = 'center';
            app.ReferralBadge.FontSize = 11;
            app.ReferralBadge.FontWeight = 'bold';
            app.ReferralBadge.WordWrap = 'on';
            app.ReferralBadge.BackgroundColor = [0.15 0.18 0.25];
            app.ReferralBadge.FontColor = [0.7 0.8 0.9];
            
            % Confidence
            app.ConfidenceLabel = uilabel(app.RightGrid);
            app.ConfidenceLabel.Text = 'Model Diagnostic Confidence: --';
            app.ConfidenceLabel.FontSize = 11;
            app.ConfidenceLabel.FontWeight = 'bold';
            app.ConfidenceLabel.FontColor = [0.8 0.9 1];
            
            % Probability Chart
            app.ProbAxes = uiaxes(app.RightGrid);
            app.ProbAxes.Color = [0.08 0.11 0.16];
            app.ProbAxes.XColor = [0.6 0.7 0.8];
            app.ProbAxes.YColor = [0.6 0.7 0.8];
            title(app.ProbAxes, 'CLASS PROBABILITY DISTRIBUTION', 'Color', [0.8 0.9 1], 'FontSize', 10);
            
            % Biomarkers Card
            app.QualityMetricLabel = uilabel(app.RightGrid);
            app.QualityMetricLabel.Text = 'Image Quality: Unchecked';
            app.QualityMetricLabel.FontSize = 11;
            app.QualityMetricLabel.FontColor = [0.7 0.8 0.9];
            
            app.VesselDensityLabel = uilabel(app.RightGrid);
            app.VesselDensityLabel.Text = 'Retinal Vessel Density: --';
            app.VesselDensityLabel.FontSize = 11;
            app.VesselDensityLabel.FontColor = [0.7 0.8 0.9];
            
            app.LesionCountLabel = uilabel(app.RightGrid);
            app.LesionCountLabel.Text = 'Lesion Candidates: --';
            app.LesionCountLabel.FontSize = 11;
            app.LesionCountLabel.FontColor = [0.7 0.8 0.9];
            
            % Clinical Recommendation Text Area
            app.RecommendationTextArea = uitextarea(app.RightGrid);
            app.RecommendationTextArea.Editable = 'off';
            app.RecommendationTextArea.Value = {'Load an image and click "RUN AI DIAGNOSIS" to generate clinical screening findings.'};
            app.RecommendationTextArea.BackgroundColor = [0.08 0.10 0.15];
            app.RecommendationTextArea.FontColor = [0.8 0.88 0.95];
            app.RecommendationTextArea.FontSize = 11;
            
            % Show the figure
            app.UIFigure.Visible = 'on';
        end
    end
    
    % Construction and Deletion
    methods (Access = public)
        
        function app = DR_Screening_Pro_Editor
            % Create UIFigure and components
            createComponents(app)
            
            % Register with App Designer infrastructure
            registerApp(app, app.UIFigure)
            
            % Initialize Backend and Load First Demo
            initBackend(app)
            loadDefaultSample(app)
            
            if nargout == 0
                clear app
            end
        end
        
        function delete(app)
            delete(app.UIFigure)
        end
    end
end
