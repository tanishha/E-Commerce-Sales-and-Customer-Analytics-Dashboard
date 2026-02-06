# E-Commerce Sales and Customer Analytics Dashboard

## Overview
This project demonstrates advanced database optimization and business intelligence techniques by building a comprehensive analytics dashboard for e-commerce data. It combines SQL query optimization, database indexing strategies, and Power BI visualizations to deliver actionable insights on sales performance, customer behavior, and seller metrics. The project includes performance analysis and comparison of baseline and optimized SQL queries on a real-world e-commerce dataset.

## Project Objectives
- Import and process e-commerce transaction data
- Establish baseline query performance metrics
- Implement indexing strategies to improve query performance
- Compare query execution performance before and after optimization
- Analyze and document performance improvements

## Project Structure

### Root Files
- **Data Importing.ipynb** - Jupyter notebook for loading and preprocessing the dataset
- **Indexing.ipynb** - Notebook documenting database indexing implementation
- **Optimization.ipynb** - Notebook covering query optimization strategies
- **Transaction.ipynb** - Notebook analyzing transaction data and patterns

### Dataset Folder
Contains the raw e-commerce data in CSV format:
- `olist_customers_dataset.csv` - Customer information
- `olist_orders_dataset.csv` - Order details
- `olist_order_items_dataset.csv` - Individual items within orders
- `olist_order_payments_dataset.csv` - Payment information
- `olist_products_dataset.csv` - Product catalog
- `olist_sellers_dataset.csv` - Seller information

### Queries Folder
SQL query files for performance testing:
- **Baseline_Queries.sql** - Standard queries without optimization
- **Optimized_Queries.sql** - Improved queries with optimization techniques
- **Index.sql** - Index creation and definition statements
- **Analyze_Queries_Plan_Baseline.sql** - Query execution plans for baseline queries
- **Analyze_Queries_Plan_Optimized.sql** - Query execution plans for optimized queries

### Results Files
Performance comparison results:
- **final_baseline_results.csv** - Performance metrics for baseline queries
- **final_optimized_results.csv** - Performance metrics for optimized queries
- **final_baseline_indexed_results.csv** - Performance metrics for baseline with indexing
- **final_optimized_indexed_results.csv** - Performance metrics for optimized with indexing
- **Statistics_Result.csv** - Summary statistics and performance analysis

## Workflow

1. **Data Importing** - Load and prepare the e-commerce dataset
2. **Baseline Analysis** - Run queries without optimization and record metrics
3. **Indexing** - Create database indexes on frequently queried columns
4. **Optimization** - Implement query optimizations (restructuring, better joins, etc.)
5. **Performance Comparison** - Execute all query variants and compare results
6. **Analysis** - Evaluate improvements and document findings

## Key Metrics
- Query execution time
- Query plan efficiency
- Impact of indexing on performance
- Optimization effectiveness

## Technologies Used
- **Python** (Jupyter Notebooks) - Data processing and analysis
- **SQL** - Complex query design and optimization
- **Power BI** - Interactive dashboard and business intelligence visualizations
- **Database Indexing** - Performance optimization techniques
- **Query Execution Plan Analysis** - Performance diagnostics

## Usage
1. Start with **Data Importing.ipynb** to load the dataset
2. Review **Baseline_Queries.sql** to understand the base queries
3. Check **Indexing.ipynb** for index implementation details
4. Run optimized queries from **Optimized_Queries.sql**
5. Analyze results in the CSV output files for performance comparison

## Results Summary

### Performance Overview
The optimization efforts resulted in **significant performance improvements** across all 10 complex queries tested. Each query was executed 25 times to ensure statistical validity.

### Key Findings

#### Top Optimization Winners
| Query | Baseline (sec) | Optimized (sec) | Speedup | Improvement |
|-------|---|---|---|---|
| **Compare Seller Revenue Against City Average** | 83.50 | 0.46 | **83.04x** | **99.5%**  |
| **Customer Segmentation Analysis** | 2.73 | 1.28 | **2.13x** | **53.1%** |
| **Top Customer & Seller Cities by Volume** | 1.95 | 0.74 | **2.64x** | **62.3%** |
| **Average Delivery Time per Product** | 2.48 | 1.24 | **2.00x** | **50.2%** |
| **Total Revenue by Customer** | 3.04 | 2.11 | **1.44x** | **30.7%** |
| **Co-Purchased Product Pairs** | 1.28 | 0.76 | **1.68x** | **40.3%** |

#### Performance Metrics (All Queries)
- **Average Speedup**: 1.46x faster
- **Total Time Saved**: 9.49 seconds per full query run
- **Best Case**: 99.5% improvement
- **Worst Case**: 3.2% improvement (still statistically significant)

### Statistical Validation
All performance improvements were validated with statistical significance:
- **Confidence Level**: 95% confidence intervals
- **Average p-value**: < 0.01 (highly significant)
- **Consistency**: Low standard deviation across the 25 runs

### Optimization Techniques Applied
1. **Query Restructuring** - Rewrote complex joins and subqueries
2. **Indexing Strategy** - Strategic index placement on frequently queried columns
3. **Join Optimization** - Optimized join order for better execution plans
4. **Aggregation Efficiency** - Improved GROUP BY and aggregation queries


### Conclusion
The optimization project achieved substantial performance gains, with the most complex query improving by **99.5%**. Average query execution time was reduced by **1.46x**, translating to significant improvements in system responsiveness and database efficiency.

---
*This project demonstrates practical database optimization techniques and best practices for improving query performance through indexing and query restructuring.*
