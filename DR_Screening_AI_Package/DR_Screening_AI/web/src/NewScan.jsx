import { useState } from "react";

const API_URL = import.meta.env.VITE_API_URL;

function NewScan({ onAnalysisComplete }) {

    const [file, setFile] = useState(null);
    const [preview, setPreview] = useState(null);

    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");


    function handleFileChange(event) {

        const selectedFile = event.target.files[0];

        if (!selectedFile) {
            return;
        }

        setFile(selectedFile);

        setPreview(
            URL.createObjectURL(selectedFile)
        );

        setError("");
    }


    async function analyzeImage() {

        if (!file) {

            setError(
                "Please select a fundus image first."
            );

            return;
        }


        setLoading(true);
        setError("");


        const formData = new FormData();

        formData.append(
            "file",
            file
        );


        try {

            const response = await fetch(
                `${API_URL}/analyze`,
                {
                    method: "POST",
                    body: formData
                }
            );


            const data = await response.json();


            if (!response.ok || data.error) {

                throw new Error(
                    data.error ||
                    "Analysis failed."
                );

            }


            onAnalysisComplete(data);


        } catch (err) {

            setError(
                err.message
            );

        } finally {

            setLoading(false);

        }
    }


    return (

        <div>

            <h1>
                New DR Screening
            </h1>


            <input
                type="file"
                accept=".jpg,.jpeg,.png"
                onChange={handleFileChange}
            />


            {preview && (

                <div>

                    <h3>
                        Selected Image
                    </h3>

                    <img
                        src={preview}
                        alt="Fundus preview"
                        style={{
                            width: "400px"
                        }}
                    />

                </div>

            )}


            <br />


            <button
                onClick={analyzeImage}
                disabled={loading}
            >

                {loading
                    ? "Analyzing..."
                    : "Analyze Image"
                }

            </button>


            {error && (

                <p style={{
                    color: "red"
                }}>

                    {error}

                </p>

            )}

        </div>

    );
}


export default NewScan;