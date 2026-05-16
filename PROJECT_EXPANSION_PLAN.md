# Funnel Analysis — Project Expansion Plan

**Goal:** Transform the project from a problem description ("97% drop-off at view→cart") into a root-cause analysis with defensible hypotheses, behavioral evidence, and experiment designs. This closes the interview gap where conversation stalls after the initial funnel numbers.

**Estimated time:** 10–15 hours across ~3 sessions  
**New resume bullets:** 2–3  
**Primary payoff:** Ability to answer "why is this happening?" and "what would you do about it?" with data

---

## Phase 1 — Data Enrichment
**Time: 1–2 hours**  
**Notebook: `data_enrichment.ipynb`**

The RetailRocket dataset on Kaggle ships with three files you don't currently have. Download all of them:

- `item_properties_part1.csv`
- `item_properties_part2.csv`  
- `category_tree.csv`

### What these files contain

The item properties files are in long format: each row is `(timestamp, itemid, property, value)`. The key properties to extract are `categoryid` and `available` (in-stock status). The category tree maps each `categoryid` to its parent, giving you a hierarchy you can flatten into top-level and sub-level categories.

### What to build

Concatenate both item property files, then pivot to get one row per item with `categoryid` and `available` as columns. Join the category tree to get a `parent_category` column. Finally, merge this enriched item table onto your existing `events.csv` on `itemid`.

```python
# Rough structure
props = pd.concat([pd.read_csv('item_properties_part1.csv'), 
                   pd.read_csv('item_properties_part2.csv')])

# Keep only the most recent property value per item
props = props.sort_values('timestamp').drop_duplicates(['itemid', 'property'], keep='last')
props_wide = props.pivot(index='itemid', columns='property', values='value').reset_index()

category_tree = pd.read_csv('category_tree.csv')
# Join tree to get parent category
props_wide = props_wide.merge(category_tree, on='categoryid', how='left')

# Merge onto events
df = df.merge(props_wide[['itemid', 'categoryid', 'parentid', 'available']], 
              on='itemid', how='left')
```

### Watch out for
The item properties files use a sparse, changelog-style format — an item's category may appear multiple times as it changed over time. Always take the most recent value. Expect ~15–20% of event rows to have no category match (items with no property data); document this and exclude from category-level analyses rather than imputing.

### Output
A merged dataframe saved to `data/processed/events_enriched.csv` that all subsequent notebooks read from.

---

## Phase 2 — Category-Level Analysis
**Time: 2–3 hours**  
**Notebook: `category_analysis.ipynb`**

This is the highest-impact addition. It lets you answer "why" with specificity: the drop-off isn't uniform — it's concentrated in certain product categories, which immediately points to category-specific explanations rather than a generic site-wide UX problem.

### What to build

**2a. Funnel by top-level category**

For each parent category, calculate view→cart rate and cart→purchase rate. You're looking for variance — if all categories convert similarly, the problem is site-wide; if a few categories are dragging the average down, you've isolated the problem.

```python
category_funnel = df.groupby(['parentid', 'event']).size().unstack(fill_value=0)
category_funnel['view_to_cart'] = category_funnel['addtocart'] / category_funnel['view']
category_funnel['cart_to_purchase'] = category_funnel['transaction'] / category_funnel['addtocart']
```

Filter to categories with at least 1,000 views for statistical credibility. Visualize as a scatter plot with view→cart on x-axis and cart→purchase on y-axis — you'll likely see distinct clusters (high browse/low purchase categories vs. high intent categories).

**2b. Availability effect**

Check whether items marked `available=0` (out of stock) appear in view events at meaningful rates. If users are frequently viewing unavailable items, that's a direct explanation for the view→cart gap — users can't add what they can't buy. This is a concrete, actionable finding.

```python
availability_funnel = df.groupby(['available', 'event']).size().unstack(fill_value=0)
```

**2c. Category concentration analysis**

What share of total views come from the bottom 20% of categories by conversion rate? If low-converting categories account for 40%+ of traffic, you've found a prioritization opportunity — deprioritize or fix those categories before trying to improve the overall funnel.

### Interview talking point this unlocks

> "When I broke conversion down by product category, I found that the top 5 categories by view volume had a view→cart rate of X%, while the bottom 5 had Y% — a Zx difference. This told me the problem wasn't the checkout flow or cart UX, it was product-page-level engagement concentrated in specific verticals. That's a very different fix than a global UX redesign."

---

## Phase 3 — Session Reconstruction
**Time: 2–3 hours**  
**Notebook: `session_analysis.ipynb`**

Sessions are the unit of user intent. A user browsing in the morning and returning that evening is not the same behavior as two hours of continuous browsing — these are different psychological states. Reconstructing sessions lets you analyze behavior at the right level of granularity.

### What to build

**3a. Session definition and reconstruction**

Industry standard: a new session begins after 30 minutes of inactivity. Sort events by user and timestamp, then flag session boundaries.

```python
df = df.sort_values(['visitorid', 'timestamp'])
df['time_since_last'] = df.groupby('visitorid')['timestamp'].diff()
df['new_session'] = (df['time_since_last'] > pd.Timedelta(minutes=30)) | df['time_since_last'].isna()
df['session_id'] = df.groupby('visitorid')['new_session'].cumsum()
df['global_session_id'] = df['visitorid'].astype(str) + '_' + df['session_id'].astype(str)
```

**3b. Session-level feature engineering**

Aggregate to one row per session:

| Feature | Description |
|---|---|
| `items_viewed` | Distinct items viewed in session |
| `session_duration_min` | Time from first to last event |
| `events_in_session` | Total events |
| `reached_cart` | Boolean — any addtocart in session |
| `reached_purchase` | Boolean — any transaction in session |
| `categories_browsed` | Distinct parent categories viewed |
| `session_number` | Which session is this for the user (1st, 2nd, etc.) |

**3c. Conversion rate by session depth**

This is the money analysis. Calculate view→cart rate by number of items viewed per session. Hypothesis: users who view more items per session are more engaged and convert at higher rates — or alternatively, they're confused and browsing without intent.

```python
session_df['items_viewed_bucket'] = pd.cut(session_df['items_viewed'], 
                                            bins=[0,1,3,7,15,999], 
                                            labels=['1','2-3','4-7','8-15','15+'])
conversion_by_depth = session_df.groupby('items_viewed_bucket')['reached_cart'].mean()
```

**3d. Multi-session journey analysis**

What fraction of purchasers needed more than one session? This tells you whether purchase intent is formed in a single visit or through a consideration journey. If 60%+ of purchasers return across multiple sessions, that's evidence for a trust/familiarity gap rather than a friction problem — you'd invest in remarketing and email capture, not button redesigns.

```python
user_sessions = session_df.groupby('visitorid').agg(
    total_sessions=('session_id', 'nunique'),
    made_purchase=('reached_purchase', 'max')
)
```

### Interview talking point this unlocks

> "After reconstructing sessions, I found that X% of purchasers returned across multiple sessions before buying, with a median of Y sessions. This pointed to a consideration journey problem — users needed multiple touchpoints before committing — rather than a checkout friction problem. That insight shifts the recommendation from 'simplify the cart page' to 'implement email capture for return-visit remarketing.'"

---

## Phase 4 — Behavioral Segmentation
**Time: 2–3 hours**  
**Notebook: `user_segmentation.ipynb`**

Segmentation answers the question every product analytics interviewer is listening for: "who are your users, and how do they behave differently?" It also sets up the experiment design in Phase 5 by identifying which segments to target.

### What to build

Use rule-based segmentation rather than clustering. Rule-based is easier to explain in an interview, produces segments with intuitive business names, and doesn't require you to justify a choice of k.

**4a. Build user-level features**

Aggregate session data to the user level:

```python
user_df = session_df.groupby('visitorid').agg(
    total_sessions=('session_id', 'nunique'),
    total_items_viewed=('items_viewed', 'sum'),
    avg_items_per_session=('items_viewed', 'mean'),
    total_categories=('categories_browsed', 'sum'),
    days_active=('session_date', 'nunique'),
    made_purchase=('reached_purchase', 'max'),
    reached_cart=('reached_cart', 'max')
)
```

**4b. Define four segments**

| Segment | Rule | Description |
|---|---|---|
| **Decisive Buyers** | `reached_purchase=True` AND `total_sessions <= 2` | Converted quickly, high intent |
| **Researchers** | `reached_purchase=True` AND `total_sessions > 2` | Needed multiple visits before committing |
| **Cart Abandoners** | `reached_cart=True` AND `reached_purchase=False` | Made it to cart, didn't complete |
| **Browsers** | `reached_cart=False` | Never added to cart |

**4c. Profile each segment**

For each segment, calculate: size (n and %), avg items viewed per session, avg sessions, avg categories browsed, and conversion rate. The contrast between Browsers and Cart Abandoners is especially important — Browsers represent a product discovery problem (they never found what they wanted), while Cart Abandoners represent a checkout confidence problem (they found it but didn't pull the trigger).

**4d. Segment-level funnel**

Show the funnel separately for each segment. This is a powerful visual for an interview — you're showing that the "overall" funnel is actually four different behaviors averaged together, each requiring a different intervention.

### Interview talking point this unlocks

> "When I segmented users, I found that Browsers — people who never added to cart — account for 97% of the user base and average only 1.4 items viewed per session. This suggests they're not deeply engaged with product pages — they're scanning and leaving. The fix for this group is product discoverability (better recommendation modules, clearer category navigation), not cart optimization."

---

## Phase 5 — Root Cause Synthesis + Experiment Design
**Time: 1–2 hours**  
**Notebook: `root_cause_and_experiments.ipynb`** (or add as a final section to the segmentation notebook)

This is where you turn analysis into a product analytics portfolio piece rather than just an analytics exercise. Every finding from Phases 2–4 should map to a falsifiable hypothesis and a testable experiment.

### Root cause write-up structure

For each hypothesis, write:
- **What the data shows** (quantified)
- **What this suggests** (the mechanism)
- **Alternative explanation** (intellectual honesty)
- **How you'd distinguish between them** (experiment design)

**Hypothesis 1: Product discovery gap (from session depth analysis)**
> Users who view only 1 item per session convert at X% vs Y% for users who view 5+ items. This suggests that users who see more of the catalog are better able to find relevant items — the problem is surface area of discovery, not product page quality.

**Hypothesis 2: Category-specific product quality gap (from category analysis)**
> Categories A, B, C account for Z% of total views but only W% of cart adds. These categories may have thinner product descriptions, fewer images, or weaker social proof than top-converting categories.

**Hypothesis 3: Consideration journey gap (from multi-session analysis)**
> X% of purchasers made 3+ sessions before buying. A significant portion of Browsers may be genuinely interested but not ready to buy on first visit — they leave and don't return because there's no mechanism to re-engage them.

### Experiment design (for each hypothesis)

Structure each experiment with these components:

```
Experiment: Recommendation Module on Product Pages
Hypothesis: Showing "users also viewed" recommendations will increase items viewed 
            per session, which will increase view→cart rate.

Treatment: Add 6-item recommendation carousel below product description
Control: Current product page (no recommendations)

Primary metric: View → Add-to-Cart rate
Secondary metrics: Items viewed per session, session duration, revenue per visitor

Minimum detectable effect: 0.5pp improvement in view→cart rate (from 2.69% to 3.19%)
Statistical power: 80%, significance level: 95%

Sample size calculation:
  Baseline conversion: 2.69%
  MDE: 0.5pp
  Required n per arm: ~X (calculate using proportions z-test)
  At current traffic: ~X days runtime

Guardrail metrics: Cart→purchase rate (shouldn't decrease), page load time
```

Including even one sample size calculation in your project signals quantitative rigor that most candidates skip entirely.

---

## Phase 6 — Cleanup and Documentation
**Time: 1–2 hours**

### Notebook narrative

Rename and reorder notebooks to tell a coherent story:
```
01_data_exploration.ipynb        (existing)
02_data_enrichment.ipynb         (new — Phase 1)
03_funnel_analysis.ipynb         (existing, lightly updated)
04_category_analysis.ipynb       (new — Phase 2)
05_session_analysis.ipynb        (new — Phase 3)
06_user_segmentation.ipynb       (new — Phase 4)
07_root_cause_experiments.ipynb  (new — Phase 5)
```

Each notebook should open with a 3-sentence summary cell: what question this notebook answers, what the key finding is, and what notebook comes next.

### README update

Update the Key Findings section to reflect the full story:

1. **What** — 97% drop-off at view→cart (existing)
2. **Where** — Concentrated in categories X, Y, Z (new)
3. **Who** — 94% of users are Browsers averaging only 1.4 items/session (new)
4. **Why** — Evidence points to product discovery gap and consideration journey, not checkout friction (new)
5. **What to do** — Three experiments with sample size calculations (new)

### Updated resume bullets

Replace or augment your current bullets with:

- "Identified root cause of 97% view-to-cart drop-off through category-level funnel segmentation (2.7M events, 235K items across X categories), isolating conversion gap to specific product verticals rather than site-wide UX"
- "Reconstructed user sessions from raw event logs to show X% of purchasers required 3+ sessions before converting, surfacing a consideration-journey gap and motivating retargeting experiment design"
- "Segmented 1.4M users into four behavioral profiles; found Browser segment (94% of users) averaged 1.4 items viewed per session, pointing to product discoverability as primary conversion lever"

---

## Summary Timeline

| Phase | Work | Time |
|---|---|---|
| 1 | Download Kaggle files, clean and merge category data | 1–2 hrs |
| 2 | Category-level funnel + availability analysis | 2–3 hrs |
| 3 | Session reconstruction + session depth analysis | 2–3 hrs |
| 4 | Behavioral segmentation (4 user types) | 2–3 hrs |
| 5 | Root cause write-up + experiment designs | 1–2 hrs |
| 6 | Notebook cleanup, README, resume bullets | 1–2 hrs |
| **Total** | | **9–15 hrs** |

## Future Extensions (Beyond Phase 6)

These require pulling additional properties from the item properties files (add them to the `isin` filter in Phase 1):

- **Price sensitivity analysis** — extract the `price` property and bucket items into price tiers. Do higher-priced items have lower view→cart rates? This could explain category-level variance found in Phase 2 and motivate a price-display experiment.

- **Brand-level conversion** — extract the `brand` property and run the same category-level funnel (Phase 2) at the brand level. Some brands may have stronger recognition and convert better even within the same category.

- **Item age effect** — the properties files are timestamped, so you can approximate when an item was first listed. Do newer listings convert worse (less reviews, less trust)?

- **Availability over time** — instead of just the most recent `available` value, track how often items flip between in-stock and out-of-stock. High-churn availability items may frustrate repeat visitors.

- **Price change effect** — items with price reductions between sessions may be a driver of multi-session purchases (Phase 3). A user who viewed an item, left, and returned after a price drop would be strong evidence for price-anchoring behavior.

---

## What Makes This Interview-Ready

The project is done when you can answer all of these without hesitation:

- "Walk me through your funnel." *(existing — you can do this)*
- "Why do you think view-to-cart is so low?" *(Phase 2 + 3 answer this)*
- "Who are the users that never convert?" *(Phase 4 answers this)*
- "What would you do to fix it?" *(Phase 5 answers this)*
- "How would you measure success?" *(Phase 5 experiment design)*
- "How long would your experiment need to run?" *(Sample size calc in Phase 5)*
- "What surprised you in the data?" *(Availability analysis, multi-session journey)*
