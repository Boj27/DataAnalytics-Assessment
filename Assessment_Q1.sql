
-- Query: Identify High-Value Customers with Multiple Products
-- Goal: Find customers who have both a savings and an investment plan 
--       (at least one of each), and rank them by total deposits.

SELECT 
    u.id AS owner_id,  -- Unique customer identifier
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Full name of the customer

    -- Count of unique savings plans associated with this user
    COUNT(DISTINCT CASE 
        WHEN LOWER(p.description) LIKE '%savings%' THEN p.id 
    END) AS savings_count,

    -- Count of unique investment plans associated with this user
    COUNT(DISTINCT CASE 
        WHEN LOWER(p.description) LIKE '%investment%' THEN p.id 
    END) AS investment_count,

    -- Total value of successful savings deposits made by this user
    SUM(s.amount) AS total_deposits

FROM users_customuser u

-- Join to link savings accounts with user
JOIN savings_savingsaccount s 
    ON u.id = s.owner_id

-- Join to link savings accounts with their associated plan details
JOIN plans_plan p 
    ON s.plan_id = p.id

-- Only consider transactions that were marked as 'success'
WHERE s.transaction_status = 'success'

-- Group data per customer
GROUP BY u.id, name

-- Ensure the customer has at least one savings AND one investment product
HAVING 
    COUNT(DISTINCT CASE WHEN LOWER(p.description) LIKE '%savings%' THEN p.id END) >= 1
    AND 
    COUNT(DISTINCT CASE WHEN LOWER(p.description) LIKE '%investment%' THEN p.id END) >= 1

-- Rank customers by total deposits, highest first
ORDER BY total_deposits DESC;
