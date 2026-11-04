create database telco;
use telco;
select version();
describe customers;

-- 1. Overall churn rate
select count(*) as customers,sum(churn_flag) as churned,
round(100.0 * sum(churn_flag) / count(*),2) as churn_rate
from customers;

-- 2. Churn by contact
select contract, count(*) as customers, sum(churn_flag) as churned,
round(100.0 * sum(churn_flag) / count(*),2) as churn_rate
from customers
group by contract
order by churn_rate desc;

-- 3. Churn by tenure group (CASE WHEN)
select case when tenure<= 12 then '0-12'
when tenure<= 24 then '13-24'
when tenure<= 48 then '25-48'
else '49-72' end as tenure_group,
count(*) as customers,
round(100.0 * sum(churn_flag) / count(*), 2) as churn_rate
from customers
group by tenure_group
order by min(tenure); 

-- 4. Riskiest segment (CTE + window function)
with seg as (
select contract, internetservice,count(*) as customers,
sum(churn_flag) as churned,
round(100.0 * sum(churn_flag) / count(*),2) as churn_rate
from customers
group by contract,internetservice
)
select *, rank() over (order by churn_rate desc) as risk_rank
from seg
where customers >= 100
order by risk_rank;

-- 5. Revenue lost to churn
select contract,
round(sum(case when churn_flag = 1 then monthlycharges else 0 end),2) as lost_monthly_revenue,
round(100.0 * sum(case when churn_flag = 1 then monthlycharges else 0 end)/sum(monthlycharges),2) as pct_of_revenue_lost
from customers
group by contract
order by lost_monthly_revenue desc;



