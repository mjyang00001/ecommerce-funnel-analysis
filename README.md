# Ecommerce Conversion Funnel Analysis

Data driven analysis of 2.7M ecommerce events to identify conversion bottlenecks and quantify revenue opportunities.

## Key Findings

**Primary Issue: 97.3% Browse to Cart Drop off**

Only 2.69% of viewers add items to cart (vs. 5 10% industry benchmark). This represents 1.36M users lost at the View → Cart stage. Interestingly, checkout performance is strong with 31.07% cart to purchase conversion, which is above the 25 35% industry benchmark.

**Root Cause**

The problem is not cart abandonment it's product page engagement. Users who add to cart convert well, but 97% never make it that far.

**Revenue Opportunity**

Improving View → Cart conversion from 2.69% to just 5% (industry standard) would generate:
  32,000+ additional cart adds
  10,000+ additional purchases
  85% revenue increase with same traffic volume

## Business Recommendations

### 1. Optimize Product Pages (High Impact)
  Improve product imagery and descriptions
  Add social proof (reviews, ratings, "bestseller" badges)
  Implement urgency triggers (limited stock indicators, time limited offers)
  A/B test "Add to Cart" button placement and copy

### 2. Leverage Timing Insights
The data shows median conversion time is 20 minutes from first view to purchase, with 50% of users adding to cart within 3 minutes of viewing. This suggests implementing retargeting campaigns for users who viewed but didn't add to cart within 1 hour could capture interested but hesitant shoppers.

### 3. Product Portfolio Optimization
Top 10 items convert at 8 15% (3 6x the overall average), while bottom 10 items convert at less than 0.1%. Analyzing top performers for common attributes and either fixing or removing underperformers could significantly improve overall conversion rates.

## Analysis Overview

### Dataset
  2,756,101 events across 1,407,580 unique users
  137 day period (May   September 2015)
  Event types: View, Add to Cart, Transaction

### Methodology
1. **Exploratory Data Analysis**: Examined time patterns, validated data quality, analyzed event distribution
2. **Funnel Analysis**: Calculated user level conversion rates and identified drop off points
3. **SQL Implementation**: Replicated analysis in SQL for production scalability
4. **Timing Analysis**: Measured time to conversion by funnel stage
5. **Item Performance**: Benchmarked product level conversion rates
6. **Impact Modeling**: Quantified revenue opportunity from optimization

### Key Metrics

| Metric | Current | Industry Benchmark | Status |

| View → Cart | 2.69% | 5 10% | Below |
| Cart → Purchase | 31.07% | 25 35% | Good |
| Overall Conversion | 0.83% | 2 3% | Below |

## Technical Stack

  **Python**: pandas, numpy, matplotlib, seaborn, plotly

  **SQL**: duckdb
  
  **Analysis**: Statistical analysis, funnel metrics, conversion rate optimization
  
  **Visualization**: Multi stage funnel charts, heatmaps, distribution analysis

## Project Structure

```
ecommerce funnel analysis/
├── data/
│   ├── events.csv              # Raw event data
│   └── processed/              # Cleaned data
├── notebooks/
│   ├── 01_data_exploration.ipynb
│   └── 02_funnel_analysis.ipynb
├── src/                        # Reusable Python functions
├── sql/                        # SQL queries
│   ├── funnel_queries.sql      # 6 production-ready queries (funnel metrics, cohorts, retention
├── requirements.txt
└── README.md
```

## How to Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/mjyang00001/ecommerce funnel analysis.git
   cd ecommerce funnel analysis
   ```

2. **Set up environment**
   ```bash
   python  m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install  r requirements.txt
   ```

3. **Run analysis notebooks**
   ```bash
   jupyter notebook
   ```
     Start with `notebooks/01_data_exploration.ipynb`
     Then run `notebooks/02_funnel_analysis.ipynb`

## Results Summary

This analysis demonstrates end to end analytical capabilities: identifying specific problems through data exploration, quantifying business impact, and delivering actionable recommendations prioritized by expected ROI. The findings pinpoint the exact stage of user drop off and calculate the specific revenue opportunity, providing clear direction for product and marketing teams.

## Future Work

  Cohort analysis to track user behavior trends over time
  User segmentation using RFM analysis and clustering techniques
  Predictive modeling for purchase probability
  Interactive dashboard for stakeholder exploration

   

**Author:** Matthew Yang
**Date:** November 2025
