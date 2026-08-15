# Lending-Club-Credit-Risk-Analysis

## SQL Analysis
## Overview
This repository contains SQL analyses for the Lending Club loan dataset, exploring credit risk patterns, pricing integrity, vintage performance, data quality validation, and cohort default curves.

## Query Catalog

| Query | Title | Purpose | Key Technique |
|-------|-------|---------|---------------|
| **Q1** | Vintage Risk Analysis | Find worst Grade A vintage by charged-off rate | CTE + subquery for baseline comparison |
| **Q2** | FICO Pricing Integrity | Flag mispriced FICO bands (high rate + high default) | CASE bands + conditional flagging |
| **Q3** | Revolving Utilization as Risk Predictor | Test DTI co-movement across utilization buckets | Bucketing + co-movement flag |
| **Q4** | Sub-Grade Underperformers | Find sub-grades exceeding parent grade default rate | Self-join via grade-level CTE |
| **Q5** | Rolling Volume Trend | Flag contraction signals (volume < 80% of 3-mo avg + MoM decline) | Window functions: `ROWS BETWEEN`, `LAG()` |
| **Q6** | Verification Status Controlled for Grade | Test if verification adds explanatory power beyond grade | Grade-controlled comparison |
| **Q7** | Employment Length Segmentation | Default rate & dollar exposure by employment tenure | CASE bucketing + dollar-weighted loss |
| **Q8** | State Risk Rank Divergence | Find states safe by count but risky by dollar exposure | Dual ranking (count vs dollar) + divergence flag |
| **Q9** | Debt Trap Segmentation | Share of charged-off dollars from high-DTI + high-util borrowers | Profile filtering + purpose-level aggregation |
| **Q10** | Risk Score Proxy Validation | 0–4 composite score validated for monotonicity, lift, confusion matrix | Composite scoring + 3-way validation |
| **Q11** | DTI Decile Concentration | Top DTI decile charged-off rate, loan size, grade overrepresentation | `NTILE(10)` + overrepresentation ratio |
| **Q12** | Data Quality Audit | 5 validation checks (duplicates, rate range, FICO range, DTI >100, future dates) | Multi-CTE pipeline + `UNION ALL` summary |
| **Q13** | Vintage Cohort Default Curve | Cumulative default % at 6/12/18/24 months for 3 monthly cohorts | Fixed observation windows + running SUM window |

---

## Q12 — Data Quality Audit: Insight

**Purpose:** Pre-analysis gate to quantify data quality issues before trusting downstream analytics.

| Check | What It Catches | Why It Matters |
|-------|-----------------|----------------|
| Duplicate `loan_id` | Primary key violations | Duplicate records inflate volumes, bias rates |
| `interest_rate` outside 1–40% | Implausible rates (data entry errors) | Skews pricing analysis, risk models |
| `fico_range_low`/`high` outside 300–850 | Invalid FICO scores | FICO banding logic breaks |
| `win_dti` > 100 | Likely decimal-place errors (150 vs 1.5) | DTI deciles, risk scores corrupted |
| `issue_date` > dataset max | Future-dated records from ingestion bugs | Vintage/cohort analyses contaminated |

**Structure:** Each check is an independent CTE; final `UNION ALL` produces a one-row-per-check summary ordered by violation count (highest first). Run first — any non-zero count warrants investigation before proceeding.

---

## Q13 — Vintage Cohort Default Curve: Insight

**Purpose:** Track how default risk accumulates over a loan's life for specific issuance vintages. This is the foundational view for credit risk modeling — it answers "of loans issued in Jan 2015, what % had charged off by month 6, 12, 18, 24?"

**Key Design Decisions:**
- **Fixed observation windows** (6, 12, 18, 24 months post-cohort) using `DATEADD`, not `GETDATE()` — results are historically reproducible
- **Cohort denominator locked at issuance** — `cohort_sizes` CTE ensures the denominator never changes (loans don't leave the cohort)
- **Running cumulative SUM** — `ROWS UNBOUNDED PRECEDING` properly accumulates charged-offs month-over-month
- **Plot-ready output** — `cohort_month × month_on_book × cumulative_default_pct` feeds directly into line charts

**Critical Distinction:** *Cohort vintage* (`issue_date`) ≠ *borrower credit history age* (`earliest_credit_line`). The former measures loan seasoning; the latter measures borrower experience. Conflating them is a common analytical error.

**Expected Pattern:** Curves should steepen early (months 0–12) then flatten. A 2017 curve above 2015 at same month-on-book signals underwriting deterioration. Divergence between cohorts at month 24 reveals vintage quality gaps.

---

## Usage

All queries assume a table named `happen` with standard Lending Club columns:
- `loan_id`, `issue_date`, `loan_status`, `grade`, `sub_grade`
- `fico_range_low`, `fico_range_high`, `interest_rate`
- `debt_to_income_ratio`, `win_dti`, `revolving_utilization_rate`
- `loan_amount`, `purpose`, `borrower_state`, `employment_length`
- `verification_status`, `earliest_credit_line`

Run queries in any order. **Recommended:** Q12 first (data quality gate), then Q1–Q11 for risk analysis, Q13 for vintage curves.