import matlab.engine
import json

PROJECT_ROOT = r"D:\projects\SIH_2026\DR_Screening_SIH"

eng = matlab.engine.start_matlab()

eng.addpath(
    eng.genpath(PROJECT_ROOT),
    nargout=0
)


def analyze_image(image_path, output_dir):

    json_text = eng.analyzeFundusAPI(
        image_path,
        output_dir,
        nargout=1
    )

    return json.loads(json_text)