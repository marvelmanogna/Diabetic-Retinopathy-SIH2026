========================================================
   DR SCREENING AI - EARLY DETECTION, BETTER VISION
   Smart India Hackathon (SIH) 2026 Presentation Package
========================================================

WHAT IS IN THIS PACKAGE:
1. web/
   - Interactive modern clinical dashboard matching your reference design.
   - Works immediately in any web browser (Chrome, Edge, Firefox).
   - Includes 1-click clinical presets (Grade 0 to Grade 4), retinal scanner HUD, 
     accuracy metrics, checklist, and dynamic severity cards.
   - Simply double-click 'launch_web_dashboard.bat' or open 'web/index.html'.

2. DR_Screening_UI_Modern.m
   - Native MATLAB App Designer modern screening dashboard.
   - Directly integrated with team's ResNet-18 model (drResNet18.mat, analyzeFundus.m).

3. run_retina_ai.m
   - Quick 1-line launcher script for MATLAB.
   - Commands:
       run_retina_ai           -> Launches Modern UI
       run_retina_ai('web')    -> Opens Web App in browser
       run_retina_ai('pro')    -> Launches Advanced Pro Workstation

4. DR_Screening_Pro_Editor.m
   - Multi-viewport clinical diagnostic workstation with Grad-CAM, 
     vasculature segmentation, and lesion overlays.

5. modern_ui_preview.png
   - High-resolution screenshot preview of the modern clinical dashboard.

HOW TO RUN:
Option A: Web Dashboard (Zero installation needed)
  - Double-click 'launch_web_dashboard.bat' OR open 'web/index.html' in your browser.

Option B: In MATLAB
  1. Open MATLAB.
  2. Set your current folder to this folder.
  3. Type 'run_retina_ai' in the Command Window and hit Enter.
========================================================
