# UDI Matlab Analysis Pipeline
### Urodynamic Investigation in Awake Mice — Functional Urology Research Laboratory
**Department of Biomedical Research (DBMR), University of Bern**
*Pragya Nagar, Chaimae Bahou, Pedro Perreira Amado, Katia Monastyrskaya-Stäuber, Ali Hashemi Gheinani*

---

## What is UDI?

**Urodynamic Investigation (UDI)** combined with **electromyography (EMG)** is used to assess lower urinary tract (LUT) function in fully awake mice. This setup simultaneously records:

| Channel | What it measures |
|---|---|
| **Intravesical pressure** | Detrusor muscle contractions |
| **EUS-EMG** | External urethral sphincter activity |
| **Voided volume** | Urine output via precision scale (5 Hz) |

This approach enables detection of **non-voiding contractions (NVCs)** — the mouse equivalent of detrusor overactivity in humans — and **detrusor-sphincter dyssynergia (DSD)**, both key features of neurogenic lower urinary tract dysfunction (NLUTD).

> **Clinical relevance:** The pipeline supports research in **spinal cord injury (SCI)**, **partial bladder outlet obstruction (pBOO)**, and related models of bladder dysfunction.

**Reference:** Schneider MP, Hughes FM Jr, Engmann AK, Purves JT, Kasper H, Tedaldi M, Spruill LS, Gullo M, Schwab ME, Kessler TM. A novel urodynamic model for lower urinary tract assessment in awake rats. *BJU Int.* 2015 Apr;115 Suppl 6:8–15. doi: [10.1111/bju.13039](https://doi.org/10.1111/bju.13039). PMID: 25597776.

---

## Experimental Setup

![Urodynamic Setup](urodynamic_setup.png)

```
Saline infusion pump (20 µL/min for SCI)
        │
        ▼
  Bladder catheter ──► In-line pressure transducer ──► Signal amplifier
        │
  EMG electrodes ──────────────────────────────────► EMG amplifier
        │
  Mouse in restrainer
        │
        ▼
     Scale (5 Hz) ──────────────────────────────────► Data acquisition
        │
        └──────────────────────────────────────────► LabVIEW recording
```

**Data is saved as `.tdms` files** (NI LabVIEW format) and exported as `.csv` for analysis.

---

## Pipeline Overview

```
Raw .tdms or .csv file
         │
         ▼
  ┌─────────────────────────────────────┐
  │   1. Load & preprocess              │  Timeseriesfiles / Sham_for_tdms
  │      - Extract pressure, scale, EMG │
  │      - Compute sampling rates       │
  │      - Normalize & align time       │
  └────────────┬────────────────────────┘
               │
               ▼
  ┌─────────────────────────────────────┐
  │   2. Visual inspection (ginput)     │  Sham / SCI analysis scripts
  │      - Plot full recording          │
  │      - User selects micturition     │
  │        cycle interactively          │
  └────────────┬────────────────────────┘
               │
               ▼
  ┌─────────────────────────────────────┐
  │   3. Peak & threshold detection     │
  │      - Find Pmax (peak pressure)    │
  │      - Derivative-based Pthresh     │
  │      - Filling / contraction / BL   │
  │        phase segmentation           │
  └────────────┬────────────────────────┘
               │
               ▼
  ┌─────────────────────────────────────┐
  │   4. NVC & contraction detection    │
  │      - 15%, 5%, 2% above threshold  │
  │      - Sub-threshold contractions   │
  │      - Microcontractions            │
  └────────────┬────────────────────────┘
               │
               ▼
  ┌─────────────────────────────────────┐
  │   5. Compliance & voided volume     │
  │      - Bladder compliance (µL/cmH₂O)│
  │      - Voided volume (whole cycle)  │
  │      - Voided volume (peak window)  │
  └────────────┬────────────────────────┘
               │
               ▼
  ┌─────────────────────────────────────┐
  │   6. Export                         │
  │      - Results CSV                  │
  │      - Publication-quality figures  │
  └─────────────────────────────────────┘
```

---

## Scripts

### Main Analysis Scripts

| Script | Use case | Input format |
|---|---|---|
| [`Sham_for_tdms_31032026.m`](Sham_for_tdms_31032026.m) | Full Sham analysis | `.tdms` |
| [`Sham_for_csv_19032026.m`](Sham_for_csv_19032026.m) | Full Sham analysis | `.csv` |
| [`SCI_24.08.2024.m`](SCI_24.08.2024.m) | SCI model analysis | `.tdms` / `.csv` |
| [`Sham_24.08.2024.m`](Sham_24.08.2024.m) | Sham (legacy version) | `.tdms` / `.csv` |
| [`Sham_compliance_23.07.2025.m`](Sham_compliance_23.07.2025.m) | Compliance-focused | `.tdms` / `.csv` |
| [`Timeseriesfiles_24042025.m`](Timeseriesfiles_24042025.m) | Export timeseries to CSV | `.tdms` |
| [`Plotting_tracings.m`](Plotting_tracings.m) | Publication-quality plots | `.tdms` |
| [`All_codes_summary_PN.m`](All_codes_summary_PN.m) | Code reference summary | — |

### Helper Functions

| Function | Purpose |
|---|---|
| [`findpeak.m`](findpeak.m) | Find index and value of maximum pressure |
| [`findmin.m`](findmin.m) | Find index and value of minimum pressure |
| [`findselection.m`](findselection.m) | Return indices within a user-selected time range |
| [`findtimewindow.m`](findtimewindow.m) | Extract pre/post window around pressure peak |
| [`findpre.m`](findpre.m) | Extract pre-peak filling phase indices |
| [`findpost.m`](findpost.m) | Extract post-peak indices |
| [`findsection.m`](findsection.m) | Extract contraction phase (Pthresh → Pmax) |
| [`findprolsection.m`](findprolsection.m) | Extended section (±5000 pts) for smooth boundary handling |
| [`findprolongedsection.m`](findprolongedsection.m) | Extended section (±1 s) for smooth boundary handling |

---

## Output Parameters

Each analysis run exports a `.csv` row containing:

| Parameter | Unit | Description |
|---|---|---|
| Number of peaks | — | Detected voiding contractions |
| Peak pressure (Pmax) | cmH₂O | Maximum detrusor pressure |
| Normalized Pmax (nPmax) | cmH₂O | Pmax − Pbase |
| Micturition cycle duration | min | Full cycle length |
| Threshold pressure (Pthresh) | cmH₂O | Pressure at voiding onset |
| Pthresh → Pmax amplitude | cmH₂O | Contraction range |
| Voided volume (whole cycle) | µL | Total urine output |
| Voided volume (peak window) | µL | Output around peak |
| NVCs ≥ 15% above threshold | count | Strong non-voiding contractions |
| NVCs at threshold | count | Threshold-level NVCs |
| NVCs 5% / 2% above threshold | count | Graded NVC classification |
| Sub-threshold contractions | count | Below voiding threshold |
| Microcontractions | count | Noise-adaptive small contractions |
| Bladder compliance | µL/cmH₂O | Filling phase compliance |
| Volume filled | µL | Saline instilled during filling |

---

## Variable Naming Convention

```
[scope] _ [type] _ [parameter]

Scope:   e = entire recording
         z = zoom (one micturition cycle)
         w = window (around pressure peak)
         a = all cycles (SCI measurements)

Type:    tsp  = timestamp (seconds)
         idx  = array index
         val  = numeric value
         logi = logical (0/1) mask
```

**Example:** `z_val_nPmax` = normalized max pressure within the selected micturition cycle.

---

## NVC Classification

Non-voiding contractions (NVCs) are classified by their height relative to the voiding pressure threshold:

```
                    ┌──────────────────────── Pmax (voiding contraction)
                    │
  ── 15% above ─────┼──── NVC_15  (strong NVCs, clinically significant)
  ──  5% above ─────┼──── NVC_5
  ──  2% above ─────┼──── NVC_2
  ── Pthresh ────────┼──── NVC (at threshold)
  ── Sub-thresh ─────┼──── sub-NVC
  ── Micro ──────────┼──── microcontractions (noise-adaptive floor)
                    │
  ── Pbase ──────────┘
```

Detection uses a **smoothed filtered signal** (`smooth(..., 2500)`) with `findpeaks()` and minimum peak distance/width constraints to avoid counting noise.

---

## Requirements

- **MATLAB** R2018b or later
- **Signal Processing Toolbox** (for `smooth`, `findpeaks`)
- **TDMS reader:** [`TDMS_readTDMSFile`](https://www.mathworks.com/matlabcentral/fileexchange/30023) (NI LabVIEW TDMS file reader)

---

## Folder Structure

```
Animal_ID/               e.g. 189L/
├── Day 1/
│   └── recording.tdms   (or pressure.csv + scale.csv)
├── Day 2/
│   └── recording.tdms
├── figures/
│   ├── *_fig1.png       (raw + normalized overview)
│   ├── *_fig2.png       (compliance window)
│   └── micturationcycle figure/
│       └── *_NVC_summary.png
└── output results/
    └── *_results.csv
```

---

## Contact

**Functional Urology Research Laboratory**
Department for BioMedical Research (DBMR), University of Bern
GitHub: [github.com/1urology](https://github.com/1urology)

---

| | |
|---|---|
| **Dr. Ali Hashemi Gheinani** | **Prof. Dr. Katia Monastyrskaya-Stäuber** |
| Group Leader | Group Leader |
| ali.hashemi@unibe.ch | katia.monastyrskaia@unibe.ch |
| [Hashemi Gheinani Lab](https://www.dbmr.unibe.ch/research/research_programs/monastyrskaya_lab/index_eng.html) | [Monastyrskaya Lab](https://www.dbmr.unibe.ch/research/research_programs/hashemi_gheinani_lab/index_eng.html) |
