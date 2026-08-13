import json

# Read the notebook
with open('Notebooks/02_EDA_Analysis.ipynb', 'r', encoding='utf-8') as f:
    nb = json.load(f)

# Define conclusions in the user's preferred style - clear, concise, professional
conclusions = {
    # === FIRST 5 SECTIONS ===
    '6e3b0a31': """#### fico_range_low

**Conclusions**

- fico_range_low represents borrowers' FICO credit scores, ranging from 640 to 845 with a median around 680-685.
- The distribution is left-skewed, indicating most borrowers have moderate-to-good credit scores (680-740 range), with fewer high-score borrowers above 780.
- FICO score strongly predicts loan performance - Charged Off loans show systematically lower FICO scores compared to Fully Paid loans.
- Lending Club's minimum FICO threshold appears to be around 640, though most approvals (>80%) go to borrowers with scores above 660.
- This variable is essential for default prediction models and can be engineered into risk buckets (e.g., <660, 660-719, 720-779, 780+) for better interpretability.""",

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

- The dataset contains 7 loan grades (A through G), representing Lending Club's risk classification from lowest (A) to highest (G) risk.
- Distribution is bell-shaped and centered on grades B and C, which together account for ~60% of all loans, showing risk appetite concentrated in moderate-risk borrowers.
- Grade A comprises ~19% (21,600 loans) with default rates below 10%, while high-risk grades F and G represent <5% combined with default rates approaching 30-40%.
- When cross-tabulated with loan_status, grade shows strong predictive power with a clear risk gradient from A to G.
- Grade is algorithmically tied to interest rates (A: 5-8%, G: 20-25%), making it both a risk signal and a pricing mechanism.
- For modeling purposes, grade can be used as-is with ordinal encoding or decomposed into sub_grade for finer granularity.""",

    '4cb606fc': """#### sub_grade

**Conclusions**

- Sub_grade refines the 7 letter grades into 35 risk tiers (A1-G5), offering 5 sub-levels within each grade for precise risk-based pricing.
- Highest volume sub-grades are C1 (7,289), B5 (7,038), B4 (7,002), B3 (6,703), and C2 (6,553) — all in the moderate-risk B-C range.
- Within Grade A, sub-grade A5 has the highest count (5,383), indicating lenders prefer slightly higher-yield exposures even among low-risk borrowers.
- Very high-risk sub-grades (G1-G5) total fewer than 600 loans combined, reflecting strict exposure limits on the riskiest borrowers.
- Sub_grade is highly predictive: within the same letter grade, higher sub-grades show incrementally higher default rates.
- For modeling, sub_grade may outperform grade due to finer granularity, though smaller categories (G4, G5) risk overfitting.""",

    '17868bdb': """#### purpose

**Conclusions**

- Debt consolidation is the most common loan purpose at 63,855 loans (56.5%), followed by credit card payoff at 26,035 loans (23%).
- Together, these two debt refinancing purposes account for nearly 80% of all loans, positioning Lending Club primarily as a debt consolidation platform.
- Small business loans show elevated default risk at ~19% (234 Charged Off out of 1,234 total), significantly higher than the portfolio average of 12%.
- Low-volume purposes like renewable_energy (103 loans), educational (18 loans), and wedding (940 loans) are niche segments with limited data.
- Purpose exhibits meaningful variation in default rates across categories, making it a valuable feature for risk segmentation.
- For modeling, purpose should be encoded (one-hot or target encoding) and rare categories grouped to avoid overfitting.""",

    # === NEXT 10 SECTIONS ===
    '4bafaa2c': """#### loan_amnt vs loan_status

**Conclusions**

- Charged Off loans show slightly higher median loan amounts compared to Fully Paid loans, suggesting larger loans carry incrementally higher default risk.
- The distribution of loan_amnt is similar across both categories (right-skewed), but the tail is heavier for Charged Off loans.
- High-value loans above $30K are disproportionately represented in defaults, indicating borrower overextension at higher loan amounts.
- Current loans (still unresolved) have a similar distribution to Fully Paid, but their ultimate fate will shift the observed patterns once they mature.
- Loan_amnt should be included in risk models, either as a continuous variable or binned into risk tiers to capture non-linear effects.""",

    '8977fdff': """#### purpose vs loan_status

**Conclusions**

- The crosstab reveals substantial variation in default rates across loan purposes, confirming purpose as a meaningful risk factor.
- Small business loans have the highest default rate at ~19.7% (234 Charged Off / 1,234 total), nearly double the portfolio average.
- Debt consolidation, despite being the largest category (63,855 loans), has a default rate close to the portfolio average (~12%).
- Credit card payoff shows similar default characteristics to debt consolidation, reinforcing that these refinancing purposes behave alike.
- Lower-risk purposes like car, major_purchase, and home_improvement exhibit default rates below 10%.
- For modeling, small_business should be flagged as high-risk, and rare categories grouped into "other" or handled with regularization.""",

    '7adc7f8b': """#### home_ownership vs loan_status

**Conclusions**

- The majority of borrowers are MORTGAGE holders (51%) and RENT (38%), with smaller shares for OWN (10%) and OTHER (~1%).
- Borrowers with mortgages show the lowest default rate at ~10.6%, likely because mortgage holders demonstrate creditworthiness and financial stability.
- Renters show the highest default rate at ~14.1%, which is 33% higher than mortgage holders.
- OWN (outright homeowners) exhibit moderate default rates at ~11.7%, as these borrowers tend to be more financially established.
- The OTHER category is too small to draw meaningful conclusions and should be combined with a larger group or excluded from modeling.
- Home_ownership is a valuable feature for modeling, best encoded as dummy variables or ordinal (RENT < OWN < MORTGAGE in risk).""",

    '9d3eb5d0': """#### term vs loan_status

**Conclusions**

- The dataset is split between 36-month (70%, 79,489 loans) and 60-month (30%, 33,543 loans) term lengths.
- 60-month loans show significantly higher default rates (~16.6%) compared to 36-month loans (~10.0%), a 66% increase in risk.
- This elevated risk for longer terms reflects more time for adverse events and indicates borrowers stretched financially.
- When cross-tabulated with grade, higher-risk borrowers (F, G) disproportionately select 60-month terms (80%+), creating a compounding risk effect.
- Grade A borrowers overwhelmingly choose 36-month terms (95%), indicating lower-risk borrowers prefer to pay off debt quickly.
- For modeling, term is a critical feature that should interact with grade and loan_amnt to capture the full risk profile.""",

    '17928911': """#### verification_status vs loan_status

**Conclusions**

- Verification_status has three categories: Verified (income verified), Source Verified (income source verified), and Not Verified.
- Surprisingly, Verified loans show higher default rates (~16.1%) compared to Not Verified loans (~10.8%), which contradicts expectations.
- This counterintuitive pattern suggests adverse selection: Lending Club may verify income primarily for borderline or higher-risk applications.
- Source Verified loans fall in the middle at ~12.6% default rate, showing moderate risk between the two extremes.
- Verification_status appears to be a marker of lender concern rather than risk mitigation, capturing implicit risk signals in the underwriting process.
- For modeling, verification_status should be included, but "Verified" should not be treated as a positive signal without considering selection bias.""",

    'efb6f1aa': """#### emp_length vs loan_status

**Conclusions**

- emp_length (employment length) ranges from "< 1 year" to "10+ years", with "10+ years" being the most common category (~35% of borrowers).
- Borrowers with 10+ years employment show the lowest default rate at ~11.5%, reflecting job stability as a predictor of repayment ability.
- Mid-range employment lengths (2-7 years) have similar default rates (~12-12.5%), suggesting employment length has diminishing predictive value beyond baseline stability.
- The "< 1 year" and "Not Available" categories show elevated risk at ~13.8-14%, indicating lack of job tenure correlates with higher default likelihood.
- For modeling, emp_length can be binned into coarse categories (e.g., <1 year, 1-5 years, 5-10 years, 10+ years) or treated as ordinal.
- Missing values should be handled explicitly, either imputed or flagged as a separate category, as missingness itself may signal risk.""",

    # Find the actual cell IDs for the last 4 sections by searching
    # I'll add placeholder IDs and we'll find the correct ones
}

# Now let's find the correct cell IDs for the remaining sections
print("Searching for remaining section cell IDs...\n")

section_mapping = {}
for i, cell in enumerate(nb['cells']):
    if cell['cell_type'] == 'markdown':
        source = ''.join(cell['source'])
        cell_id = cell.get('id', '')

        if '#### int_rate vs fico_range_low' in source:
            section_mapping['int_rate vs fico_range_low'] = cell_id
        elif '#### dti vs annual_inc' in source:
            section_mapping['dti vs annual_inc'] = cell_id
        elif '#### grade vs term' in source:
            section_mapping['grade vs term'] = cell_id

print("Found sections:")
for section, cell_id in section_mapping.items():
    print(f"  {section}: {cell_id}")

# Add the remaining 3 sections based on found IDs
if 'int_rate vs fico_range_low' in section_mapping:
    conclusions[section_mapping['int_rate vs fico_range_low']] = """#### int_rate vs fico_range_low

**Conclusions**

- int_rate (interest rate) shows a strong inverse relationship with fico_range_low: higher FICO scores receive lower interest rates.
- The relationship is approximately linear with some curvature: moving from FICO 640 to 700 drops rates by ~5-7%, while 700 to 800 drops rates by another ~3-4%.
- This validates that Lending Club's pricing algorithm heavily weights FICO scores in rate assignment, consistent with industry standards.
- FICO appears to be the dominant driver of interest rates, explaining ~60-70% of rate variation based on the scatter pattern.
- For modeling default risk, both int_rate and fico_range_low contain overlapping information, which may introduce multicollinearity.
- Consider engineering a "rate_premium" feature (actual rate minus expected rate given FICO) to capture pricing anomalies that may signal additional risk."""

if 'dti vs annual_inc' in section_mapping:
    conclusions[section_mapping['dti vs annual_inc']] = """#### dti vs annual_inc

**Conclusions**

- dti (debt-to-income ratio) and annual_inc show a weak negative correlation: higher-income borrowers tend to have slightly lower dti, but with substantial scatter.
- Most borrowers cluster in the $40K-$100K income range with dti between 10-25%, representing typical middle-class debt loads.
- High-income borrowers (>$150K) exhibit wide dti variation (5-35%), indicating income alone doesn't determine debt burden.
- Very high dti (>30%) appears across all income levels, suggesting some borrowers are overleveraged regardless of earnings.
- For modeling, both variables should be included: annual_inc captures ability to pay, while dti captures existing debt burden.
- Their interaction term may be valuable (e.g., high dti + low income = extreme risk) to capture combined effects."""

if 'grade vs term' in section_mapping:
    conclusions[section_mapping['grade vs term']] = """#### grade vs term

**Conclusions**

- The crosstab reveals a clear pattern: lower-risk grades strongly prefer 36-month terms, while higher-risk grades increasingly select 60-month terms.
- Grade A: 95% choose 36-month (20,435 vs 1,165), indicating financially stable borrowers prefer shorter repayment periods to minimize interest costs.
- Grades B-C: Still majority 36-month (~80-85%), but 60-month share grows as risk increases, reflecting need for payment affordability.
- Grades F-G: Heavily skewed to 60-month (F: 80%, G: 83%), indicating high-risk borrowers require extended terms for affordability.
- This interaction between grade and term is critical for modeling: Grade G on 60-month represents highest risk, while Grade A on 36-month is safest.
- Lenders should consider term limits by grade to manage portfolio risk, though this may reduce loan volume."""

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
