
-- Query: Estimate Customer Lifetime Value (CLV)
-- Purpose: Help marketing prioritize customers by estimating their value over time
-- Assumption: Profit per transaction = 0.1% of transaction amount
-- Formula: CLV = (total_transactions / tenure_in_months) * 12 * avg_profit_per_transaction


SELECT 
    u.id AS customer_id,  -- Unique customer identifier

    -- Dynamically build full name by combining first and last names
    CONCAT(u.first_name, ' ', u.last_name) AS name,

    -- Calculate how long the customer has had an account (in months)
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,

    -- Total number of transactions made by the customer
    COUNT(s.id) AS total_transactions,

    -- Estimate CLV using a simplified profit model:
    -- - Normalize monthly activity (transactions per month)
    -- - Annualize it by multiplying by 12
    -- - Multiply by average profit per transaction (0.1% of avg transaction value)
    ROUND(
        (COUNT(s.id) / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 0)) * 12 * (0.001 * AVG(s.amount)),
        2
    ) AS estimated_clv

FROM users_customuser u

-- Use LEFT JOIN to include customers with zero transactions
LEFT JOIN savings_savingsaccount s
    ON u.id = s.owner_id

-- Group by user to get per-customer aggregates
GROUP BY u.id, name

-- Sort customers from highest to lowest CLV for prioritization
ORDER BY estimated_clv DESC;
