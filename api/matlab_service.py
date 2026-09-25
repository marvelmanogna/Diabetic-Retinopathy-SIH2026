import sys
import os
import matlab.engine


# =========================================================
# PATHS
# =========================================================

MATLAB_ROOT = r"C:\Program Files\MATLAB\R2026a"

PROJECT_ROOT = (
    r"D:\projects\SIH_2026\DR_Screening_SIH"
)


# =========================================================
# START MATLAB
# =========================================================

print("Starting MATLAB Engine...")

eng = matlab.engine.start_matlab()

print("MATLAB Engine started.")


# =========================================================
# LOAD YOUR SIH PROJECT
# =========================================================

eng.addpath(
    eng.genpath(PROJECT_ROOT),
    nargout=0
)

print("SIH MATLAB project loaded.")


# =========================================================
# TEST MATLAB
# =========================================================

def test_matlab():

    result = eng.which(
        "analyzeFundus"
    )

    print("analyzeFundus location:")
    print(result)

    return result
    }

def test_analyze_function():

    result = eng.which(
        "analyzeFundus"
    )

    print("analyzeFundus location:")
    print(result)

    return result