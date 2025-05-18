
-- Query: Identify Inactive Accounts (Savings or Investments)
-- Purpose: Help the operations team flag plans with no inflow activity 
--          for 365 days or more, to support re-engagement strategies.


SELECT 
    p.id AS plan_id,               -- Unique identifier for each plan (savings or investment)
    p.owner_id,                    -- ID of the user who owns the plan
    p.description AS type,         -- Description of the plan (e.g., 'Savings', 'Investment')

    -- Capture the most recent transaction date for the plan (if any)
    MAX(s.transaction_date) AS last_transaction_date,

    -- Calculate number of days since the last transaction using current date
    DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days

FROM plans_plan p

-- Use LEFT JOIN to retain all plans, even if they have no matching transactions
LEFT JOIN savings_savingsaccount s 
    ON p.id = s.plan_id 
    AND (LOWER(p.description) LIKE '%savings%' OR LOWER(p.description) LIKE '%investment%')

-- Filter to only consider successful transactions in the date analysis
WHERE s.transaction_status = 'success' OR s.transaction_status IS NULL

-- Group results by each plan to evaluate activity on a per-plan basis
GROUP BY p.id, p.owner_id, p.description

-- Only include:
-- - plans that have never had a transaction (NULL last_transaction_date), OR
-- - plans with last transaction 365 days ago or more
HAVING last_transaction_date IS NULL OR inactivity_days >= 365

-- Show the longest inactive plans first for priority review
ORDER BY inactivity_days DESC;
