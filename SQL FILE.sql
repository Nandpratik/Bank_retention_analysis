create database Project_with_join ;
use Project_with_join ;
show tables;
select * from cust_bank_info;
select * from cust_info;


# OBJECTIVE QUESTIONS 
# Q2- Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)

Select CustomerID,Surname,EstimatedSalary ,Rank_Sal
from(
select  CustomerID,Surname,EstimatedSalary ,Bank_DOJ , dense_rank() over(partition by year(Bank_DOJ) order by EstimatedSalary desc) "Rank_Sal"
from cust_info
where month(Bank_DOJ) between 10 and 12 
)innerquery
where Rank_Sal < 6; 


#  Q3-Calculate the average number of products used by customers who have a credit card. (SQL)
# Explanation - calculating - avg(NumOfProducts) used only for customers having Creditcard 
 
 SELECT 
    AVG(NumOfProducts) AS AVG_NOSPRODUCTS_Cust_HAVINGCRCARD
FROM
    cust_bank_info
WHERE
    HasCrCard = 'Credit card holder';
    

# Q5- Compare the average credit score of customers who have exited and those who remain. (SQL)
# finding avg of credit score for the customers who left the bank and who got retained at the bank 

SELECT 
    Exited, AVG(CreditScore) AVG_CREDIT_SCORE
FROM
    cust_bank_info
GROUP BY Exited;

# Q6 Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
# i am calculating avg salary as per gender and besides them number of active or inactive accounts 

SELECT 
    ci.GenderID,
    AVG(ci.EstimatedSalary) as AVG_ESTIMATED_SAL ,
    SUM(CASE
        WHEN cbi.IsActiveMember = 'Active Member' THEN 1
        ELSE 0 END) AS ActiveAccounts,
    SUM(CASE
        WHEN cbi.IsActiveMember = 'Inactive' THEN 1
        ELSE 0 END) AS InActiveAccounts
FROM   cust_info ci
JOIN   cust_bank_info cbi ON ci.CustomerID = cbi.customerID
GROUP BY ci.GenderID;

# Q7 -Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)

SELECT CASE
        WHEN cbi.CreditScore BETWEEN 300 AND 579 THEN 'Poor'
        WHEN cbi.CreditScore BETWEEN 580 AND 669 THEN 'Fair'
        WHEN cbi.CreditScore BETWEEN 670 AND 739 THEN 'Good'
        WHEN cbi.CreditScore BETWEEN 740 AND 799 THEN 'Very Good'
        WHEN cbi.CreditScore BETWEEN 800 AND 850 THEN 'Excellent'
        ELSE 'NULL'
    END AS CREDIT_SCORE_SEGMENT,sum(case when Exited = "Exit" then 1 else 0 end ) NOS_CUST_EXITED,
    (sum(case when Exited = "Exit" then 1 else 0 end ) /count(ci.CustomerId))*100 Churn_rate

FROM cust_bank_info cbi
        JOIN cust_info ci ON cbi.CustomerID = ci.CustomerID
GROUP BY CREDIT_SCORE_SEGMENT
order by Churn_rate desc;

# Q8-Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)

SELECT 
    ci.GeographyID, COUNT(cbi.IsActiveMember) Active_Cust
FROM
    cust_info ci
        JOIN
    cust_bank_info cbi ON ci.CustomerID = cbi.CustomerID
WHERE
    IsActiveMember = 'Active Member'
        AND cbi.Tenure > 5
GROUP BY ci.GeographyID;


#Q11 -Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). 
#Prepare the data through SQL and then visualize it.

#YEARLY
SELECT 
    YEAR(Bank_DOJ) 'YEAR', COUNT(CustomerID) 'COUNT_CUST_JOINED'
FROM
    cust_info
GROUP BY YEAR(Bank_DOJ)
ORDER BY COUNT(CustomerID) DESC;
#MONTHLY
SELECT 
    YEAR(Bank_DOJ) 'YEAR',
    MONTH(Bank_DOJ) 'MONTH',
    COUNT(CustomerID) 'COUNT_CUST_JOINED'
FROM
    cust_info
GROUP BY YEAR(Bank_DOJ) , MONTH(Bank_DOJ)
ORDER BY YEAR ASC , MONTH ASC;

#Q15 Using SQL, write a query to find out the gender-wise average income of males and females in each geography id.
# Also, rank the gender according to the average value. (SQL)

select GeographyID,GenderID, AVG_SAL,
 rank() over(partition by GeographyID order by AVG_SAL desc) as "Rank" # outerquery 
from (
select GeographyID,GenderID,avg(EstimatedSalary) AVG_SAL
from cust_info 
group by GeographyID,GenderID
order by GeographyID asc ,GenderID asc)innerquery ;

# Q16-Using SQL, write a query to find out the average tenure of the people who
#have exited in each age bracket (18-30, 30-50, 50+)
select 
case 
when ci.Age between 18 and 30 then "18-30"
when ci.Age between 30 and 50 then "30-50"
when ci.Age >50 then "50+"
Else "0" end AGE_BRACKET , avg(cbi.Tenure) AVG_TENURE
from cust_info ci
join cust_bank_info cbi 
on ci.CustomerID = cbi.CustomerID 
where cbi.Exited = "EXIT"
group by AGE_BRACKET
order by AGE_BRACKET ;

# Q19- Rank each bucket of credit score as per the number of customers who have churned the bank.

SELECT CREDIT_SCORE_SEGMENT,CUST_CHURNED_BANK ,
rank() over(order by CUST_CHURNED_BANK desc ) as "RANK"
 from (
SELECT 
    CASE
        WHEN CreditScore BETWEEN 300 AND 579 THEN 'Poor'
        WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair'
        WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good'
        WHEN CreditScore BETWEEN 740 AND 799 THEN 'Very Good'
        WHEN CreditScore BETWEEN 800 AND 850 THEN 'Excellent'
        ELSE 'NULL'
    END AS CREDIT_SCORE_SEGMENT , count(Exited) CUST_CHURNED_BANK  
    from cust_bank_info
    where Exited = "Exit"
    group by CREDIT_SCORE_SEGMENT
    order by CUST_CHURNED_BANK desc) inner_query_for_ranking;
    
# Q20 Part -A  According to the age buckets find the number of customers who have a credit card.
#PArt -B -Also retrieve those buckets who have lesser than average number of credit cards, per bucket.

#Part -A 
select 
case 
when ci.Age between 18 and 30 then "18-30"
when ci.Age between 30 and 50 then "30-50"
when ci.Age >50 then "50+"
Else "0" end AGE_BRACKET , 
sum(case when cbi.HasCrCard = "Credit card holder" then 1 else 0 end) HAVING_CR_CARD
from cust_info ci
join cust_bank_info cbi 
on ci.CustomerID = cbi.CustomerID 
group by AGE_BRACKET ;

#Part B 

WITH AGE_brack_wise_cust as (
select 
case 
when ci.Age between 18 and 30 then "18-30"
when ci.Age between 30 and 50 then "30-50"
when ci.Age >50 then "50+"
Else "0" end AGE_BRACKET , 
count(cbi.CustomerID) HAVING_CR_CARD
from cust_info ci
join cust_bank_info cbi 
on ci.CustomerID = cbi.CustomerID 
where cbi.HasCrCard = "Credit card holder"
group by AGE_BRACKET )

select * from AGE_brack_wise_cust 
where HAVING_CR_CARD < (select avg( HAVING_CR_CARD) from (
select 
case 
when ci.Age between 18 and 30 then "18-30"
when ci.Age between 30 and 50 then "30-50"
when ci.Age >50 then "50+"
Else "0" end AGE_BRACKET , 
count(cbi.CustomerID) HAVING_CR_CARD
from cust_info ci
join cust_bank_info cbi 
on ci.CustomerID = cbi.CustomerID 
where cbi.HasCrCard = "Credit card holder"
group by AGE_BRACKET)x) ;

# Q21 Rank the Locations as per the number of people who have churned and the bank average balance of the learners.
select GeographyID,CUST_CHURNED ,
rank() over(order by CUST_CHURNED desc ) as  "RANK_CUST_CHURN"
from (
select ci.GeographyID,count(cbi.Exited) CUST_CHURNED 
from cust_bank_info cbi
join cust_info ci 
on cbi.CustomerID = ci.CustomerID
where cbi.Exited = "Exit"
group by ci.GeographyID)x; 

#Rank the Locations as per the  average balance of the learners.

select GeographyID,CUST_AVG_BAL ,
rank() over(order by CUST_AVG_BAL desc ) as  "RANK_CUST_AVG_BAL"
from (
select ci.GeographyID,round(avg(cbi.Balance),2) CUST_AVG_BAL
from cust_bank_info cbi
join cust_info ci 
on cbi.CustomerID = ci.CustomerID
group by ci.GeographyID)x; 


# Q22  As we can see that the “CustomerInfo” table has the CustomerID and Surname, 
#      now if we have to join it with a table where the primary key is also a combination of CustomerID and Surname,
#      come up with a column where the format is “CustomerID_Surname”.

SELECT 
    CustomerId,
    Surname,
    CONCAT(CustomerID, '_', Surname) CustomerID_Surname,
    Age,
    GenderID,
    EstimatedSalary,
    GeographyID,
    Bank_DOJ
FROM
    cust_info;
    
# Q 23 Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? 
#      If yes do this using SQL.

/* ANSWER & EXPLAINATION - 
                            I have preprocessed the data in excel before importing it on SQL database -
                            For this AS there were 2 main data sheets and remianing 5 were sheets for nominal categorical data
                            i  replaced the categorical variables from sheets of "ACTIVE CUSTOMERS",
                            "CREDIT CARD","EXIT CUSTOMER","GENDER" & "GEOGRAPHY" as per their accurate specifications
                            into the main data sheet.
                            Hence for this particular Q23 i am importing the needed tables of "Q23exit_customers"
                            and "Q23bank_churn" 
*/

# 1st way - using "corelated subquery"
SELECT 
    bc.*,
    (SELECT 
            ExitCategory
        FROM
            q23exitcustomer ec
        WHERE
            ec.ExitID = bc.Exited) AS ExitCategory
FROM
    q23bank_Churn bc; 

# 2nd way - using "case when" statement 
 
select * ,
 case when Exited = 1 then "Exit" else "Retain" end as churn_status
 from q23bank_churn;
 
# 3rd way - using UPDATE staement 
/*        UPDATE q23bank_churn 
          set Exited = "Exit"
          where Exited = "1"; 
        
          UPDATE q23bank_churn 
          set Exited = "Retain"
          where Exited = "0"; 
          */
	
# using IF statement 
                         select * , if(Exited=1,"Exit","Retain") Churn_status
                         from q23bank_churn;
  
# Q25 Write the query to get the customer ids,
# their last name and whether they are active or not for the customers whose surname  ends with “on”.

select CustomerId ,Surname from cust_info 
where Surname like "%on" ;

# Q9 Subjective question
#Utilize SQL queries to segment customers based on demographics and account details

#Segmentation as per Age
select 
CASE
WHEN ci.Age between 0 and 25 then "18-25" 
when ci.Age between 26 and 35 then "26-35" 
when ci.Age between 36 and 55 then "36-55"
when ci.Age between 56 and 65 then "56-65"
when ci.Age > 65 then ">65"
else 0 end AGE_BRACKET,
SUM(case when cbi.Exited = "Exit" then 1 else 0 end) CUST_EXITED,SUM(case when cbi.Exited = "Retain" then 1 else 0 end) CUST_RETAIN,
SUM(CASE WHEN cbi.HasCrCard = "Credit card holder" then 1 else 0 end ) CUST_HAVING_CRcard,SUM(CASE WHEN cbi.HasCrCard = "Credit card holder" then 0 else 1 end ) CUST_NOTHAVING_CRcard,
Avg(Tenure) AVG_TENURE, avg(CreditScore) AVG_CREDITSCORE
from cust_bank_info cbi 
join cust_info ci 
on cbi.customerId=ci.customerId
group by AGE_BRACKET;

#segmentation as per credit score

 SELECT 
    CASE
        WHEN cbi.CreditScore BETWEEN 300 AND 579 THEN 'Poor'
        WHEN cbi.CreditScore BETWEEN 580 AND 669 THEN 'Fair'
        WHEN cbi.CreditScore BETWEEN 670 AND 739 THEN 'Good'
        WHEN cbi.CreditScore BETWEEN 740 AND 799 THEN 'Very Good'
        WHEN cbi.CreditScore BETWEEN 800 AND 850 THEN 'Excellent'
        ELSE 'NULL'
    END AS CREDIT_SCORE_SEGMENT ,
SUM(case when cbi.Exited = "Exit" then 1 else 0 end) CUST_EXITED,SUM(case when cbi.Exited = "Retain" then 1 else 0 end) CUST_RETAIN,
Avg(Tenure) AVG_TENURE, avg(CreditScore) AVG_CREDITSCORE
from cust_bank_info cbi 
join cust_info ci 
on cbi.customerId=ci.customerId
group by CREDIT_SCORE_SEGMENT ;

# segmentations as per tenure

SELECT 
    CASE
        WHEN cbi.Tenure between 0 and 4 then "NEW_CUSTOMERS"
        WHEN cbi.Tenure between 5 and 6 then "ESTABLISHED_CUSTOMERS"
        WHEN cbi.Tenure > 6 then "LONG_TERM_CUSTOMERS"
        ELSE 'NULL'
    END AS TENURE_SEGMENT ,
SUM(case when cbi.Exited = "Exit" then 1 else 0 end) CUST_EXITED,SUM(case when cbi.Exited = "Retain" then 1 else 0 end) CUST_RETAIN,
 avg(CreditScore) AVG_CREDITSCORE,
 SUM(CASE WHEN cbi.HasCrCard = "Credit card holder" then 1 else 0 end ) CUST_HAVING_CRcard,SUM(CASE WHEN cbi.HasCrCard = "Credit card holder" then 0 else 1 end ) CUST_NOTHAVING_CRcard

from cust_bank_info cbi 
join cust_info ci 
on cbi.customerId=ci.customerId
group by TENURE_SEGMENT  ;

#Q14 In the “Bank_Churn” table how can you modify the name of “HasCrCard” column to “Has_creditcard”?

/*Alter table cust_bank_info
change HasCrCard Has_creditcard varchar(100);*/
 



 

























    

 








