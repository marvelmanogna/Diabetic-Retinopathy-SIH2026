import { useState } from "react";

import NewScan from "./pages/NewScan";
import Analysis from "./pages/Analysis";


function App() {

    const [page, setPage] =
        useState("newscan");


    const [analysisResult, setAnalysisResult] =
        useState(null);


    function handleAnalysisComplete(result) {

        setAnalysisResult(result);

        setPage("analysis");

    }


    return (

        <div>

            <nav>

                <button
                    onClick={() =>
                        setPage("newscan")
                    }
                >
                    New Scan
                </button>


                <button
                    onClick={() =>
                        setPage("analysis")
                    }
                >
                    Analysis
                </button>

            </nav>


            <hr />


            {page === "newscan" && (

                <NewScan
                    onAnalysisComplete={
                        handleAnalysisComplete
                    }
                />

            )}


            {page === "analysis" && (

                <Analysis
                    result={analysisResult}
                />

            )}

        </div>

    );
}


export default App;