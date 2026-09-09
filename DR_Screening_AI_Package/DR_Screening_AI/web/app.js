// CLINICAL PRESETS DATASET

const API_URL = "http://127.0.0.1:8000";

async function testBackend() {
    try {
        const response = await fetch(`${API_URL}/test`);

        if (!response.ok) {
            throw new Error("Backend request failed");
        }

        const data = await response.json();

        console.log(data);

        alert(data.message);

    } catch (error) {
        console.error(error);
        alert("Could not connect to FastAPI backend.");
    }
}

const CLINICAL_PRESETS = [
  {
    grade: 0,
    title: "No DR Detected",
    subtitle: "Normal Retina",
    badgeClass: "normal",
    confidence: 96,
    progressColor: "linear-gradient(90deg, #10B981, #059669)",
    imageSrc: "assets/normal.png",
    findings: [
      "No signs of microaneurysms detected",
      "No hemorrhages detected",
      "Blood vessels appear normal",
      "Optic disc is healthy"
    ],
    recommendation: "Maintain regular eye checkups (at least once a year) and manage blood sugar levels."
  },
  {
    grade: 1,
    title: "Mild NPDR Detected",
    subtitle: "Early Microaneurysms",
    badgeClass: "mild",
    confidence: 91,
    progressColor: "linear-gradient(90deg, #F59E0B, #D97706)",
    imageSrc: "assets/mild.png",
    findings: [
      "Isolated microaneurysms observed in deep retinal capillary layers",
      "No clinical hard exudates present",
      "Macula clear of clinically significant edema",
      "Focal capillary leakage minimal"
    ],
    recommendation: "Strict glycemic and blood pressure management recommended. Follow-up dilated fundus exam in 6–12 months."
  },
  {
    grade: 2,
    title: "Moderate NPDR Detected",
    subtitle: "Multiple Hemorrhages / Exudates",
    badgeClass: "moderate",
    confidence: 98,
    progressColor: "linear-gradient(90deg, #EA580C, #C2410C)",
    imageSrc: "assets/moderate.png",
    findings: [
      "Multiple dot-and-blot hemorrhages identified across retinal quadrants",
      "Hard exudates noted along temporal vascular arcades",
      "Venous caliber alterations detected",
      "Potential risk of developing diabetic macular edema"
    ],
    recommendation: "Referral to ophthalmology required within 4 weeks. Optical Coherence Tomography (OCT) recommended."
  },
  {
    grade: 3,
    title: "Severe NPDR Detected",
    subtitle: "Meets 4-2-1 Grading Rule",
    badgeClass: "severe",
    confidence: 95,
    progressColor: "linear-gradient(90deg, #EF4444, #DC2626)",
    imageSrc: "assets/severe.png",
    findings: [
      "Severe retinal hemorrhages across ≥ 4 quadrants",
      "Venous beading confirmed in 2 or more quadrants",
      "Prominent cotton-wool spots and intraretinal microvascular abnormalities (IRMA)",
      "High probability of rapid conversion to proliferative stage"
    ],
    recommendation: "Expedited referral to a vitreoretinal specialist within 2 weeks. Comprehensive fluorescein angiography advised."
  },
  {
    grade: 4,
    title: "Proliferative DR Detected",
    subtitle: "Neovascularization Risk",
    badgeClass: "pdr",
    confidence: 99,
    progressColor: "linear-gradient(90deg, #E11D48, #9F1239)",
    imageSrc: "assets/proliferative.png",
    findings: [
      "Active neovascularization detected at the optic disc (NVD) and elsewhere (NVE)",
      "Preretinal / vitreous hemorrhage risk elevated",
      "Fibrous proliferation threatening tractional retinal detachment",
      "Vision-threatening critical emergency"
    ],
    recommendation: "Urgent same-week clinical retina referral. Panretinal photocoagulation (PRP) laser or anti-VEGF injection indicated."
  }
];

// STATE
let currentGrade = 0;
let isGradCamOn = false;
let historyLog = [
  { id: "DR_20250910_1432", time: "10 Sep 2025, 14:32", diagnosis: "No DR Detected", conf: "96%", status: "Normal" },
  { id: "DR_20250910_1115", time: "10 Sep 2025, 11:15", diagnosis: "Moderate NPDR", conf: "98%", status: "Referral" },
  { id: "DR_20250909_1640", time: "09 Sep 2025, 16:40", diagnosis: "Mild NPDR", conf: "91%", status: "Routine" }
];

// DOM ELEMENTS
const demoPills = document.querySelectorAll('.demo-pill');
const heroUploadBtn = document.getElementById('heroUploadBtn');
const uploadAnotherBtn = document.getElementById('uploadAnotherBtn');
const navUploadBtn = document.getElementById('navUploadBtn');
const imageFileInput = document.getElementById('imageFileInput');
const heroFundusImg = document.getElementById('heroFundusImg');
const resultFundusImg = document.getElementById('resultFundusImg');
const scanBeam = document.getElementById('scanBeam');
const toggleGradCamBtn = document.getElementById('toggleGradCamBtn');
const gradcamOverlay = document.getElementById('gradcamOverlay');

const diagnosisBadgeCard = document.getElementById('diagnosisBadgeCard');
const diagnosisTitle = document.getElementById('diagnosisTitle');
const diagnosisSubtitle = document.getElementById('diagnosisSubtitle');
const confidenceValue = document.getElementById('confidenceValue');
const progressFill = document.getElementById('progressFill');
const metaImageId = document.getElementById('metaImageId');
const metaDate = document.getElementById('metaDate');
const lastUpdatedText = document.getElementById('lastUpdatedText');
const findingsList = document.getElementById('findingsList');
const recommendationText = document.getElementById('recommendationText');

const historyModal = document.getElementById('historyModal');
const viewHistoryBtn = document.getElementById('viewHistoryBtn');
const navHistoryBtn = document.getElementById('navHistoryBtn');
const closeHistoryModal = document.getElementById('closeHistoryModal');
const historyTableBody = document.getElementById('historyTableBody');

const aboutModal = document.getElementById('aboutModal');
const navAboutBtn = document.getElementById('navAboutBtn');
const closeAboutModal = document.getElementById('closeAboutModal');

// INITIALIZE
function init() {
  updateView(0);
  renderHistoryTable();
  setupEventListeners();
}

// SETUP EVENT LISTENERS
function setupEventListeners() {
  // Demo pills
  demoPills.forEach(pill => {
    pill.addEventListener('click', () => {
      demoPills.forEach(p => p.classList.remove('active'));
      pill.classList.add('active');
      const grade = parseInt(pill.getAttribute('data-grade'));
      triggerScanningAnimation(() => updateView(grade));
    });
  });

  // Upload buttons trigger file input
  [heroUploadBtn, uploadAnotherBtn, navUploadBtn].forEach(btn => {
    btn.addEventListener('click', () => imageFileInput.click());
  });

  // Handle local file upload
  imageFileInput.addEventListener('change', handleFileSelect);

  // Toggle Grad-CAM
  toggleGradCamBtn.addEventListener('click', () => {
    isGradCamOn = !isGradCamOn;
    gradcamOverlay.classList.toggle('active', isGradCamOn);
    toggleGradCamBtn.style.background = isGradCamOn ? '#0284C7' : 'rgba(15, 23, 42, 0.85)';
    toggleGradCamBtn.style.color = isGradCamOn ? '#FFFFFF' : '#38BDF8';
  });

  // Modals
  viewHistoryBtn.addEventListener('click', () => historyModal.classList.add('open'));
  navHistoryBtn.addEventListener('click', (e) => {
    e.preventDefault();
    historyModal.classList.add('open');
  });
  closeHistoryModal.addEventListener('click', () => historyModal.classList.remove('open'));

  navAboutBtn.addEventListener('click', (e) => {
    e.preventDefault();
    aboutModal.classList.add('open');
  });
  closeAboutModal.addEventListener('click', () => aboutModal.classList.remove('open'));

  // Close modals when clicking backdrop
  [historyModal, aboutModal].forEach(modal => {
    modal.addEventListener('click', (e) => {
      if (e.target === modal) modal.classList.remove('open');
    });
  });
}

// SCANNING ANIMATION
function triggerScanningAnimation(callback) {
  scanBeam.classList.add('scanning');
  setTimeout(() => {
    scanBeam.classList.remove('scanning');
    if (callback) callback();
  }, 1200);
}

// UPDATE VIEW TO MATCH CASE
function updateView(grade) {
  currentGrade = grade;
  const data = CLINICAL_PRESETS[grade];

  // Update images
  heroFundusImg.src = data.imageSrc;
  resultFundusImg.src = data.imageSrc;

  // Reset Grad-CAM overlay
  isGradCamOn = false;
  gradcamOverlay.classList.remove('active');
  toggleGradCamBtn.style.background = 'rgba(15, 23, 42, 0.85)';
  toggleGradCamBtn.style.color = '#38BDF8';

  // Update Badge
  diagnosisBadgeCard.className = `diagnosis-badge-card ${data.badgeClass}`;
  diagnosisTitle.textContent = data.title;
  diagnosisSubtitle.textContent = data.subtitle;

  // Update Confidence Bar
  confidenceValue.textContent = `${data.confidence}%`;
  progressFill.style.width = `${data.confidence}%`;
  progressFill.style.background = data.progressColor;

  // Update Metadata
  const now = new Date();
  const dateStr = now.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
  const timeStr = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  const formattedTime = `${dateStr}, ${timeStr}`;
  const randomId = `DR_${now.getFullYear()}${(now.getMonth()+1).toString().padStart(2,'0')}${now.getDate().toString().padStart(2,'0')}_${Math.floor(1000 + Math.random()*9000)}`;

  metaImageId.textContent = randomId;
  metaDate.textContent = formattedTime;
  lastUpdatedText.textContent = `Last updated: ${formattedTime}`;

  // Update Findings
  findingsList.innerHTML = '';
  data.findings.forEach(finding => {
    const li = document.createElement('li');
    const isWarning = grade >= 2;
    li.innerHTML = `
      <svg class="check-icon ${isWarning ? 'alert-icon' : ''}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
        ${isWarning ? '<circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line>' : '<polyline points="20 6 9 17 4 12"></polyline>'}
      </svg>
      <span>${finding}</span>
    `;
    findingsList.appendChild(li);
  });

  // Update Recommendation
  recommendationText.textContent = data.recommendation;

  // Log to history
  historyLog.unshift({
    id: randomId,
    time: formattedTime,
    diagnosis: data.title,
    conf: `${data.confidence}%`,
    status: grade >= 2 ? 'Referral' : (grade === 1 ? 'Routine' : 'Normal')
  });
  renderHistoryTable();
}

// HANDLE FILE UPLOAD
function handleFileSelect(e) {
  const file = e.target.files[0];
  if (!file) return;

  const reader = new FileReader();
  reader.onload = function(evt) {
    const imgSrc = evt.target.result;
    triggerScanningAnimation(() => {
      heroFundusImg.src = imgSrc;
      resultFundusImg.src = imgSrc;

      // Classify as Grade 1 or 2 for demo
      const randomGrade = Math.random() > 0.5 ? 1 : 2;
      updateView(randomGrade);
      resultFundusImg.src = imgSrc;
      heroFundusImg.src = imgSrc;
    });
  };
  reader.readAsDataURL(file);
}

// RENDER HISTORY TABLE
function renderHistoryTable() {
  historyTableBody.innerHTML = '';
  historyLog.slice(0, 10).forEach(entry => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td><strong>${entry.id}</strong></td>
      <td>${entry.time}</td>
      <td>${entry.diagnosis}</td>
      <td>${entry.conf}</td>
      <td><span style="padding: 3px 8px; border-radius: 6px; font-size: 11px; font-weight: 700; ${entry.status === 'Referral' ? 'background: #FEE2E2; color: #DC2626;' : (entry.status === 'Routine' ? 'background: #FEF9C3; color: #CA8A04;' : 'background: #DCFCE7; color: #16A34A;')} ">${entry.status}</span></td>
    `;
    historyTableBody.appendChild(tr);
  });
}

// START
window.addEventListener('DOMContentLoaded', init);


async function predictImage() {

    const input = document.getElementById("imageInput");

    if (!input) {
        console.error("imageInput was not found");
        alert("Image upload input was not found.");
        return;
    }

    if (!input.files.length) {
        alert("Please select a retinal image first.");
        return;
    }

    const file = input.files[0];

    const formData = new FormData();

    formData.append("file", file);

    try {

        console.log("Sending image to FastAPI...");

        const response = await fetch(
            `${API_URL}/predict`,
            {
                method: "POST",
                body: formData
            }
        );

        console.log("Response status:", response.status);

        if (!response.ok) {
            throw new Error(
                `FastAPI returned ${response.status}`
            );
        }

        const data = await response.json();

        console.log("FastAPI response:", data);

        const result = document.getElementById("result");

        if (result) {

            result.innerHTML = `
                <h2>Prediction Result</h2>

                <p>
                    <strong>Prediction:</strong>
                    ${data.prediction}
                </p>

                <p>
                    <strong>Confidence:</strong>
                    ${(data.confidence * 100).toFixed(2)}%
                </p>
            `;

        } else {

            alert(
                `Prediction: ${data.prediction}\n` +
                `Confidence: ${(data.confidence * 100).toFixed(2)}%`
            );
        }

    } catch (error) {

        console.error("FastAPI connection error:", error);

        alert(
            "Could not connect to FastAPI.\n\n" +
            "Check that the backend terminal is running."
        );
    }
}