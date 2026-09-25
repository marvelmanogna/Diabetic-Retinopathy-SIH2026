from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware

import os
import uuid

from matlab_service import analyze_image


app = FastAPI(
    title="DR Screening SIH API",
    description="Explainable AI Diabetic Retinopathy Screening API",
    version="1.0"
)


# --------------------------------------------------
# CORS
# --------------------------------------------------

app.add_middleware(
    CORSMiddleware,

    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173"
    ],

    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# --------------------------------------------------
# Folders
# --------------------------------------------------

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

UPLOAD_DIR = os.path.join(BASE_DIR, "uploads")
RESULT_DIR = os.path.join(BASE_DIR, "results")

os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(RESULT_DIR, exist_ok=True)


# --------------------------------------------------
# Home
# --------------------------------------------------

@app.get("/")
def root():

    return {
        "message": "DR Screening SIH API is running"
    }


# --------------------------------------------------
# Health Check
# --------------------------------------------------

@app.get("/health")
def health():

    return {
        "status": "ok"
    }


# --------------------------------------------------
# Analyze Fundus Image
# --------------------------------------------------

@app.post("/analyze")
async def analyze(file: UploadFile = File(...)):

    extension = os.path.splitext(file.filename)[1].lower()

    if extension not in [".jpg", ".jpeg", ".png"]:

        return {
            "error": "Only JPG, JPEG and PNG images are supported."
        }


    unique_id = str(uuid.uuid4())

    image_path = os.path.join(
        UPLOAD_DIR,
        unique_id + extension
    )

    output_dir = os.path.join(
        RESULT_DIR,
        unique_id
    )


    # Save uploaded image
    contents = await file.read()

    with open(image_path, "wb") as f:

        f.write(contents)


    try:

        result = analyze_image(
            image_path,
            output_dir
        )

        return result


    except Exception as e:

        return {
            "error": str(e)
        }