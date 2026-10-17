import pandas as pd
import numpy as np

def load_and_clean_olist_data():
    """
    Olist E-Commerce Dataset Cleaning & Logistics ETL Pipeline
    """
    print("ETL Pipeline started...")
    
    # 1. Load Data
    try:
        orders = pd.read_csv('data/orders.csv')
        customers = pd.read_csv('data/customers.csv')
        print("Datasets loaded successfully.")
    except FileNotFoundError:
        print("Error: Required CSV files (orders.csv, customers.csv) not found in 'data/' directory.")
        return None

    # 2. Data Cleaning & Unique Customer Logic
    # Merge using customer_id to bring customer_unique_id for retention tracking
    df = orders.merge(customers, on='customer_id', how='inner')
    print(f"Data merged successfully. Total records: {len(df)}")

    # 3. Delivery Delay Calculation
    df['order_delivered_customer_date'] = pd.to_datetime(df['order_delivered_customer_date'])
    df['order_estimated_delivery_date'] = pd.to_datetime(df['order_estimated_delivery_date'])
    
    # Calculate delay in days
    df['delivery_delay_days'] = (df['order_delivered_customer_date'] - df['order_estimated_delivery_date']).dt.days
    df['is_delayed'] = df['delivery_delay_days'].apply(lambda x: 1 if x > 0 else 0)
    
    print(f"Logistics lead times calculated. Delayed orders flagged: {df['is_delayed'].sum()}")
    print("ETL Pipeline completed successfully.")
    
    return df

if __name__ == "__main__":
    load_and_clean_olist_data()