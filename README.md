# Apple Project Analysis

This project contains SQL queries for analyzing Apple sales data.

## Database Schema

The project database consists of five main tables that store information about product categories, products, stores, sales transactions, and warranty claims.


### 1. Category
Stores product category information.

| Column Name   | Description |
|--------------|-------------|
| category_id  | Unique identifier for each category |
| category_name| Name of the product category |

---

### 2. Products
Contains details about products.

| Column Name  | Description |
|-------------|-------------|
| product_id  | Unique identifier for each product |
| product_name| Name of the product |
| category_id | Category identifier (Foreign Key → Category) |
| launch_date | Product launch date |
| price       | Product price |

---

### 3. Stores
Contains information about store locations.

| Column Name | Description |
|------------|-------------|
| stores_id  | Unique identifier for each store |
| store_name | Name of the store |
| city       | City where the store is located |
| country    | Country where the store is located |

---

### 4. Sales
Stores sales transaction data.

| Column Name | Description |
|------------|-------------|
| sale_id    | Unique identifier for each sale |
| sale_date  | Date of the sale |
| store_id   | Store identifier (Foreign Key → Stores) |
| product_id | Product identifier (Foreign Key → Products) |
| quantity   | Number of units sold |

---

### 5. Warranty
Contains warranty claim information.

| Column Name   | Description |
|--------------|-------------|
| claim_id     | Unique identifier for each claim |
| claim_date   | Date the claim was filed |
| sale_id      | Sale identifier (Foreign Key → Sales) |
| repair_status| Status of the warranty repair |

---

## How to Run
1. Clone the repo: `git clone https://github.com/BinEmad7/apple_project_analysis.git`
2. Open the SQL file in your preferred database.




# --- ANALYSIS & EXPORT SCRIPT ---
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# 1. Final Data Formatting
data['sale_date'] = pd.to_datetime(data['sale_date'], dayfirst=True)
data['Revenue'] = data['Price'] * data['quantity']
data['YearQuarter'] = data['sale_date'].dt.to_period('Q').astype(str)

# 2. Strategic Insight: Revenue Trend
plt.figure(figsize=(10, 5))
revenue_trend = data.groupby('YearQuarter')['Revenue'].sum().reset_index()
sns.lineplot(data=revenue_trend, x='YearQuarter', y='Revenue', marker='o', color='#2ecc71', linewidth=2)
plt.title('Business Growth: Total Revenue by Quarter', fontsize=14)
plt.grid(axis='y', linestyle='--', alpha=0.6)
plt.savefig('revenue_trend.png', dpi=300) # Exporting for GitHub
plt.show()

# 3. Operational Insight: Warranty Claims by Store
plt.figure(figsize=(10, 6))
claims_only = data.dropna(subset=['claim_id'])
sns.countplot(data=claims_only, y='Store_Name', palette='magma', order=claims_only['Store_Name'].value_counts().index)
plt.title('Operational Risk: Warranty Claim Volume by Store', fontsize=14)
plt.xlabel('Number of Claims')
plt.tight_layout()
plt.savefig('warranty_claims.png', dpi=300) # Exporting for GitHub
plt.show()

# 4. Extracting "Executive Summary" numbers
top_store = data.groupby('Store_Name')['Revenue'].sum().idxmax()
total_rev = data['Revenue'].sum()
print(f"--- PORTFOLIO STATS ---")
print(f"Total Revenue: ${total_rev:,.2f}")
print(f"Top Store: {top_store}")

## Author
Ahmed Elsharef
