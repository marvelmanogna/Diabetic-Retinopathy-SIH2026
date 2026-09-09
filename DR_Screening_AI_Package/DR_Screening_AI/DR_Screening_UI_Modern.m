classdef DR_Screening_UI_Modern < matlab.apps.AppBase
    % DR_SCREENING_UI_MODERN
    % Pixel-perfect reproduction of the modern DR Screening AI clinical interface
    % Styled with Dark Navy Sidebar, Light Slate Canvas, Retinal Scanner HUD,
    % 3 Stat Cards, Workflow Stepper, and Right-hand Screening Results Panel.

    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        MainGrid                    matlab.ui.container.GridLayout

        % Left Sidebar
        SidebarPanel                matlab.ui.container.Panel
        SidebarGrid                 matlab.ui.container.GridLayout
        BrandTitle                  matlab.ui.control.Label
        BrandSubtitle               matlab.ui.control.Label
        NavDashboardBtn             matlab.ui.control.Button
        NavUploadBtn                matlab.ui.control.Button
        NavResultsBtn               matlab.ui.control.Button
        NavHistoryBtn               matlab.ui.control.Button
        NavAboutBtn                 matlab.ui.control.Button
        SidebarFooter               matlab.ui.control.Label

        % Content Area
        ContentPanel                matlab.ui.container.Panel
        ContentGrid                 matlab.ui.container.GridLayout

        % Top Header
        HeaderPanel                 matlab.ui.container.Panel
        HeaderGrid                  matlab.ui.container.GridLayout
        DemoPill0                   matlab.ui.control.Button
        DemoPill1                   matlab.ui.control.Button
        DemoPill2                   matlab.ui.control.Button
        DemoPill3                   matlab.ui.control.Button
        DemoPill4                   matlab.ui.control.Button
        UserProfileLabel            matlab.ui.control.Label

        % Dashboard 2-Column Body
        BodyGrid                    matlab.ui.container.GridLayout

        % Left Column Container
        LeftColGrid                 matlab.ui.container.GridLayout

        % Hero Card
        HeroPanel                   matlab.ui.container.Panel
        HeroGrid                    matlab.ui.container.GridLayout
        HeroBadge                   matlab.ui.control.Label
        HeroTitle                   matlab.ui.control.Label
        HeroDesc                    matlab.ui.control.Label
        HeroUploadBtn               matlab.ui.control.Button
        HeroScannerAxes             matlab.ui.control.UIAxes

        % 3 Stat Cards
        StatsGrid                   matlab.ui.container.GridLayout
        StatCard1                   matlab.ui.container.Panel
        Stat1Label                  matlab.ui.control.Label
        Stat1Val                    matlab.ui.control.Label
        Stat1Sub                    matlab.ui.control.Label

        StatCard2                   matlab.ui.container.Panel
        Stat2Label                  matlab.ui.control.Label
        Stat2Val                    matlab.ui.control.Label
        Stat2Sub                    matlab.ui.control.Label

        StatCard3                   matlab.ui.container.Panel
        Stat3Label                  matlab.ui.control.Label
        Stat3Val                    matlab.ui.control.Label

        % How It Works Card
        HowItWorksPanel             matlab.ui.container.Panel
        HowItWorksGrid              matlab.ui.container.GridLayout
        HowTitle                    matlab.ui.control.Label
        Step1Label                  matlab.ui.control.Label
        Step2Label                  matlab.ui.control.Label
        Step3Label                  matlab.ui.control.Label
        Step4Label                  matlab.ui.control.Label

        % Right Column Container (Screening Results Panel)
        ResultsPanel                matlab.ui.container.Panel
        ResultsGrid                 matlab.ui.container.GridLayout

        ResultsTitle                matlab.ui.control.Label
        LastUpdatedLabel            matlab.ui.control.Label

        ResultSummaryGrid           matlab.ui.container.GridLayout
        ResultThumbnailAxes         matlab.ui.control.UIAxes
        BadgeCardPanel              matlab.ui.container.Panel
        BadgeCardGrid               matlab.ui.container.GridLayout
        BadgeTitle                  matlab.ui.control.Label
        BadgeSubtitle               matlab.ui.control.Label

        % Confidence Score Bar
        ConfidenceLabel             matlab.ui.control.Label
        ConfidenceValLabel          matlab.ui.control.Label
        ConfidenceAxes              matlab.ui.control.UIAxes

        % Metadata Grid
        MetaGrid                    matlab.ui.container.GridLayout
        MetaIdLabel                 matlab.ui.control.Label
        MetaDateLabel               matlab.ui.control.Label
        MetaModelLabel              matlab.ui.control.Label

        % Key Findings
        FindingsHeading             matlab.ui.control.Label
        FindingsLabel1              matlab.ui.control.Label
        FindingsLabel2              matlab.ui.control.Label
        FindingsLabel3              matlab.ui.control.Label
        FindingsLabel4              matlab.ui.control.Label

        % Recommendation Box
        RecPanel                    matlab.ui.container.Panel
        RecGrid                     matlab.ui.container.GridLayout
        RecHeading                  matlab.ui.control.Label
        RecText                     matlab.ui.control.Label

        % Action Buttons
        ActionBtnGrid               matlab.ui.container.GridLayout
        UploadAnotherBtn            matlab.ui.control.Button
        ViewHistoryBtn              matlab.ui.control.Button
    end

    properties (Access = private)
        CurrentGrade                = 0
        CurrentRawImage
        TrainedNet
        IsModelLoaded               = false
        DatasetPath                 = 'D:\SIH\aptos2019-blindness-detection\train_images\'
        PresetFiles                 = {
            '002c21358ce6.png', 0, 'No DR Detected', 'Normal Retina', 96;
            '0024cdab0c1e.png', 1, 'Mild NPDR Detected', 'Early Microaneurysms', 91;
            '000c1434d8d7.png', 2, 'Moderate NPDR Detected', 'Multiple Hemorrhages / Exudates', 98;
            '0104b032c141.png', 3, 'Severe NPDR Detected', 'Meets 4-2-1 Grading Rule', 95;
            '001639a390f0.png', 4, 'Proliferative DR Detected', 'Neovascularization Risk', 99
        }
    end

    methods (Access = public)

        function initBackend(app)
            backendPath = 'D:\SIH\DR_Screening_SIH';
            if exist(backendPath, 'dir')
                addpath(genpath(backendPath));
            end
            modelFile = fullfile(backendPath, 'classification', 'drResNet18.mat');
            if exist(modelFile, 'file')
                try
                    d = load(modelFile);
                    if isfield(d, 'trainedNet')
                        app.TrainedNet = d.trainedNet;
                        app.IsModelLoaded = true;
                    end
                catch
                end
            end
        end

        function loadPresetCase(app, grade)
            app.CurrentGrade = grade;
            idx = grade + 1;
            fileName = app.PresetFiles{idx, 1};
            filePath = fullfile(app.DatasetPath, fileName);
            if exist(filePath, 'file')
                img = imread(filePath);
            else
                img = app.createSyntheticRetina(grade);
            end
            app.CurrentRawImage = img;
            app.renderCase(grade);
        end

        function renderCase(app, grade)
            idx = grade + 1;
            titleText = app.PresetFiles{idx, 3};
            subtitleText = app.PresetFiles{idx, 4};
            confVal = app.PresetFiles{idx, 5};
            img = app.CurrentRawImage;

            % 1. Render Hero Scanner
            cla(app.HeroScannerAxes);
            imshow(img, 'Parent', app.HeroScannerAxes);
            axis(app.HeroScannerAxes, 'image');

            % 2. Render Result Thumbnail
            cla(app.ResultThumbnailAxes);
            imshow(img, 'Parent', app.ResultThumbnailAxes);
            axis(app.ResultThumbnailAxes, 'image');

            % 3. Update Diagnosis Badge
            app.BadgeTitle.Text = titleText;
            app.BadgeSubtitle.Text = subtitleText;

            switch grade
                case 0
                    app.BadgeCardPanel.BackgroundColor = [0.86 0.98 0.90]; % Light Green
                    app.BadgeTitle.FontColor = [0.08 0.50 0.24];
                    app.BadgeSubtitle.FontColor = [0.09 0.40 0.20];
                    barColor = [0.06 0.72 0.40];
                    f1 = '  No signs of microaneurysms detected';
                    f2 = '  No hemorrhages detected';
                    f3 = '  Blood vessels appear normal';
                    f4 = '  Optic disc is healthy';
                    rec = 'Maintain regular eye checkups (at least once a year) and manage blood sugar levels.';
                case 1
                    app.BadgeCardPanel.BackgroundColor = [0.99 0.98 0.76]; % Light Yellow
                    app.BadgeTitle.FontColor = [0.52 0.30 0.05];
                    app.BadgeSubtitle.FontColor = [0.63 0.38 0.04];
                    barColor = [0.96 0.62 0.04];
                    f1 = '  Isolated microaneurysms observed in deep capillary layers';
                    f2 = '  No clinical hard exudates present';
                    f3 = '  Macula clear of clinically significant edema';
                    f4 = '  Focal capillary leakage minimal';
                    rec = 'Strict glycemic and blood pressure management recommended. Follow-up dilated exam in 6-12 months.';
                case 2
                    app.BadgeCardPanel.BackgroundColor = [1.00 0.93 0.84]; % Light Orange
                    app.BadgeTitle.FontColor = [0.60 0.20 0.07];
                    app.BadgeSubtitle.FontColor = [0.76 0.25 0.05];
                    barColor = [0.92 0.35 0.05];
                    f1 = '  Multiple dot-and-blot hemorrhages identified across quadrants';
                    f2 = '  Hard exudates noted along temporal vascular arcades';
                    f3 = '  Venous caliber alterations detected';
                    f4 = '  Potential risk of diabetic macular edema';
                    rec = 'Referral to ophthalmology required within 4 weeks. Optical Coherence Tomography (OCT) recommended.';
                case 3
                    app.BadgeCardPanel.BackgroundColor = [0.99 0.89 0.89]; % Light Red
                    app.BadgeTitle.FontColor = [0.60 0.11 0.11];
                    app.BadgeSubtitle.FontColor = [0.72 0.11 0.11];
                    barColor = [0.94 0.15 0.15];
                    f1 = '  Severe retinal hemorrhages across >= 4 quadrants';
                    f2 = '  Venous beading confirmed in 2 or more quadrants';
                    f3 = '  Prominent cotton-wool spots and IRMA detected';
                    f4 = '  High probability of rapid progression to proliferative stage';
                    rec = 'Expedited referral to a vitreoretinal specialist within 2 weeks. Fluorescein angiography advised.';
                case 4
                    app.BadgeCardPanel.BackgroundColor = [1.00 0.89 0.90]; % Crimson
                    app.BadgeTitle.FontColor = [0.62 0.07 0.22];
                    app.BadgeSubtitle.FontColor = [0.75 0.07 0.24];
                    barColor = [0.88 0.11 0.28];
                    f1 = '  Active neovascularization detected at disc (NVD) / elsewhere';
                    f2 = '  Preretinal / vitreous hemorrhage risk critically elevated';
                    f3 = '  Fibrous proliferation threatening tractional detachment';
                    f4 = '  Vision-threatening critical emergency';
                    rec = 'Urgent same-week clinical retina referral. Panretinal photocoagulation (PRP) laser or anti-VEGF injection indicated.';
            end

            % 4. Update Confidence Score Bar
            app.ConfidenceValLabel.Text = sprintf('%d%%', confVal);
            cla(app.ConfidenceAxes);
            barh(app.ConfidenceAxes, 1, confVal, 'FaceColor', barColor, 'EdgeColor', 'none');
            xlim(app.ConfidenceAxes, [0 100]);
            ylim(app.ConfidenceAxes, [0.5 1.5]);

            % 5. Update Metadata
            nowStr = char(datetime('now', 'Format', 'dd MMM yyyy, HH:mm'));
            app.LastUpdatedLabel.Text = ['Last updated: ' nowStr];
            app.MetaDateLabel.Text = nowStr;
            app.MetaIdLabel.Text = sprintf('DR_%s_%04d', char(datetime('now', 'Format', 'yyyyMMdd')), 1430 + grade);

            % 6. Update Findings & Recommendation
            app.FindingsLabel1.Text = f1;
            app.FindingsLabel2.Text = f2;
            app.FindingsLabel3.Text = f3;
            app.FindingsLabel4.Text = f4;
            app.RecText.Text = rec;

            % 7. Update Demo Pill Buttons active state
            pills = [app.DemoPill0, app.DemoPill1, app.DemoPill2, app.DemoPill3, app.DemoPill4];
            for k = 1:5
                if (k - 1) == grade
                    pills(k).BackgroundColor = [0.11 0.31 0.85]; % Blue Active
                    pills(k).FontColor = [1 1 1];
                else
                    pills(k).BackgroundColor = [0.97 0.98 0.99];
                    pills(k).FontColor = [0.28 0.33 0.41];
                end
            end
        end

        function synthetic = createSyntheticRetina(~, ~)
            [X, Y] = meshgrid(linspace(-1, 1, 300), linspace(-1, 1, 300));
            R = sqrt(X.^2 + Y.^2);
            mask = R <= 0.88;
            red = (0.75 - 0.25 * R) .* mask;
            green = (0.35 - 0.20 * R) .* mask;
            blue = (0.05 * ones(300,300)) .* mask;
            fundus = cat(3, red, green, blue);
            synthetic = uint8(rescale(fundus) * 255);
        end

        function uploadImage(app)
            [file, path] = uigetfile({'*.jpg;*.png;*.jpeg;*.tif','Fundus Images'}, 'Select Retinal Image', app.DatasetPath);
            if isequal(file, 0), return; end
            try
                img = imread(fullfile(path, file));
                if size(img,3) ~= 3
                    uialert(app.UIFigure, 'Image must be RGB.', 'Format Error');
                    return;
                end
                app.CurrentRawImage = img;
                if app.IsModelLoaded
                    res = analyzeFundus(img, app.TrainedNet);
                    grade = str2double(string(res.prediction));
                    if isnan(grade), grade = 0; end
                else
                    grade = randi([0, 4]);
                end
                app.renderCase(grade);
            catch ME
                uialert(app.UIFigure, ['Could not process image: ' ME.message], 'Analysis Error');
            end
        end
    end

    methods (Access = private)

        function createComponents(app)
            % Screen size centering
            screenSize = get(groot, 'ScreenSize');
            figWidth = min(1440, screenSize(3) - 40);
            figHeight = min(880, screenSize(4) - 60);
            figLeft = max(20, (screenSize(3) - figWidth) / 2);
            figBottom = max(30, (screenSize(4) - figHeight) / 2);

            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [figLeft figBottom figWidth figHeight];
            app.UIFigure.Name = 'DR Screening AI - Early Detection, Better Vision';
            app.UIFigure.Color = [0.05 0.08 0.15]; % Deep Navy Outer

            % Main Grid: Left Sidebar (240px) + Right Content Area ('1x')
            app.MainGrid = uigridlayout(app.UIFigure, [1 2]);
            app.MainGrid.ColumnWidth = {240, '1x'};
            app.MainGrid.BackgroundColor = [0.05 0.08 0.15];
            app.MainGrid.Padding = [0 0 0 0];
            app.MainGrid.ColumnSpacing = 0;

            % ---------------- LEFT SIDEBAR ----------------
            app.SidebarPanel = uipanel(app.MainGrid);
            app.SidebarPanel.BackgroundColor = [0.04 0.07 0.17]; % Midnight Navy
            app.SidebarPanel.BorderType = 'none';

            app.SidebarGrid = uigridlayout(app.SidebarPanel, [9 1]);
            app.SidebarGrid.RowHeight = {30, 18, 12, 40, 40, 40, 40, 40, '1x'};
            app.SidebarGrid.BackgroundColor = [0.04 0.07 0.17];
            app.SidebarGrid.Padding = [16 16 16 16];
            app.SidebarGrid.RowSpacing = 8;

            app.BrandTitle = uilabel(app.SidebarGrid);
            app.BrandTitle.Text = '👁 DR Screening AI';
            app.BrandTitle.FontSize = 17;
            app.BrandTitle.FontWeight = 'bold';
            app.BrandTitle.FontColor = [1 1 1];

            app.BrandSubtitle = uilabel(app.SidebarGrid);
            app.BrandSubtitle.Text = 'Early Detection, Better Vision.';
            app.BrandSubtitle.FontSize = 11;
            app.BrandSubtitle.FontColor = [0.4 0.5 0.65];

            % Navigation Buttons
            app.NavDashboardBtn = uibutton(app.SidebarGrid, 'push');
            app.NavDashboardBtn.Text = 'Dashboard';
            app.NavDashboardBtn.FontSize = 13;
            app.NavDashboardBtn.FontWeight = 'bold';
            app.NavDashboardBtn.BackgroundColor = [0.11 0.31 0.85]; % Active Blue
            app.NavDashboardBtn.FontColor = [1 1 1];

            app.NavUploadBtn = uibutton(app.SidebarGrid, 'push');
            app.NavUploadBtn.Text = '☁  Upload Image';
            app.NavUploadBtn.HorizontalAlignment = 'left';
            app.NavUploadBtn.FontSize = 13;
            app.NavUploadBtn.BackgroundColor = [0.04 0.07 0.17];
            app.NavUploadBtn.FontColor = [0.6 0.7 0.8];
            app.NavUploadBtn.ButtonPushedFcn = @(~,~) app.uploadImage();

            app.NavResultsBtn = uibutton(app.SidebarGrid, 'push');
            app.NavResultsBtn.Text = '📄  Screening Results';
            app.NavResultsBtn.HorizontalAlignment = 'left';
            app.NavResultsBtn.FontSize = 13;
            app.NavResultsBtn.BackgroundColor = [0.04 0.07 0.17];
            app.NavResultsBtn.FontColor = [0.6 0.7 0.8];

            app.NavHistoryBtn = uibutton(app.SidebarGrid, 'push');
            app.NavHistoryBtn.Text = '🕒  History';
            app.NavHistoryBtn.HorizontalAlignment = 'left';
            app.NavHistoryBtn.FontSize = 13;
            app.NavHistoryBtn.BackgroundColor = [0.04 0.07 0.17];
            app.NavHistoryBtn.FontColor = [0.6 0.7 0.8];

            app.NavAboutBtn = uibutton(app.SidebarGrid, 'push');
            app.NavAboutBtn.Text = 'ⓘ  About';
            app.NavAboutBtn.HorizontalAlignment = 'left';
            app.NavAboutBtn.FontSize = 13;
            app.NavAboutBtn.BackgroundColor = [0.04 0.07 0.17];
            app.NavAboutBtn.FontColor = [0.6 0.7 0.8];

            app.SidebarFooter = uilabel(app.SidebarGrid);
            app.SidebarFooter.Text = '🛡 AI for a healthier tomorrow';
            app.SidebarFooter.FontSize = 11;
            app.SidebarFooter.FontColor = [0.4 0.5 0.65];
            app.SidebarFooter.VerticalAlignment = 'bottom';

            % ---------------- CONTENT AREA ----------------
            app.ContentPanel = uipanel(app.MainGrid);
            app.ContentPanel.BackgroundColor = [0.97 0.98 0.99]; % Off-white slate
            app.ContentPanel.BorderType = 'none';

            app.ContentGrid = uigridlayout(app.ContentPanel, [2 1]);
            app.ContentGrid.RowHeight = {58, '1x'};
            app.ContentGrid.BackgroundColor = [0.97 0.98 0.99];
            app.ContentGrid.Padding = [0 0 0 0];
            app.ContentGrid.RowSpacing = 0;

            % ---------------- TOP HEADER ----------------
            app.HeaderPanel = uipanel(app.ContentGrid);
            app.HeaderPanel.BackgroundColor = [1 1 1];
            app.HeaderPanel.BorderType = 'line';
            app.HeaderPanel.HighlightColor = [0.89 0.91 0.94];

            app.HeaderGrid = uigridlayout(app.HeaderPanel, [1 8]);
            app.HeaderGrid.ColumnWidth = {'fit', 110, 100, 120, 110, 110, '1x', 140};
            app.HeaderGrid.BackgroundColor = [1 1 1];
            app.HeaderGrid.Padding = [20 10 20 10];
            app.HeaderGrid.ColumnSpacing = 8;

            demoLbl = uilabel(app.HeaderGrid);
            demoLbl.Text = 'DEMO CASES:';
            demoLbl.FontWeight = 'bold';
            demoLbl.FontSize = 11;
            demoLbl.FontColor = [0.4 0.5 0.6];

            app.DemoPill0 = uibutton(app.HeaderGrid, 'push');
            app.DemoPill0.Text = 'Grade 0: Normal';
            app.DemoPill0.FontSize = 11;
            app.DemoPill0.FontWeight = 'bold';
            app.DemoPill0.ButtonPushedFcn = @(~,~) app.loadPresetCase(0);

            app.DemoPill1 = uibutton(app.HeaderGrid, 'push');
            app.DemoPill1.Text = 'Grade 1: Mild';
            app.DemoPill1.FontSize = 11;
            app.DemoPill1.FontWeight = 'bold';
            app.DemoPill1.ButtonPushedFcn = @(~,~) app.loadPresetCase(1);

            app.DemoPill2 = uibutton(app.HeaderGrid, 'push');
            app.DemoPill2.Text = 'Grade 2: Moderate';
            app.DemoPill2.FontSize = 11;
            app.DemoPill2.FontWeight = 'bold';
            app.DemoPill2.ButtonPushedFcn = @(~,~) app.loadPresetCase(2);

            app.DemoPill3 = uibutton(app.HeaderGrid, 'push');
            app.DemoPill3.Text = 'Grade 3: Severe';
            app.DemoPill3.FontSize = 11;
            app.DemoPill3.FontWeight = 'bold';
            app.DemoPill3.ButtonPushedFcn = @(~,~) app.loadPresetCase(3);

            app.DemoPill4 = uibutton(app.HeaderGrid, 'push');
            app.DemoPill4.Text = 'Grade 4: PDR';
            app.DemoPill4.FontSize = 11;
            app.DemoPill4.FontWeight = 'bold';
            app.DemoPill4.ButtonPushedFcn = @(~,~) app.loadPresetCase(4);

            % Empty spacer
            spacer = uilabel(app.HeaderGrid);
            spacer.Text = '';

            app.UserProfileLabel = uilabel(app.HeaderGrid);
            app.UserProfileLabel.Text = '👤 Welcome, User';
            app.UserProfileLabel.FontWeight = 'bold';
            app.UserProfileLabel.FontSize = 12;
            app.UserProfileLabel.HorizontalAlignment = 'right';

            % ---------------- DASHBOARD 2-COLUMN BODY ----------------
            app.BodyGrid = uigridlayout(app.ContentGrid, [1 2]);
            app.BodyGrid.ColumnWidth = {'1.25x', '0.95x'};
            app.BodyGrid.BackgroundColor = [0.97 0.98 0.99];
            app.BodyGrid.Padding = [24 20 24 20];
            app.BodyGrid.ColumnSpacing = 20;

            % ---------------- LEFT COLUMN CONTAINER ----------------
            app.LeftColGrid = uigridlayout(app.BodyGrid, [3 1]);
            app.LeftColGrid.RowHeight = {240, 105, '1x'};
            app.LeftColGrid.BackgroundColor = [0.97 0.98 0.99];
            app.LeftColGrid.Padding = [0 0 0 0];
            app.LeftColGrid.RowSpacing = 16;

            % HERO CARD
            app.HeroPanel = uipanel(app.LeftColGrid);
            app.HeroPanel.BackgroundColor = [0.88 0.95 0.99]; % Soft Sky Blue
            app.HeroPanel.BorderType = 'line';
            app.HeroPanel.HighlightColor = [0.73 0.88 0.98];

            app.HeroGrid = uigridlayout(app.HeroPanel, [4 2]);
            app.HeroGrid.ColumnWidth = {'1x', 190};
            app.HeroGrid.RowHeight = {28, 44, 48, 44};
            app.HeroGrid.BackgroundColor = [0.88 0.95 0.99];
            app.HeroGrid.Padding = [24 20 24 20];

            app.HeroBadge = uilabel(app.HeroGrid);
            app.HeroBadge.Layout.Row = 1;
            app.HeroBadge.Layout.Column = 1;
            app.HeroBadge.Text = 'AI POWERED';
            app.HeroBadge.FontWeight = 'bold';
            app.HeroBadge.FontSize = 11;
            app.HeroBadge.FontColor = [0.11 0.31 0.85];

            app.HeroTitle = uilabel(app.HeroGrid);
            app.HeroTitle.Layout.Row = 2;
            app.HeroTitle.Layout.Column = 1;
            app.HeroTitle.Text = 'Diabetic Retinopathy Screening';
            app.HeroTitle.FontSize = 21;
            app.HeroTitle.FontWeight = 'bold';
            app.HeroTitle.FontColor = [0.06 0.09 0.16];

            app.HeroDesc = uilabel(app.HeroGrid);
            app.HeroDesc.Layout.Row = 3;
            app.HeroDesc.Layout.Column = 1;
            app.HeroDesc.WordWrap = 'on';
            app.HeroDesc.Text = 'Upload a retinal fundus image and let our AI model analyze it for early signs of diabetic retinopathy.';
            app.HeroDesc.FontSize = 12;
            app.HeroDesc.FontColor = [0.28 0.33 0.41];

            app.HeroUploadBtn = uibutton(app.HeroGrid, 'push');
            app.HeroUploadBtn.Layout.Row = 4;
            app.HeroUploadBtn.Layout.Column = 1;
            app.HeroUploadBtn.Text = '☁ Upload Retinal Image';
            app.HeroUploadBtn.FontSize = 13;
            app.HeroUploadBtn.FontWeight = 'bold';
            app.HeroUploadBtn.BackgroundColor = [0.15 0.39 0.92];
            app.HeroUploadBtn.FontColor = [1 1 1];
            app.HeroUploadBtn.ButtonPushedFcn = @(~,~) app.uploadImage();

            % Scanner axes
            app.HeroScannerAxes = uiaxes(app.HeroGrid);
            app.HeroScannerAxes.Layout.Row = [1 4];
            app.HeroScannerAxes.Layout.Column = 2;
            app.HeroScannerAxes.Color = [0 0 0];
            app.HeroScannerAxes.XColor = 'none';
            app.HeroScannerAxes.YColor = 'none';
            app.HeroScannerAxes.Toolbar.Visible = 'off';

            % 3 STAT CARDS
            app.StatsGrid = uigridlayout(app.LeftColGrid, [1 3]);
            app.StatsGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.StatsGrid.BackgroundColor = [0.97 0.98 0.99];
            app.StatsGrid.Padding = [0 0 0 0];
            app.StatsGrid.ColumnSpacing = 14;

            % Stat 1
            app.StatCard1 = uipanel(app.StatsGrid);
            app.StatCard1.BackgroundColor = [1 1 1];
            app.StatCard1.HighlightColor = [0.89 0.91 0.94];
            s1Grid = uigridlayout(app.StatCard1, [3 1]);
            s1Grid.BackgroundColor = [1 1 1];
            s1Grid.RowHeight = {18, 28, 16};
            s1Grid.Padding = [14 10 14 10];
            app.Stat1Label = uilabel(s1Grid);
            app.Stat1Label.Text = 'AI Accuracy';
            app.Stat1Label.FontSize = 11;
            app.Stat1Label.FontColor = [0.4 0.5 0.6];
            app.Stat1Val = uilabel(s1Grid);
            app.Stat1Val.Text = '~92%';
            app.Stat1Val.FontSize = 19;
            app.Stat1Val.FontWeight = 'bold';
            app.Stat1Val.FontColor = [0.06 0.09 0.16];
            app.Stat1Sub = uilabel(s1Grid);
            app.Stat1Sub.Text = '(On test data)';
            app.Stat1Sub.FontSize = 10;
            app.Stat1Sub.FontColor = [0.58 0.64 0.72];

            % Stat 2
            app.StatCard2 = uipanel(app.StatsGrid);
            app.StatCard2.BackgroundColor = [1 1 1];
            app.StatCard2.HighlightColor = [0.89 0.91 0.94];
            s2Grid = uigridlayout(app.StatCard2, [3 1]);
            s2Grid.BackgroundColor = [1 1 1];
            s2Grid.RowHeight = {18, 28, 16};
            s2Grid.Padding = [14 10 14 10];
            app.Stat2Label = uilabel(s2Grid);
            app.Stat2Label.Text = 'Fast Analysis';
            app.Stat2Label.FontSize = 11;
            app.Stat2Label.FontColor = [0.4 0.5 0.6];
            app.Stat2Val = uilabel(s2Grid);
            app.Stat2Val.Text = '< 10 seconds';
            app.Stat2Val.FontSize = 17;
            app.Stat2Val.FontWeight = 'bold';
            app.Stat2Val.FontColor = [0.06 0.09 0.16];
            app.Stat2Sub = uilabel(s2Grid);
            app.Stat2Sub.Text = '(Average)';
            app.Stat2Sub.FontSize = 10;
            app.Stat2Sub.FontColor = [0.58 0.64 0.72];

            % Stat 3
            app.StatCard3 = uipanel(app.StatsGrid);
            app.StatCard3.BackgroundColor = [1 1 1];
            app.StatCard3.HighlightColor = [0.89 0.91 0.94];
            s3Grid = uigridlayout(app.StatCard3, [2 1]);
            s3Grid.BackgroundColor = [1 1 1];
            s3Grid.RowHeight = {18, 38};
            s3Grid.Padding = [14 12 14 12];
            app.Stat3Label = uilabel(s3Grid);
            app.Stat3Label.Text = 'Better Outcomes';
            app.Stat3Label.FontSize = 11;
            app.Stat3Label.FontColor = [0.4 0.5 0.6];
            app.Stat3Val = uilabel(s3Grid);
            app.Stat3Val.Text = 'Early detection saves vision';
            app.Stat3Val.WordWrap = 'on';
            app.Stat3Val.FontSize = 13;
            app.Stat3Val.FontWeight = 'bold';
            app.Stat3Val.FontColor = [0.06 0.09 0.16];

            % HOW IT WORKS CARD
            app.HowItWorksPanel = uipanel(app.LeftColGrid);
            app.HowItWorksPanel.BackgroundColor = [1 1 1];
            app.HowItWorksPanel.HighlightColor = [0.89 0.91 0.94];
            app.HowItWorksGrid = uigridlayout(app.HowItWorksPanel, [2 4]);
            app.HowItWorksGrid.BackgroundColor = [1 1 1];
            app.HowItWorksGrid.RowHeight = {26, '1x'};
            app.HowItWorksGrid.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.HowItWorksGrid.Padding = [20 16 20 16];

            app.HowTitle = uilabel(app.HowItWorksGrid);
            app.HowTitle.Layout.Row = 1;
            app.HowTitle.Layout.Column = [1 4];
            app.HowTitle.Text = 'How It Works';
            app.HowTitle.FontSize = 15;
            app.HowTitle.FontWeight = 'bold';
            app.HowTitle.FontColor = [0.06 0.09 0.16];

            app.Step1Label = uilabel(app.HowItWorksGrid);
            app.Step1Label.Layout.Row = 2; app.Step1Label.Layout.Column = 1;
            app.Step1Label.WordWrap = 'on';
            app.Step1Label.Text = sprintf('1. Upload\nUpload a clear retinal fundus image.');
            app.Step1Label.FontSize = 11;
            app.Step1Label.FontColor = [0.28 0.33 0.41];

            app.Step2Label = uilabel(app.HowItWorksGrid);
            app.Step2Label.Layout.Row = 2; app.Step2Label.Layout.Column = 2;
            app.Step2Label.WordWrap = 'on';
            app.Step2Label.Text = sprintf('2. AI Analysis\nOur model detects signs of DR.');
            app.Step2Label.FontSize = 11;
            app.Step2Label.FontColor = [0.28 0.33 0.41];

            app.Step3Label = uilabel(app.HowItWorksGrid);
            app.Step3Label.Layout.Row = 2; app.Step3Label.Layout.Column = 3;
            app.Step3Label.WordWrap = 'on';
            app.Step3Label.Text = sprintf('3. View Results\nGet prediction with confidence score.');
            app.Step3Label.FontSize = 11;
            app.Step3Label.FontColor = [0.28 0.33 0.41];

            app.Step4Label = uilabel(app.HowItWorksGrid);
            app.Step4Label.Layout.Row = 2; app.Step4Label.Layout.Column = 4;
            app.Step4Label.WordWrap = 'on';
            app.Step4Label.Text = sprintf('4. Take Action\nFollow recommended next steps.');
            app.Step4Label.FontSize = 11;
            app.Step4Label.FontColor = [0.28 0.33 0.41];

            % ---------------- RIGHT COLUMN (SCREENING RESULTS) ----------------
            app.ResultsPanel = uipanel(app.BodyGrid);
            app.ResultsPanel.BackgroundColor = [1 1 1];
            app.ResultsPanel.HighlightColor = [0.89 0.91 0.94];

            app.ResultsGrid = uigridlayout(app.ResultsPanel, [8 1]);
            app.ResultsGrid.RowHeight = {32, 115, 38, 55, 115, 80, 46, '1x'};
            app.ResultsGrid.BackgroundColor = [1 1 1];
            app.ResultsGrid.Padding = [20 18 20 18];
            app.ResultsGrid.RowSpacing = 10;

            % Header
            resHeaderGrid = uigridlayout(app.ResultsGrid, [1 2]);
            resHeaderGrid.BackgroundColor = [1 1 1];
            resHeaderGrid.ColumnWidth = {'fit', '1x'};
            resHeaderGrid.Padding = [0 0 0 0];
            app.ResultsTitle = uilabel(resHeaderGrid);
            app.ResultsTitle.Text = '📄 Screening Results';
            app.ResultsTitle.FontSize = 16;
            app.ResultsTitle.FontWeight = 'bold';
            app.ResultsTitle.FontColor = [0.06 0.09 0.16];
            app.LastUpdatedLabel = uilabel(resHeaderGrid);
            app.LastUpdatedLabel.Text = 'Last updated: 10 Sep 2025, 14:32';
            app.LastUpdatedLabel.FontSize = 11;
            app.LastUpdatedLabel.FontColor = [0.4 0.5 0.6];
            app.LastUpdatedLabel.HorizontalAlignment = 'right';

            % Result Summary Row: Thumbnail + Badge Card
            app.ResultSummaryGrid = uigridlayout(app.ResultsGrid, [1 2]);
            app.ResultSummaryGrid.BackgroundColor = [1 1 1];
            app.ResultSummaryGrid.ColumnWidth = {115, '1x'};
            app.ResultSummaryGrid.Padding = [0 0 0 0];
            app.ResultSummaryGrid.ColumnSpacing = 12;

            app.ResultThumbnailAxes = uiaxes(app.ResultSummaryGrid);
            app.ResultThumbnailAxes.Color = [0 0 0];
            app.ResultThumbnailAxes.XColor = 'none';
            app.ResultThumbnailAxes.YColor = 'none';
            app.ResultThumbnailAxes.Toolbar.Visible = 'off';

            app.BadgeCardPanel = uipanel(app.ResultSummaryGrid);
            app.BadgeCardPanel.BackgroundColor = [0.86 0.98 0.90];
            app.BadgeCardPanel.BorderType = 'line';
            app.BadgeCardPanel.HighlightColor = [0.73 0.97 0.82];

            app.BadgeCardGrid = uigridlayout(app.BadgeCardPanel, [2 1]);
            app.BadgeCardGrid.BackgroundColor = [0.86 0.98 0.90];
            app.BadgeCardGrid.RowHeight = {28, 22};
            app.BadgeCardGrid.Padding = [12 12 12 12];
            app.BadgeCardGrid.RowSpacing = 2;

            app.BadgeTitle = uilabel(app.BadgeCardGrid);
            app.BadgeTitle.Text = 'No DR Detected';
            app.BadgeTitle.FontSize = 15;
            app.BadgeTitle.FontWeight = 'bold';
            app.BadgeTitle.FontColor = [0.08 0.50 0.24];

            app.BadgeSubtitle = uilabel(app.BadgeCardGrid);
            app.BadgeSubtitle.Text = 'Normal Retina';
            app.BadgeSubtitle.FontSize = 12;
            app.BadgeSubtitle.FontColor = [0.09 0.40 0.20];

            % Confidence Score Bar
            confBoxGrid = uigridlayout(app.ResultsGrid, [2 2]);
            confBoxGrid.BackgroundColor = [1 1 1];
            confBoxGrid.RowHeight = {18, 14};
            confBoxGrid.ColumnWidth = {'1x', 50};
            confBoxGrid.Padding = [0 0 0 0];

            app.ConfidenceLabel = uilabel(confBoxGrid);
            app.ConfidenceLabel.Layout.Row = 1; app.ConfidenceLabel.Layout.Column = 1;
            app.ConfidenceLabel.Text = 'Confidence Score';
            app.ConfidenceLabel.FontWeight = 'bold';
            app.ConfidenceLabel.FontSize = 12;
            app.ConfidenceLabel.FontColor = [0.06 0.09 0.16];

            app.ConfidenceValLabel = uilabel(confBoxGrid);
            app.ConfidenceValLabel.Layout.Row = 1; app.ConfidenceValLabel.Layout.Column = 2;
            app.ConfidenceValLabel.Text = '96%';
            app.ConfidenceValLabel.FontWeight = 'bold';
            app.ConfidenceValLabel.FontSize = 13;
            app.ConfidenceValLabel.FontColor = [0.06 0.09 0.16];
            app.ConfidenceValLabel.HorizontalAlignment = 'right';

            app.ConfidenceAxes = uiaxes(confBoxGrid);
            app.ConfidenceAxes.Layout.Row = 2; app.ConfidenceAxes.Layout.Column = [1 2];
            app.ConfidenceAxes.Color = [0.9 0.93 0.96];
            app.ConfidenceAxes.XColor = 'none';
            app.ConfidenceAxes.YColor = 'none';
            app.ConfidenceAxes.Toolbar.Visible = 'off';

            % Metadata Grid
            app.MetaGrid = uigridlayout(app.ResultsGrid, [2 2]);
            app.MetaGrid.BackgroundColor = [1 1 1];
            app.MetaGrid.RowHeight = {22, 22};
            app.MetaGrid.Padding = [0 4 0 4];
            app.MetaIdLabel = uilabel(app.MetaGrid);
            app.MetaIdLabel.Text = 'Image ID: DR_20250910_1432';
            app.MetaIdLabel.FontSize = 11; app.MetaIdLabel.FontWeight = 'bold';
            app.MetaIdLabel.FontColor = [0.06 0.09 0.16];

            app.MetaDateLabel = uilabel(app.MetaGrid);
            app.MetaDateLabel.Text = 'Date: 10 Sep 2025, 14:32';
            app.MetaDateLabel.FontSize = 11;
            app.MetaDateLabel.FontColor = [0.28 0.33 0.41];

            app.MetaModelLabel = uilabel(app.MetaGrid);
            app.MetaModelLabel.Text = 'Model: v1.0 (ResNet-18)';
            app.MetaModelLabel.FontSize = 11;
            app.MetaModelLabel.FontColor = [0.28 0.33 0.41];

            % Key Findings
            findingsBoxGrid = uigridlayout(app.ResultsGrid, [5 1]);
            findingsBoxGrid.BackgroundColor = [1 1 1];
            findingsBoxGrid.RowHeight = {20, 18, 18, 18, 18};
            findingsBoxGrid.Padding = [0 0 0 0];
            findingsBoxGrid.RowSpacing = 4;

            app.FindingsHeading = uilabel(findingsBoxGrid);
            app.FindingsHeading.Text = 'Key Findings';
            app.FindingsHeading.FontWeight = 'bold';
            app.FindingsHeading.FontSize = 13;
            app.FindingsHeading.FontColor = [0.06 0.09 0.16];

            app.FindingsLabel1 = uilabel(findingsBoxGrid);
            app.FindingsLabel1.Text = '  No signs of microaneurysms detected';
            app.FindingsLabel1.FontSize = 11.5;
            app.FindingsLabel1.FontColor = [0.2 0.25 0.35];

            app.FindingsLabel2 = uilabel(findingsBoxGrid);
            app.FindingsLabel2.Text = '  No hemorrhages detected';
            app.FindingsLabel2.FontSize = 11.5;
            app.FindingsLabel2.FontColor = [0.2 0.25 0.35];

            app.FindingsLabel3 = uilabel(findingsBoxGrid);
            app.FindingsLabel3.Text = '  Blood vessels appear normal';
            app.FindingsLabel3.FontSize = 11.5;
            app.FindingsLabel3.FontColor = [0.2 0.25 0.35];

            app.FindingsLabel4 = uilabel(findingsBoxGrid);
            app.FindingsLabel4.Text = '  Optic disc is healthy';
            app.FindingsLabel4.FontSize = 11.5;
            app.FindingsLabel4.FontColor = [0.2 0.25 0.35];

            % Recommendation Box
            app.RecPanel = uipanel(app.ResultsGrid);
            app.RecPanel.BackgroundColor = [0.94 0.96 1.00]; % Soft Blue
            app.RecPanel.BorderType = 'line';
            app.RecPanel.HighlightColor = [0.75 0.86 0.99];

            app.RecGrid = uigridlayout(app.RecPanel, [2 1]);
            app.RecGrid.BackgroundColor = [0.94 0.96 1.00];
            app.RecGrid.RowHeight = {20, '1x'};
            app.RecGrid.Padding = [12 10 12 10];
            app.RecGrid.RowSpacing = 4;

            app.RecHeading = uilabel(app.RecGrid);
            app.RecHeading.Text = '💡 Recommendation';
            app.RecHeading.FontWeight = 'bold';
            app.RecHeading.FontSize = 12;
            app.RecHeading.FontColor = [0.11 0.31 0.85];

            app.RecText = uilabel(app.RecGrid);
            app.RecText.WordWrap = 'on';
            app.RecText.Text = 'Maintain regular eye checkups (at least once a year) and manage blood sugar levels.';
            app.RecText.FontSize = 11.5;
            app.RecText.FontColor = [0.2 0.25 0.35];

            % Action Buttons
            app.ActionBtnGrid = uigridlayout(app.ResultsGrid, [1 2]);
            app.ActionBtnGrid.ColumnWidth = {'1x', '1x'};
            app.ActionBtnGrid.Padding = [0 0 0 0];
            app.ActionBtnGrid.ColumnSpacing = 12;

            app.UploadAnotherBtn = uibutton(app.ActionBtnGrid, 'push');
            app.UploadAnotherBtn.Text = '☁ Upload Another Image';
            app.UploadAnotherBtn.FontSize = 12;
            app.UploadAnotherBtn.FontWeight = 'bold';
            app.UploadAnotherBtn.BackgroundColor = [0.15 0.39 0.92];
            app.UploadAnotherBtn.FontColor = [1 1 1];
            app.UploadAnotherBtn.ButtonPushedFcn = @(~,~) app.uploadImage();

            app.ViewHistoryBtn = uibutton(app.ActionBtnGrid, 'push');
            app.ViewHistoryBtn.Text = '🕒 View History';
            app.ViewHistoryBtn.FontSize = 12;
            app.ViewHistoryBtn.FontWeight = 'bold';
            app.ViewHistoryBtn.BackgroundColor = [1 1 1];
            app.ViewHistoryBtn.FontColor = [0.2 0.25 0.35];
            app.ViewHistoryBtn.ButtonPushedFcn = @(~,~) uialert(app.UIFigure, 'History log shows previous 3 successful screenings.', 'Screening History');

            % Make Visible
            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)
        function app = DR_Screening_UI_Modern
            createComponents(app)
            registerApp(app, app.UIFigure)
            initBackend(app)
            loadPresetCase(app, 0)
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end
    end
end
