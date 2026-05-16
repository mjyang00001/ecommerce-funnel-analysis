# E-Commerce Conversion Funnel Analysis

Data-driven root cause analysis of 2.7M e-commerce events across 1.4M users to identify why 97.3% of viewers never add to cart — and what to do about it.

---

## The Story

### What
97.3% of viewers never add to cart. View→cart rate is 2.69% vs. a 5–10% industry benchmark. Cart→purchase is strong at 31%, meaning the problem is upstream — users are leaving before they engage, not after.

### Where
The drop-off is not uniform. Conversion rates vary 30x across product categories. More critically, 60% of all views are on out-of-stock items, which convert at 1.7% vs. 4.5% for in-stock items. Availability alone is a direct, structural driver of the overall rate.

### Who
Segmenting 1.4M users into four behavioral profiles reveals the aggregate funnel is four different behaviors averaged together:

| Segment | Users | % of Total | Avg Items/Session | View→Cart | Cart→Purchase |
|---|---|---|---|---|---|
| Browser | 1,368,715 | 97.2% | 1.5 | ~0% | — |
| Cart Abandoner | 27,146 | 1.9% | 4.1 | 28% | 0% |
| Decisive Buyer | 7,920 | 0.6% | 2.5 | 33% | 100% |
| Researcher | 3,799 | 0.3% | 30.3 | 12% | 71% |

Browsers — 97% of users — average 1.5 items viewed per session and almost never add to cart. They are not failing to complete checkout; they are never engaging with the catalog deeply enough to find something they want.

### Why
Three hypotheses, each grounded in the data:

1. **Product discovery gap** — Users viewing 15+ items per session convert at 44.7% vs. 1.4% for single-item sessions (33x gap). Most users never browse deeply enough to find relevant items.
2. **Category-specific quality gap** — Low-converting categories may have thinner content (fewer images, weaker descriptions, less social proof) relative to high-converting ones.
3. **Consideration journey gap** — 45.3% of purchasers needed more than one session before buying. There is no re-engagement mechanism to bring interested users back.

### What to Do
See `reports/root_cause_analysis.md` for full experiment designs. The highest-leverage intervention is a recommendation carousel on product pages — it targets the Browser segment (97% of users) and is directly testable with a clean A/B design with ~18,000 users per arm and ~7–10 days runtime.

---

## Key Metrics

| Metric | Value | Industry Benchmark | Status |
|---|---|---|---|
| View → Cart | 2.69% | 5–10% | Below |
| Cart → Purchase | 31.07% | 25–35% | Good |
| Overall Conversion | 0.83% | 2–3% | Below |
| Cohort stability | ±0.6pp week-over-week | — | Structural, not seasonal |

---

## Notebooks

| Notebook | Question |
|---|---|
| `01_data_exploration.ipynb` | What does the raw data look like? |
| `02_data_enrichment.ipynb` | How do we add category and availability data? |
| `03_funnel_analysis.ipynb` | Where are users dropping off and what's the revenue opportunity? |
| `04_category_analysis.ipynb` | Is the drop-off uniform across categories? |
| `05_session_analysis.ipynb` | Does browsing depth predict conversion? |
| `06_cohort_analysis.ipynb` | Have rates changed over time? |
| `07_user_segmentation.ipynb` | Who are the users that never convert? |

---

## Reports

- `reports/root_cause_analysis.md` — Three root cause hypotheses with experiment designs and sample size calculations

---

## Project Structure

```
funnel-analysis/
├── data/
│   ├── events.csv
│   ├── item_properties_part1.csv
│   ├── item_properties_part2.csv
│   ├── category_tree.csv
│   └── processed/
│       ├── events_enriched.csv
│       └── sessions.csv
├── notebooks/
│   ├── 01_data_exploration.ipynb
│   ├── 02_data_enrichment.ipynb
│   ├── 03_funnel_analysis.ipynb
│   ├── 04_category_analysis.ipynb
│   ├── 05_session_analysis.ipynb
│   ├── 06_cohort_analysis.ipynb
│   └── 07_user_segmentation.ipynb
├── reports/
│   └── root_cause_analysis.md
├── sql/
├── src/
└── requirements.txt
```

## How to Run

```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
jupyter notebook
```

Run notebooks in order starting from `01_data_exploration.ipynb`.

---

**Author:** Matthew Yang
