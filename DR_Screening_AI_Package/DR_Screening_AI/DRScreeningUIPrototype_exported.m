classdef DRScreeningUIPrototype_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        GridLayout           matlab.ui.container.GridLayout
        MainPanel            matlab.ui.container.Panel
        PredictionPanel      matlab.ui.container.Panel
        ReferableLabel       matlab.ui.control.Label
        SeverityLabel        matlab.ui.control.Label
        ConfidenceLabel      matlab.ui.control.Label
        DRGradeLabel         matlab.ui.control.Label
        StatusTextLabel      matlab.ui.control.Label
        AnalyzeButton        matlab.ui.control.Button
        ImagePanel           matlab.ui.container.Panel
        ClearButton          matlab.ui.control.Button
        UploadButton         matlab.ui.control.Button
        Image                matlab.ui.control.Image
        ImageTitleLabel      matlab.ui.control.Label
        SidebarPanel         matlab.ui.container.Panel
        SettingsButton       matlab.ui.control.Button
        ReportsButton        matlab.ui.control.Button
        UploadAnalyzeButton  matlab.ui.control.Button
        DashboardButton      matlab.ui.control.Button
        Headerpanel          matlab.ui.container.Panel
        StatusLabel          matlab.ui.control.Label
        SubtitleLabel        matlab.ui.control.Label
        TitleLabel           matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: UploadButton
        function UploadButtonPushed(app, event)
            [file,path] = uigetfile({'*.jpg;*.png;*.jpeg','Fundus Images'});

            if isequal(file,0)
                return;
            end

            img = imread(fullfile(path,file));

            app.Image.ImageSource = img;
            app.StatusTextLabel.Text = 'STATUS: IMAGE LOADED';
        end

        % Button pushed function: ClearButton
        function ClearButtonPushed(app, event)
             app.Image.ImageSource = '';
        end

        % Button pushed function: AnalyzeButton
        function AnalyzeButtonPushed(app, event)
             app.StatusTextLabel.Text = 'STATUS: ANALYZING...';
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1237 750];
            app.UIFigure.Name = 'MATLAB App';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x'};

            % Create Headerpanel
            app.Headerpanel = uipanel(app.GridLayout);
            app.Headerpanel.Layout.Row = 1;
            app.Headerpanel.Layout.Column = [1 3];

            % Create TitleLabel
            app.TitleLabel = uilabel(app.Headerpanel);
            app.TitleLabel.FontSize = 18;
            app.TitleLabel.FontWeight = 'bold';
            app.TitleLabel.Position = [1 1 1179 62];
            app.TitleLabel.Text = 'RETINA-AI';

            % Create SubtitleLabel
            app.SubtitleLabel = uilabel(app.Headerpanel);
            app.SubtitleLabel.HorizontalAlignment = 'right';
            app.SubtitleLabel.FontSize = 18;
            app.SubtitleLabel.FontWeight = 'bold';
            app.SubtitleLabel.Position = [353 13 472 34];
            app.SubtitleLabel.Text = 'Explainable AI-Based Diabetic Retinopathy Screening';

            % Create StatusLabel
            app.StatusLabel = uilabel(app.Headerpanel);
            app.StatusLabel.HorizontalAlignment = 'right';
            app.StatusLabel.FontSize = 14;
            app.StatusLabel.FontWeight = 'bold';
            app.StatusLabel.Position = [970 11 162 33];
            app.StatusLabel.Text = '● SYSTEM READY';

            % Create SidebarPanel
            app.SidebarPanel = uipanel(app.GridLayout);
            app.SidebarPanel.Layout.Row = [2 6];
            app.SidebarPanel.Layout.Column = 1;
            app.SidebarPanel.FontAngle = 'italic';
            app.SidebarPanel.FontWeight = 'bold';
            app.SidebarPanel.FontSize = 36;

            % Create DashboardButton
            app.DashboardButton = uibutton(app.SidebarPanel, 'push');
            app.DashboardButton.FontSize = 21;
            app.DashboardButton.FontWeight = 'bold';
            app.DashboardButton.FontAngle = 'italic';
            app.DashboardButton.Position = [102 495 159 46];
            app.DashboardButton.Text = 'Dashboard';

            % Create UploadAnalyzeButton
            app.UploadAnalyzeButton = uibutton(app.SidebarPanel, 'push');
            app.UploadAnalyzeButton.FontSize = 21;
            app.UploadAnalyzeButton.FontWeight = 'bold';
            app.UploadAnalyzeButton.FontAngle = 'italic';
            app.UploadAnalyzeButton.Position = [86 387 192 53];
            app.UploadAnalyzeButton.Text = 'Upload & Analyze';

            % Create ReportsButton
            app.ReportsButton = uibutton(app.SidebarPanel, 'push');
            app.ReportsButton.FontSize = 21;
            app.ReportsButton.FontWeight = 'bold';
            app.ReportsButton.FontAngle = 'italic';
            app.ReportsButton.Position = [102 278 159 50];
            app.ReportsButton.Text = 'Reports';

            % Create SettingsButton
            app.SettingsButton = uibutton(app.SidebarPanel, 'push');
            app.SettingsButton.FontSize = 21;
            app.SettingsButton.FontWeight = 'bold';
            app.SettingsButton.FontAngle = 'italic';
            app.SettingsButton.Position = [102 144 159 87];
            app.SettingsButton.Text = 'Settings';

            % Create MainPanel
            app.MainPanel = uipanel(app.GridLayout);
            app.MainPanel.Layout.Row = [2 6];
            app.MainPanel.Layout.Column = [2 3];

            % Create ImagePanel
            app.ImagePanel = uipanel(app.MainPanel);
            app.ImagePanel.Position = [11 301 353 299];

            % Create ImageTitleLabel
            app.ImageTitleLabel = uilabel(app.ImagePanel);
            app.ImageTitleLabel.HorizontalAlignment = 'center';
            app.ImageTitleLabel.FontSize = 14;
            app.ImageTitleLabel.FontWeight = 'bold';
            app.ImageTitleLabel.Position = [97 254 202 31];
            app.ImageTitleLabel.Text = 'ORIGINAL FUNDUS IMAGE';

            % Create Image
            app.Image = uiimage(app.ImagePanel);
            app.Image.Position = [112 83 172 172];

            % Create UploadButton
            app.UploadButton = uibutton(app.ImagePanel, 'push');
            app.UploadButton.ButtonPushedFcn = createCallbackFcn(app, @UploadButtonPushed, true);
            app.UploadButton.FontWeight = 'bold';
            app.UploadButton.Position = [128 50 140 30];
            app.UploadButton.Text = 'Upload Fundus Image';

            % Create ClearButton
            app.ClearButton = uibutton(app.ImagePanel, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.Position = [148 16 100 22];
            app.ClearButton.Text = 'Clear';

            % Create AnalyzeButton
            app.AnalyzeButton = uibutton(app.MainPanel, 'push');
            app.AnalyzeButton.ButtonPushedFcn = createCallbackFcn(app, @AnalyzeButtonPushed, true);
            app.AnalyzeButton.Position = [155 268 103 22];
            app.AnalyzeButton.Text = '  Analyze Image ';

            % Create StatusTextLabel
            app.StatusTextLabel = uilabel(app.MainPanel);
            app.StatusTextLabel.Position = [150 1 99 22];
            app.StatusTextLabel.Text = 'STATUS: READY';

            % Create PredictionPanel
            app.PredictionPanel = uipanel(app.MainPanel);
            app.PredictionPanel.TitlePosition = 'centertop';
            app.PredictionPanel.Title = 'AI SCREENING RESULT';
            app.PredictionPanel.Position = [77 33 260 221];

            % Create DRGradeLabel
            app.DRGradeLabel = uilabel(app.PredictionPanel);
            app.DRGradeLabel.FontName = 'Bodoni MT Poster Compressed';
            app.DRGradeLabel.FontWeight = 'bold';
            app.DRGradeLabel.Position = [18 164 64 22];
            app.DRGradeLabel.Text = 'DR Grade:';

            % Create ConfidenceLabel
            app.ConfidenceLabel = uilabel(app.PredictionPanel);
            app.ConfidenceLabel.FontName = 'Franklin Gothic Demi';
            app.ConfidenceLabel.FontWeight = 'bold';
            app.ConfidenceLabel.Position = [15 111 74 22];
            app.ConfidenceLabel.Text = 'Confidence:';

            % Create SeverityLabel
            app.SeverityLabel = uilabel(app.PredictionPanel);
            app.SeverityLabel.FontName = 'Franklin Gothic Demi';
            app.SeverityLabel.FontWeight = 'bold';
            app.SeverityLabel.Position = [15 42 90 57];
            app.SeverityLabel.Text = 'Severity:';

            % Create ReferableLabel
            app.ReferableLabel = uilabel(app.PredictionPanel);
            app.ReferableLabel.FontName = 'Franklin Gothic Demi';
            app.ReferableLabel.FontWeight = 'bold';
            app.ReferableLabel.Position = [18 15 74 29];
            app.ReferableLabel.Text = 'Referable:';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = DRScreeningUIPrototype_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end