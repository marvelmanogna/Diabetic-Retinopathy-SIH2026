% RUN_RETINA_AI
% Master Launcher for Diabetic Retinopathy Screening System (SIH 2026)
%
% USAGE:
%   run_retina_ai           - Launches the Modern Clinical UI (matching requested dashboard)
%   run_retina_ai('modern') - Launches the Modern Clinical UI
%   run_retina_ai('web')    - Opens the interactive Web Dashboard in default browser
%   run_retina_ai('pro')    - Launches Retina-AI Pro Diagnostic Workstation (multi-viewport)

function app = run_retina_ai(mode)
    if nargin < 1
        mode = 'modern';
    end

    clc;
    fprintf('=========================================================\n');
    fprintf('   RETINA-AI: Diabetic Retinopathy Screening System     \n');
    fprintf('   Smart India Hackathon (SIH) 2026                     \n');
    fprintf('=========================================================\n\n');

    % Setup paths
    frontendPath = 'D:\SIH\frontend';
    backendPath = 'D:\SIH\DR_Screening_SIH';

    if exist(frontendPath, 'dir')
        addpath(frontendPath);
    end
    if exist(backendPath, 'dir')
        addpath(genpath(backendPath));
    end

    switch lower(mode)
        case {'web', 'html'}
            webUrl = 'http://localhost:8080/';
            localHtml = fullfile(frontendPath, 'web', 'index.html');
            fprintf('Launching Web Application Dashboard...\n');
            try
                web(webUrl, '-browser');
            catch
                web(localHtml, '-browser');
            end
            fprintf('Web Dashboard opened in browser: %s\n', webUrl);
            app = [];

        case {'pro', 'editor', 'advanced'}
            fprintf('Launching Retina-AI Pro Diagnostic Workstation...\n');
            app = DR_Screening_Pro_Editor;
            fprintf('Pro Workstation launched successfully!\n');

        otherwise % default 'modern'
            fprintf('Launching Modern Clinical Screening Dashboard...\n');
            app = DR_Screening_UI_Modern;
            fprintf('Modern Clinical Dashboard launched successfully!\n');
    end
end
