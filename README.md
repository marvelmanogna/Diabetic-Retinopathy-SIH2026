Explainable AI for Diabetic Retinopathy Screening in Rural India

An AI-assisted, quality-aware screening prototype for Diabetic Retinopathy (DR) designed for rural healthcare workflows.

Smart India Hackathon 2026 — Problem Statement 26038

Overview

Diabetic Retinopathy screening can be challenging in rural settings due to limited specialist availability, variations in fundus-image quality, and the difficulty of interpreting black-box AI predictions.

This project proposes a multi-stage explainable AI screening pipeline that:

Checks whether a fundus image is suitable for analysis
Enhances and standardizes the image
Classifies Diabetic Retinopathy into 5 severity levels (0–4)
Identifies referable DR (Grade ≥ 2)
Generates Grad-CAM visual explanations
Provides supporting retinal evidence such as vessel and optic-disc analysis
Keeps a human reviewer in the loop
Generates a screening report
Uses Simulink to model large-scale screening workflow and resource requirements

The system is intended as a research and screening-support prototype, not an autonomous medical diagnostic device.

System Pipeline
                FUNDUS IMAGE
                     │
                     ▼
        ┌─────────────────────────┐
        │   IMAGE QUALITY GATE     │
        │ Focus • Illumination     │
        │ Field of View • Quality  │
        └────────────┬────────────┘
                     │
          ┌──────────┴──────────┐
          │                     │
       Poor Image           Gradeable
          │                     │
          ▼                     ▼
      RECAPTURE        ┌──────────────────┐
                       │  PREPROCESSING    │
                       │ Crop • Resize     │
                       │ Normalization     │
                       │ CLAHE • Denoise  │
                       └────────┬─────────┘
                                │
                                ▼
                    ┌─────────────────────┐
                    │   DR CLASSIFIER     │
                    │     ResNet-18       │
                    │     Grades 0–4      │
                    └──────────┬──────────┘
                               │
             ┌─────────────────┼─────────────────┐
             ▼                 ▼                 ▼
        DR Prediction      Grad-CAM       Retinal Evidence
                           Explanation     • Vessels
                                           • Optic Disc
                                           • Lesion Candidates
                               │
                               ▼
                    ┌─────────────────────┐
                    │   HUMAN REVIEW      │
                    │ Accept / Override   │
                    └──────────┬──────────┘
                               │
                               ▼
                       SCREENING REPORT
                               │
                               ▼
                         SIMULINK MODEL
                    Workflow & Scalability
Key Features
1. Image Quality Assessment

Before classification, the system evaluates:

Brightness / illumination
Focus / blur
Retinal field of view

If the image fails the quality gate, the system returns a RECAPTURE recommendation instead of producing a forced prediction.

2. Image Preprocessing

The preprocessing pipeline includes:

Fundus cropping
Resizing to 224 × 224
Illumination normalization
CLAHE-based contrast enhancement
Gaussian denoising

A color-preserving preprocessing pipeline is used for the classification workflow.

3. Diabetic Retinopathy Classification

The prototype uses ResNet-18 transfer learning for five-class DR classification:

Grade	Severity
0	No DR
1	Mild DR
2	Moderate DR
3	Severe DR
4	Proliferative DR

Grades 2–4 are treated as referable DR for the prototype workflow.

4. Explainability

Grad-CAM is used to visualize regions that contributed strongly to the model prediction.

The system also provides supporting evidence through:

Retinal vessel segmentation
Candidate optic-disc detection
Candidate lesion regions

Grad-CAM highlights model-influential regions; it should not be interpreted as definitive proof of a particular lesion.

5. Human-in-the-Loop

The system is designed to support, rather than replace, clinical review.

A reviewer can:

Inspect the AI prediction
View the explainability output
Review supporting evidence
Accept the AI result
Override the predicted grade
Add reviewer notes
6. Screening Report

The generated report contains:

Image-quality information
DR grade
DR category
Model score
Referable status
Grad-CAM availability
Structural evidence
Human-review decision
Reviewer notes
7. Simulink Scalability Model

The project also models the screening workflow in Simulink:

Patient Arrival
      ↓
Image Acquisition
      ↓
AI Processing
      ↓
Screening Decision
      ↓
Specialist Review
      ↓
Referral / Follow-up

The model can be used to study:

Processing throughput
Review capacity
Queueing
Resource allocation
Large-scale screening scenarios
Technology Stack
AI / Image Processing
MATLAB R2026a
Deep Learning Toolbox
Image Processing Toolbox
Computer Vision Toolbox
Statistics and Machine Learning Toolbox
Simulink
ResNet-18
Grad-CAM
CLAHE
Application
React
Vite
FastAPI
Python
MATLAB Engine API for Python
Architecture
React Frontend
       │
       │ HTTP
       ▼
FastAPI Backend
       │
       │ MATLAB Engine API
       ▼
MATLAB Analysis Pipeline
       │
       ├── Quality Assessment
       ├── Preprocessing
       ├── DR Classification
       ├── Grad-CAM
       ├── Vessel Analysis
       ├── Optic Disc Detection
       └── Report Generation
Datasets

The project uses different datasets for different components:

Dataset	Intended Use
APTOS 2019	DR severity classification
IDRiD	Retinal lesion / DR-related analysis
DRIVE	Retinal vessel segmentation
Messidor-2	External evaluation

Large datasets and image archives should not be committed to this repository.

Project Structure
DR_Screening_SIH/
│
├── data/
│   └── APTOS/
│       ├── train.csv
│       └── train_images/
│
├── preprocessing/
│   ├── cropFundus.m
│   ├── normalizeIllumination.m
│   ├── applyCLAHE.m
│   ├── preprocessFundus.m
│   ├── preprocessFundusColor.m
│   └── processAPTOS.m
│
├── quality/
│   ├── assessQuality.m
│   └── testQuality.m
│
├── classification/
│   ├── loadAPTOS.m
│   ├── splitDataset.m
│   ├── createProcessedDatastore.m
│   │
│   ├── training/
│   │   └── trainDRModel.m
│   │
│   ├── prediction/
│   │   └── predictDR.m
│   │
│   └── evaluation/
│       ├── evaluateModel.m
│       └── evaluateReferableDR.m
│
├── segmentation/
│   ├── segmentVessels.m
│   └── detectOpticDisc.m
│
├── lesions/
│   └── detectLesionCandidates.m
│
├── explainability/
│   └── generateGradCAM.m
│
├── reports/
│   ├── humanReview.m
│   └── generateReport.m
│
├── backend/
│   ├── analyzeFundus.m
│   ├── analyzeFundusAPI.m
│   └── loadDRModel.m
│
├── simulink/
│   └── ...
│
├── app/
│   └── ...
│
├── results/
│   └── ...
│
└── README.md
Running the MATLAB Prototype

Open MATLAB and navigate to the project root.

Add the complete project to the MATLAB path:

addpath(genpath("D:\projects\SIH_2026\DR_Screening_SIH"));
Test image quality
cd quality
testQuality
Test preprocessing
cd preprocessing
testPreprocessing
Test the APTOS loader
cd classification
testLoadAPTOS
Train the DR model
cd classification/training
trainDRModel

The trained model is saved under:

results/model/drModel.mat
Evaluate the model
cd classification/evaluation
evaluateModel
evaluateReferableDR

Only use the resulting test-set metrics in reports or presentations once they have actually been measured.

Running the Web Application

The application uses:

DR_Screening_AI_Package/
│
├── DR_Screening_AI/    # React + Vite frontend
│
└── api/                # FastAPI backend
Backend
cd D:\projects\SIH_2026\DR_Screening_SIH\DR_Screening_AI_Package\api

Activate the virtual environment:

.\venv\Scripts\activate

Install dependencies:

pip install fastapi uvicorn python-multipart

Run:

python -m uvicorn main:app

Backend:

http://127.0.0.1:8000

API documentation:

http://127.0.0.1:8000/docs
Frontend
cd D:\projects\SIH_2026\DR_Screening_SIH\DR_Screening_AI_Package\DR_Screening_AI
npm install
npm run dev

Frontend:

http://localhost:5173
Model Training

The classification pipeline uses transfer learning with ResNet-18.

Current prototype training configuration includes:

Optimizer: Adam
Initial learning rate: 1e-4
Epochs: 8
Batch size: 32
Input size: 224 × 224 × 3
Data augmentation: translation + horizontal reflection

The model is trained using MATLAB's modern trainnet workflow.

Current Prototype Status

The project is being developed as a working SIH prototype.

Implemented / Prototype Modules
 APTOS dataset loading
 Fundus preprocessing
 Image-quality assessment
 CLAHE enhancement
 DR classification pipeline
 ResNet-18 training
 DR Grade 0–4 prediction
 Referable DR logic
 Grad-CAM
 Candidate vessel segmentation
 Candidate optic-disc detection
 Candidate lesion evidence
 Human-review workflow
 Screening report generation
 Simulink workflow modelling
 React frontend
 FastAPI integration architecture
Limitations

This repository represents a research/prototype implementation.

Important limitations include:

Image-quality thresholds are prototype thresholds and are not clinically validated.
Candidate lesion detection is not equivalent to clinically confirmed lesion detection.
Grad-CAM is an explainability technique, not a diagnostic confirmation mechanism.
Model performance depends on the dataset, preprocessing and evaluation split.
Dataset/domain differences may affect generalization to real-world cameras.
The prototype has not been presented as a clinically validated medical device.
Final sensitivity, specificity and other performance metrics should only be reported from a reproducible held-out evaluation.
Future Work

Planned improvements include:

More robust image-quality assessment
Better optic-disc and fovea localization
Dedicated lesion segmentation/detection models
Improved model calibration
External validation
Camera/domain-shift analysis
Edge/low-bandwidth deployment
More detailed Simulink resource modelling
Expanded clinical-review workflow
Deployment testing with real-world fundus cameras
Team

Smart India Hackathon 2026

Problem Statement: 26038
Title: Explainable AI for Diabetic Retinopathy Screening in Rural India

Disclaimer

This project is a research and educational prototype for AI-assisted screening support. It is not intended to replace qualified ophthalmologists or provide autonomous medical diagnosis. Results should be reviewed by an appropriate healthcare professional before clinical decisions are made.
