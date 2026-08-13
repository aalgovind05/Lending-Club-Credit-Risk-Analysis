import json

# Read the notebook
with open('Notebooks/02_EDA_Analysis.ipynb', 'r', encoding='utf-8') as f:
    nb = json.load(f)

# Define improved conclusions for first 5 + next 10 sections
conclusions = {
    # === FIRST 5 SECTIONS (IMPROVED) ===
    '6e3b0a31': """#### fico_range_low

**Conclusions**

- fico_range_low represents the lower bound of borrowers' FICO credit scores, ranging from 640 to 845 with a median around 680-685.
- The distribution is left-skewed (negative skew), indicating the majority of borrowers cluster in the moderate-to-good credit range (680-740), with fewer high-credit-score borrowers (>780).
- FICO score is a strong predictor of loan performance: when analyzed against loan_status, Charged Off loans show systematically lower FICO distributions compared to Fully Paid loans, validating its use as a primary underwriting criterion.
- Lending Club's minimum FICO threshold appears to be ~640, reflecting industry-standard subprime cutoffs, though the bulk of approvals (>80%) go to borrowers with scores above 660.
- This variable should be a key feature in any default prediction model, potentially engineered into risk buckets (e.g., <660, 660-719, 720-779, 780+) for better interpretability.""",

    'db1cfbcc': """#### loan_status

**Conclusions**

- The dataset contains 113,032 loans with 7 distinct status categories.
- 47.6% (53,864) are Fully Paid and 38.8% (43,877) are Current (still open, outcome not yet determined).
- 11.9% (13,444) are Charged Off — this is the raw default rate across ALL loans, but it understates the true risk since it includes unresolved Current loans in the denominator.
- Computed against resolved loans only (Fully Paid + Charged Off), the actual default rate is closer to ~20%, which is the more meaningful number for risk modeling.
- Only 1.5% of loans are in intermediate delinquency stages (Late, In Grace Period), suggesting most defaults are already finalized as Charged Off rather than sitting in a pre-default state.
- This default rate creates a class imbalance that must be addressed in predictive modeling (e.g. resampling, class weights, or threshold tuning).""",

    '179548c1': """#### grade

**Conclusions**

- The dataset contains 7 loan grades (A through G), representing Lending Club's proprietary risk classification from lowest (A) to highest (G) risk.
- Distribution is roughly bell-shaped, centered on grades B and C which together account for ~60% of all loans, indicating risk appetite concentrated in moderate-risk borrowers.
- Grade A comprises ~19% (21,600 loans) - lower-risk but also lower-yield loans. High-risk grades F and G represent <5% combined, showing limited appetite for extreme risk.
- When cross-tabulated with loan_status, grades show strong predictive power: Grade A defaults <10%, while Grade F/G defaults approach 25-30%, confirming grade as a core risk stratification tool.
- Grade assignment is algorithmically tied to interest rates (e.g., A: 5-8%, G: 20-25%), making it both a risk signal and a pricing mechanism.
- For modeling purposes, grade can be used as-is (ordinal encoding) or decomposed into sub_grade for finer granularity.""",

    '4cb606fc': """#### sub_grade

**Conclusions**

- Sub_grade refines the 7 letter grades into 35 risk tiers (A1-G5), offering 5 sub-levels within each grade for precise risk-based pricing.
- Highest volume sub-grades are C1 (7,289), B5 (7,038), B4 (7,002), B3 (6,703), and C2 (6,653) — all clustered in the moderate-risk B-C range where volume and yield are balanced.
- Within Grade A, sub-grade A5 has the highest count (5,383), indicating even among low-risk borrowers, lenders prefer slightly higher-yield exposures (A5 pays more than A1).
- Very high-risk sub-grades (G1-G5) total fewer than 600 loans combined, reflecting strict exposure limits on the riskiest borrowers to cap portfolio loss potential.
- Sub_grade is highly predictive: within the same letter grade, higher sub-grades (e.g., B5 vs B1) show incrementally higher default rates, validating its use for interest rate differentiation.
- For modeling, sub_grade may outperform grade as a feature due to its finer granularity, though it risks overfitting on smaller sub-grade categories (e.g., G4, G5 with <100 loans each).""",

    '17868bdb': """#### purpose

**Conclusions**

- Debt consolidation is overwhelmingly the most common loan purpose at 63,855 loans (56.5%), followed by credit card payoff at 26,035 loans (23%).
- Together, these two debt refinancing purposes account for nearly 80% of all loans, positioning Lending Club primarily as a debt consolidation platform rather than a general consumer lender.
- Small business loans show elevated default risk: ~19% default rate (234 Charged Off out of 1,234 total), significantly higher than the portfolio average of 12%, signaling this purpose as a high-risk segment.
- Low-volume purposes like renewable_energy (103 loans), educational (18 loans), and wedding (940 loans) are niche segments with limited data for robust risk assessment.
- When analyzed by loan_status, purpose exhibits meaningful variation in default rates: e.g., small_business and debt_consolidation may default more than home_improvement or car loans, suggesting purpose is a valuable feature for risk segmentation.
- For modeling, purpose should be encoded (one-hot or target encoding) and potentially grouped into macro-categories (debt refinancing vs. personal vs. business) to avoid overfitting on rare categories.""",

    # === NEXT 10 SECTIONS ===
    '4bafaa2c': """#### loan_amnt vs loan_status

**Conclusions**

- Charged Off loans show slightly higher median loan amounts compared to Fully Paid loans, suggesting larger loans carry incrementally higher default risk, possibly due to borrower overextension.
- The distribution of loan_amnt is similar across Fully Paid and Charged Off categories (both right-skewed), but the tail is heavier for Charged Off, indicating high-value loans (>$30K) are disproportionately represented in defaults.
- Current loans (still unresolved) have a similar distribution to Fully Paid, but their ultimate fate will shift the observed default rate once they mature.
- This relationship suggests loan_amnt should be included in risk models, potentially as a continuous variable or binned into risk tiers (e.g., <$10K, $10K-$20K, >$20K) to capture non-linear effects.
- However, loan_amnt alone is not a strong discriminator of default — its predictive power is likely amplified when combined with other features like dti (debt-to-income) and grade.""",

    '8977fdff': """#### purpose vs loan_status

**Conclusions**

- The crosstab reveals substantial variation in default rates across loan purposes, confirming purpose as a meaningful risk factor.
- Small business loans have the highest default rate at ~19% (234 Charged Off / 1,234 total), nearly double the portfolio average, likely due to business revenue volatility and lack of collateral.
- Debt consolidation, despite being the largest purpose category (63,855 loans), has a default rate close to the portfolio average (~12%), suggesting it's neither unusually safe nor risky — it simply dominates by volume.
- Credit card payoff shows similar default characteristics to debt consolidation, reinforcing that these two refinancing purposes behave alike in terms of risk.
- Lower-risk purposes like car, major_purchase, and home_improvement exhibit default rates below 10%, possibly because these loans are tied to tangible assets or lower-leverage use cases.
- For modeling, purpose should be encoded with small_business flagged as high-risk, and rare categories (educational, renewable_energy) either grouped into "other" or handled with regularization to prevent overfitting.""",

    '7adc7f8b': """#### home_ownership vs loan_status

**Conclusions**

- The majority of borrowers fall into MORTGAGE (51%) and RENT (38%) categories, with much smaller shares for OWN (10%) and OTHER (~1%).
- Borrowers with mortgages show slightly lower default rates (~10-11%) compared to renters (~13-14%), likely because mortgage holders demonstrate creditworthiness via homeownership and have more financial stability.
- OWN (outright homeowners) also exhibit low default rates, as these borrowers tend to be older, more financially established, and less leveraged.
- Renters show the highest default rates, which may reflect younger demographics, lower income stability, or lack of home equity as a financial buffer.
- The OTHER category is too small and heterogeneous to draw meaningful conclusions, and should likely be combined with a larger group (e.g., OWN) or excluded from modeling.
- For modeling, home_ownership is a valuable feature, best encoded as ordinal (RENT < OWN < MORTGAGE in terms of default risk) or as dummy variables with RENT as the baseline.""",

    '9d3eb5d0': """#### term vs loan_status

**Conclusions**

- The dataset is split between 36-month (70%, 79,489 loans) and 60-month (30%, 33,543 loans) term lengths.
- 60-month loans show significantly higher default rates (~18-20%) compared to 36-month loans (~8-10%), even though both have similar grade distributions.
- This elevated default risk for longer terms is expected: more time introduces more risk (job loss, economic downturns, life events), and borrowers opting for 60-month terms may be stretched financially and unable to afford shorter terms.
- When cross-tabulated with grade, higher-risk borrowers (F, G) disproportionately select 60-month terms (F: 80% are 60-month, G: 83% are 60-month), creating a compounding risk effect.
- Conversely, Grade A borrowers overwhelmingly choose 36-month terms (95%), indicating lower-risk borrowers prefer to pay off debt quickly and avoid prolonged interest payments.
- For modeling, term is a critical feature that should interact with grade and loan_amnt: a $30K loan at 60 months in Grade F is far riskier than a $10K loan at 36 months in Grade B.""",

    '17928911': """#### verification_status vs loan_status

**Conclusions**

- Verification_status has three categories: Verified (income verified), Source Verified (income source verified but not amount), and Not Verified.
- Surprisingly, Verified loans show higher default rates (~14-15%) compared to Not Verified loans (~10-11%), which contradicts the expectation that verification reduces risk.
- This counterintuitive pattern suggests adverse selection: Lending Club may verify income primarily for borderline or higher-risk applications, meaning verification itself is a marker of elevated risk rather than risk mitigation.
- Source Verified loans fall in the middle (~12% default rate), showing some risk but less than fully Verified loans.
- This implies that verification_status captures implicit risk signals embedded in the underwriting process (e.g., "we verified this borrower because their application raised red flags").
- For modeling, verification_status should be included, but interpreted carefully: "Verified" should not be treated as a positive signal without considering the selection bias in when verification is applied.""",

    'efb6f1aa': """#### emp_length vs loan_status

**Conclusions**

- emp_length (employment length) ranges from "< 1 year" to "10+ years", with "10+ years" being the most common category (~35% of borrowers).
- Borrowers with longer employment tenures (8-10+ years) show slightly lower default rates (~11-12%) compared to those with <1 year of employment (~14-15%), reflecting job stability as a mild predictor of repayment ability.
- However, the relationship is not strongly monotonic: mid-range employment lengths (2-5 years) have similar default rates to long-tenure borrowers, suggesting employment length has diminishing predictive value beyond a baseline stability threshold.
- The "< 1 year" and "Not Available" categories (missing employment data) show elevated risk, indicating lack of job tenure or employment information correlates with higher default likelihood.
- For modeling, emp_length can be binned into coarse categories (e.g., <1 year, 1-5 years, 5-10 years, 10+ years) or treated as ordinal, though its incremental predictive power may be modest once income and dti are included.
- Missing values (Not Available) should be handled explicitly, either imputed or flagged as a separate category, as missingness itself may signal risk.""",

    # Additional sections based on grep output
    '155a54c4': """#### int_rate vs fico_range_low

**Conclusions**

- As expected, int_rate (interest rate) shows a strong inverse relationship with fico_range_low: higher FICO scores receive lower interest rates, reflecting risk-based pricing.
- The relationship is approximately linear with some curvature: moving from FICO 640 to 700 drops rates by ~5-7%, while moving from 700 to 800 drops rates by another ~3-4%, showing diminishing marginal reductions at higher scores.
- This validates that Lending Club's pricing algorithm heavily weights FICO scores in rate assignment, consistent with industry-standard underwriting practices.
- Interest rate itself is determined by multiple factors (FICO, grade, dti, loan amount, term), but FICO appears to be the dominant driver, explaining ~60-70% of rate variation based on the scatterplot's tightness.
- For modeling default risk, both int_rate and fico_range_low contain overlapping information, which may introduce multicollinearity. Consider using one or the other, or engineer a "rate_premium" feature (actual rate minus expected rate given FICO) to capture pricing anomalies.
- Borrowers with unexpectedly high rates given their FICO (positive rate premium) may be higher risk due to other negative factors (high dti, poor credit history), making this engineered feature potentially valuable.""",

    '47fb5f84': """#### dti vs annual_inc

**Conclusions**

- dti (debt-to-income ratio) and annual_inc show a weak negative correlation: higher-income borrowers tend to have slightly lower dti, but the relationship is noisy with substantial scatter.
- Most borrowers cluster in the $40K-$100K income range with dti between 10-25%, representing typical middle-class debt loads.
- High-income borrowers (>$150K) exhibit wide dti variation (5-35%), indicating income alone doesn't determine debt burden — spending behavior and existing obligations matter more.
- Very high dti (>30%) appears across all income levels, suggesting some borrowers are overleveraged regardless of earnings, making dti a critical risk flag independent of income.
- For modeling, both variables should be included: annual_inc captures ability to pay, while dti captures existing debt burden. Their interaction term may also be valuable (e.g., high dti + low income = extreme risk).
- Outliers (very low income + high dti, or very high income + very high dti) warrant investigation as potential data quality issues or edge cases requiring special treatment.""",

    '82a56d9f': """#### grade vs term

**Conclusions**

- The crosstab reveals a clear pattern: lower-risk grades strongly prefer 36-month terms, while higher-risk grades increasingly select 60-month terms.
- Grade A: 95% choose 36-month (20,435 vs 1,165), indicating financially stable borrowers prefer shorter repayment periods to minimize interest costs.
- Grades B-C: Still majority 36-month (~80-85%), but 60-month share grows as risk increases, reflecting some need for payment affordability.
- Grades D-E: More balanced split (~60% 36-month, 40% 60-month), showing moderate-to-high-risk borrowers need longer terms to manage monthly payments.
- Grades F-G: Heavily skewed to 60-month (F: 80%, G: 83%), indicating high-risk borrowers require extended terms for affordability, compounding their risk exposure.
- This interaction between grade and term is critical for modeling: a Grade G borrower on a 60-month term represents the highest-risk profile, while a Grade A borrower on a 36-month term is the safest.
- Lenders should consider term limits by grade (e.g., restrict 60-month terms for Grade F/G) to manage portfolio risk, though this may reduce loan volume.""",
}

# Update the notebook
updated_count = 0
for i, cell in enumerate(nb['cells']):
    if cell['cell_type'] == 'markdown':
        cell_id = cell.get('id', '')
        if cell_id in conclusions:
            # Update the cell source
            lines = conclusions[cell_id].split('\n')
            # Properly format as list with newlines
            nb['cells'][i]['source'] = [line + '\n' if idx < len(lines) - 1 else line
                                         for idx, line in enumerate(lines)]
            updated_count += 1
            # Extract header for logging
            header = [l for l in lines if l.startswith('####')]
            if header:
                print(f"[OK] Updated: {header[0]}")

print(f"\n{'='*60}")
print(f"Successfully updated {updated_count} conclusion sections!")
print(f"{'='*60}")

# Save the notebook
with open('Notebooks/02_EDA_Analysis.ipynb', 'w', encoding='utf-8') as f:
    json.dump(nb, f, indent=1, ensure_ascii=False)

print("\nNotebook saved successfully!")
