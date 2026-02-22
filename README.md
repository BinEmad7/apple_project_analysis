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

## Author
Ahmed Elsharef
