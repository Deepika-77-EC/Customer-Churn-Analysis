-- ===============================
-- Customer Churn Analysis (MySQL)
-- ===============================

-- Check secure file path
SHOW VARIABLES LIKE 'secure_file_priv';

-- Use database
USE churn_analysis;

-- Create table
CREATE TABLE telco_churn (
    customerID VARCHAR(20) PRIMARY KEY,
    gender VARCHAR(10),
    SeniorCitizen INT,
    Partner VARCHAR(5),
    Dependents VARCHAR(5),
    tenure INT,
    PhoneService VARCHAR(10),
    MultipleLines VARCHAR(25),
    InternetService VARCHAR(25),
    OnlineSecurity VARCHAR(25),
    OnlineBackup VARCHAR(25),
    DeviceProtection VARCHAR(25),
    TechSupport VARCHAR(25),
    StreamingTV VARCHAR(25),
    StreamingMovies VARCHAR(25),
    Contract VARCHAR(25),
    PaperlessBilling VARCHAR(5),
    PaymentMethod VARCHAR(50),
    MonthlyCharges DECIMAL(10,2),
    TotalCharges DECIMAL(10,2) NULL,
    Churn VARCHAR(5)
);

-- Load CSV data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Telco-Customer-Churn.csv'
INTO TABLE telco_churn
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
 customerID, gender, SeniorCitizen, Partner, Dependents, tenure,
 PhoneService, MultipleLines, InternetService, OnlineSecurity,
 OnlineBackup, DeviceProtection, TechSupport, StreamingTV,
 StreamingMovies, Contract, PaperlessBilling, PaymentMethod,
 MonthlyCharges, @TotalCharges, Churn
)
SET TotalCharges = NULLIF(TRIM(@TotalCharges), '');

-- Basic counts
SELECT COUNT(*) AS total_customers FROM telco_churn;

-- Churn rate
SELECT 
    ROUND(
        AVG(CASE WHEN TRIM(Churn) = 'Yes' THEN 1 ELSE 0 END) * 100,
        2
    ) AS churn_rate_percentage
FROM telco_churn;

-- Churn by contract type
SELECT 
    Contract,
    COUNT(*) AS total_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_percentage
FROM telco_churn
GROUP BY Contract;

-- Churn by tenure group
SELECT 
    CASE 
        WHEN tenure <= 12 THEN '0–12 months'
        WHEN tenure <= 24 THEN '13–24 months'
        WHEN tenure <= 48 THEN '25–48 months'
        ELSE '49+ months'
    END AS tenure_group,
    COUNT(*) AS total_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_percentage
FROM telco_churn
GROUP BY tenure_group;

-- Churn by payment method
SELECT 
    PaymentMethod,
    COUNT(*) AS total_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_percentage
FROM telco_churn
GROUP BY PaymentMethod
ORDER BY churn_percentage DESC;
