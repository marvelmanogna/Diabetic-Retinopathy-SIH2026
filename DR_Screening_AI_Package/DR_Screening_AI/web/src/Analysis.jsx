function Analysis({ result }) {

    if (!result) {

        return (
            <div>
                No analysis available.
            </div>
        );

    }


    if (result.status === "RECAPTURE") {

        return (

            <div>

                <h1>
                    Image Quality Problem
                </h1>

                <h2>
                    Please recapture the image
                </h2>

                <p>
                    {result.message}
                </p>

            </div>

        );

    }


    const originalImage =
        `data:image/png;base64,${result.originalImage}`;


    const processedImage =
        `data:image/png;base64,${result.processedImage}`;


    const gradCAM =
        `data:image/png;base64,${result.gradCAM}`;


    return (

        <div>

            <h1>
                DR Screening Result
            </h1>


            <hr />


            <h2>
                Classification
            </h2>


            <h3>
                Grade: {result.prediction.grade}
            </h3>


            <h3>
                {result.prediction.gradeName}
            </h3>


            <p>
                Model Score:
                {" "}
                {result.prediction.score.toFixed(4)}
            </p>


            <p>

                Referable DR:
                {" "}

                {result.prediction.referable
                    ? "YES"
                    : "NO"
                }

            </p>


            <hr />


            <h2>
                Image Quality
            </h2>


            <p>
                Status:
                {" "}
                {result.quality.status}
            </p>


            <p>
                Brightness:
                {" "}
                {result.quality.meanBrightness.toFixed(3)}
            </p>


            <p>
                Focus:
                {" "}
                {result.quality.focusScore.toFixed(5)}
            </p>


            <p>
                FOV:
                {" "}
                {result.quality.fovPercentage.toFixed(2)}%
            </p>


            <hr />


            <h2>
                Original Image
            </h2>

            <img
                src={originalImage}
                alt="Original fundus"
                style={{
                    width: "400px"
                }}
            />


            <h2>
                Processed Image
            </h2>

            <img
                src={processedImage}
                alt="Processed fundus"
                style={{
                    width: "400px"
                }}
            />


            <h2>
                AI Explanation — Grad-CAM
            </h2>

            <img
                src={gradCAM}
                alt="Grad-CAM"
                style={{
                    width: "400px"
                }}
            />

        </div>

    );
}


export default Analysis;