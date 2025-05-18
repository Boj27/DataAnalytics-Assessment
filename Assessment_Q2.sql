
-- Query: Identify High-Value Customers with Multiple Products
-- Purpose: Discover customers who have engaged with both savings 
--          and investment plans, to support cross-sell strategy.


SELECT 
    u.id AS owner_id,  -- Customer's unique identifier from users table

    -- Dynamically generate full name by combining first and last names
    CONCAT(u.first_name, ' ', u.last_name) AS name,

    -- Count of distinct savings-related plans tied to successful transactions
    COUNT(DISTINCT CASE 
        WHEN LOWER(p.description) LIKE '%savings%' THEN p.id 
    END) AS savings_count,

    -- Count of distinct investment-related plans tied to successful transactions
    COUNT(DISTINCT CASE 
        WHEN LOWER(p.description) LIKE '%investment%' THEN p.id 
    END) AS investment_count,

    -- Aggregate of all successful deposit amounts made by the customer
    SUM(s.amount) AS total_deposits

FROM users_customuser u

-- Join savings account records to users using foreign key relationship
JOIN savings_savingsaccount s 
    ON u.id = s.owner_id

-- Join to plan metadata to determine the nature (savings/investment) of each plan
JOIN plans_plan p 
    ON s.plan_id = p.id

-- Focus only on transactions that were completed successfully
WHERE s.transaction_status = 'success'

-- Group records by each user to compute per-customer metrics
GROUP BY u.id, name

-- Filter to include only customers who have at least:
-- - one distinct savings plan
-- - one distinct investment plan
HAVING 
    COUNT(DISTINCT CASE WHEN LOWER(p.description) LIKE '%savings%' THEN p.id END) >= 1
    AND 
    COUNT(DISTINCT CASE WHEN LOWER(p.description) LIKE '%investment%' THEN p.id END) >= 1

-- Rank customers by the total amount they have deposited, highest first
ORDER BY total_deposits DESC;
