# 📦 E-Commerce Supply Chain & Operational Logistics Analytics

An end-to-end data analytics and ETL project analyzing 99K+ Brazilian e-commerce transaction records from the Olist dataset. This project evaluates customer purchasing behavior, regional supply chain performance, and delivery delay impacts on customer review scores.

---

### 🎯 Key Analytics & Business Insights

- **Customer Tracking & Retention Logic:** Engineered data transformations using `customer_unique_id` rather than transaction-level order keys, enabling accurate evaluation of true repeat customer retention and cohort purchasing patterns.
- **Supply Chain Bottleneck Analysis:** Integrated geolocation datasets to map state-level delivery delay rates across regions, pinpointing key logistical bottlenecks in shipping pipelines.
- **Customer Satisfaction & Delivery Lead Times:** Modeled statistical correlations between delivery lead times and customer review scores to formulate service-quality optimization strategies.
- **Financial & Shipping Efficiency:** Evaluated monthly revenue growth trends and analyzed the relationship between shipping costs and delivery duration.

---

### 🛠️ Tech Stack & Methods

- **Languages:** Python (Pandas, NumPy, Matplotlib, Seaborn), SQL
- **Database & ETL:** PostgreSQL (integrated via SQLAlchemy), Python ETL pipelines
- **Core Analytics Concepts:** Window Functions, CTEs, Data Normalization, Cohort Analysis, Correlation Analysis

---

### 📁 Project Structure

```text
├── data/       # Raw dataset files
├── notebooks/  # Exploratory Data Analysis (EDA) & SQL analytics notebooks
├── src/        # Python ETL scripts & data pipeline modules
└── outputs/    # Processed datasets, clean tables, and visual exports
