# Root Cause Analysis: 97.3% View-to-Cart Drop-Off

## Overview

The overall funnel shows a 97.3% drop-off from view to cart. This report presents three hypotheses for the root cause, each grounded in the data, with an alternative explanation and an experiment to distinguish between them.

---

## Hypothesis 1: Product Discovery Gap

**What the data shows**

Users who view only 1 item per session convert at 1.4%, while users who view 15+ items convert at 44.7% — a 33x gap. The Browser segment (97% of all users) averages only 1.5 items viewed per session.

**What this suggests**

Users who see more of the catalog are better able to find items relevant to them. The primary conversion lever is product discoverability — getting users to engage with more of the catalog before leaving — not the cart or checkout experience.

**Alternative explanation**

High-intent users may naturally browse more AND buy more. In that case, session depth is a symptom of purchase intent rather than a cause — showing more items to low-intent users wouldn't move conversion.

**How you'd distinguish**

Run an A/B test adding a recommendation carousel ("users also viewed") to product pages. If increasing items viewed per session causally drives conversion, the treatment group should show a higher view→cart rate independent of prior intent signals.

---

## Hypothesis 2: Category-Specific Product Quality Gap

**What the data shows**

View-to-cart rates vary significantly across product categories. Low-converting categories account for a disproportionate share of total views, dragging the aggregate rate down.

**What this suggests**

The drop-off is not uniform across the catalog. Certain categories may have thinner product descriptions, fewer images, or weaker social proof — causing users to view but not engage enough to add to cart. This points to a product page quality problem concentrated in specific verticals, not a site-wide UX issue.

**Alternative explanation**

Low-converting categories may simply contain inherently lower-intent product types (e.g. browsing categories vs. buying categories). The category itself — not page quality — drives the behavior, and improving those pages would have limited impact.

**How you'd distinguish**

Audit the bottom 5 categories by view→cart rate for page quality signals (image count, description length, review volume). If low-converting categories systematically have weaker content, run a content enrichment test — add images and descriptions to a subset of items in those categories and measure view→cart rate.

---

## Hypothesis 3: Consideration Journey Gap

**What the data shows**

54.6% of purchasers required multiple sessions before converting, with a median of 2 sessions. Researchers (multi-session buyers) averaged 8.5 sessions before purchasing. Decisive Buyers (≤2 sessions) represent only 0.6% of all users.

**What this suggests**

A significant portion of users are genuinely interested but not ready to buy on first visit. They leave and don't return because there is no re-engagement mechanism. The problem is not checkout friction — it is the absence of a consideration journey infrastructure (email capture, wishlist, retargeting).

**Alternative explanation**

Multi-session behavior may reflect price sensitivity rather than consideration time — users leaving to comparison shop and returning when ready. In that case, the fix is pricing or promotions, not re-engagement.

**How you'd distinguish**

Implement email capture with a "save for later" prompt on product pages. Measure whether users who opt in return and convert at higher rates than the baseline multi-session cohort. If re-engagement emails drive return visits that convert, the consideration journey gap hypothesis is confirmed.

---

## Experiment Design: Hypothesis 1 (Recommendation Carousel)

```
Experiment: Recommendation Module on Product Pages
Hypothesis: Showing "users also viewed" recommendations will increase items viewed
            per session, which will increase view→cart rate.

Treatment:  Add 6-item recommendation carousel below product description
Control:    Current product page (no recommendations)

Primary metric:    View → Add-to-Cart rate
Secondary metrics: Items viewed per session, session duration, revenue per visitor

Minimum detectable effect: 0.5pp improvement in view→cart rate (2.69% → 3.19%)
Statistical power: 80%
Significance level: 95%

Sample size calculation:
  Baseline conversion rate: 2.69%
  MDE: 0.5pp
  Required n per arm: ~18,000 users
  At current traffic: ~7–10 days runtime

Guardrail metrics: Cart→purchase rate (should not decrease), page load time
```

---

## Summary

| Hypothesis | Root Cause | Recommended Intervention |
|---|---|---|
| Product Discovery Gap | Users see too few items per session | Recommendation carousel on product pages |
| Category Quality Gap | Low-converting categories have weak content | Content enrichment test in bottom categories |
| Consideration Journey Gap | No re-engagement mechanism for returning users | Email capture + retargeting flow |

The highest-leverage intervention is the recommendation carousel — it targets the Browser segment (97% of users) and is directly testable with a clean A/B design.
