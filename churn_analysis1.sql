-- customer churn analysis

-- creating customer table
CREATE TABLE Customer (
    CustomerID VARCHAR(20) PRIMARY KEY,
    Gender VARCHAR(10),
    SeniorCitizen VARCHAR(5),
    Partner VARCHAR(5),
    Dependents VARCHAR(5),
    Country VARCHAR(50),
    State VARCHAR(50),
    City VARCHAR(50),
    ZipCode INT,
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6)
);

-- subscription table
CREATE TABLE Subscription (
    CustomerID VARCHAR(20) PRIMARY KEY,
    TenureMonths INT,
    Contract VARCHAR(30),
    PaperlessBilling VARCHAR(5),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- services table
CREATE TABLE Services (
    CustomerID VARCHAR(20) PRIMARY KEY,
    PhoneService VARCHAR(5),
    MultipleLines VARCHAR(20),
    InternetService VARCHAR(20),
    OnlineSecurity VARCHAR(20),
    OnlineBackup VARCHAR(20),
    DeviceProtection VARCHAR(20),
    TechSupport VARCHAR(20),
    StreamingTV VARCHAR(20),
    StreamingMovies VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- billing table
CREATE TABLE Billing (
    CustomerID VARCHAR(20) PRIMARY KEY,
    PaymentMethod VARCHAR(50),
    MonthlyCharges DECIMAL(10,2),
    TotalCharges DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- churn table
CREATE TABLE Churn (
    CustomerID VARCHAR(20) PRIMARY KEY,
    ChurnLabel VARCHAR(10),
    ChurnValue INT,
    ChurnScore INT,
    CLTV INT,
    ChurnReason VARCHAR(100),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- raw data table
CREATE TABLE Raw_Data (
    CustomerID VARCHAR(20),
    Country VARCHAR(50),
    State VARCHAR(50),
    City VARCHAR(50),
    ZipCode INT,
    LatLong VARCHAR(50),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    Gender VARCHAR(10),
    SeniorCitizen VARCHAR(5),
    Partner VARCHAR(5),
    Dependents VARCHAR(5),
    TenureMonths INT,
    PhoneService VARCHAR(5),
    MultipleLines VARCHAR(20),
    InternetService VARCHAR(20),
    OnlineSecurity VARCHAR(20),
    OnlineBackup VARCHAR(20),
    DeviceProtection VARCHAR(20),
    TechSupport VARCHAR(20),
    StreamingTV VARCHAR(20),
    StreamingMovies VARCHAR(20),
    Contract VARCHAR(30),
    PaperlessBilling VARCHAR(5),
    PaymentMethod VARCHAR(50),
    MonthlyCharges DECIMAL(10,2),
    TotalCharges DECIMAL(10,2),
    ChurnLabel VARCHAR(10),
    ChurnValue INT,
    ChurnScore INT,
    CLTV INT,
    ChurnReason VARCHAR(100)
);

-- inserting churn data from raw data
INSERT INTO Churn (
    CustomerID, ChurnLabel, ChurnValue, ChurnScore, CLTV, ChurnReason
)
SELECT
    CustomerID, ChurnLabel, ChurnValue, ChurnScore, CLTV, ChurnReason
FROM Raw_Data;


-- checking tables
select * from Customer;
select * from Services;
select * from Subscription;
select * from Billing;
select * from Churn;


-- total customers
select count(*) as totalcustomers
from customer;


-- churned customers
select count(*) as churnedcustomers
from churn
where churnlabel = 'Yes';


-- overall churn rate
select round(
    (select count(*) from churn where churnlabel = 'Yes') * 100.0 /
    (select count(*) from customer),
    2
) as churnrate;


-- total customer charges
select sum(totalcharges) as totalcharges
from billing;


-- average monthly charges
select round(avg(monthlycharges),2) as avg_monthlycharges
from billing;


-- churn by contract
select
    s.contract,
    count(*) as totalcustomers,
    count(case when c.churnlabel = 'Yes' then 1 end) as churnedcustomers,
    round(
        count(case when c.churnlabel = 'Yes' then 1 end) * 100.0 / count(*),
        2
    ) as churnrate
from subscription s
join churn c on s.customerid = c.customerid
group by s.contract
order by churnrate desc;


-- churn by internet service
select
    s.internetservice,
    count(*) as totalcustomers,
    count(case when c.churnlabel = 'Yes' then 1 end) as churnedcustomers,
    round(
        count(case when c.churnlabel = 'Yes' then 1 end) * 100.0 / count(*),
        2
    ) as churnrate
from services s
join churn c on s.customerid = c.customerid
group by s.internetservice
order by churnrate desc;


-- churn by payment method
select
    b.paymentmethod,
    count(*) as totalcustomers,
    count(case when c.churnlabel = 'Yes' then 1 end) as churnedcustomers,
    round(
        count(case when c.churnlabel = 'Yes' then 1 end) * 100.0 / count(*),
        2
    ) as churnrate
from billing b
join churn c on b.customerid = c.customerid
group by b.paymentmethod
order by churnrate desc;


-- churn by senior citizen
select
    cst.seniorcitizen,
    count(*) as totalcustomers,
    count(case when c.churnlabel = 'Yes' then 1 end) as churnedcustomers,
    round(
        count(case when c.churnlabel = 'Yes' then 1 end) * 100.0 / count(*),
        2
    ) as churnrate
from customer cst
join churn c on cst.customerid = c.customerid
group by cst.seniorcitizen
order by churnrate desc;


-- churn by gender
select
    cst.gender,
    count(*) as totalcustomers,
    count(case when c.churnlabel = 'Yes' then 1 end) as churnedcustomers,
    round(
        count(case when c.churnlabel = 'Yes' then 1 end) * 100.0 / count(*),
        2
    ) as churnrate
from customer cst
join churn c on cst.customerid = c.customerid
group by cst.gender
order by churnrate desc;


-- churn by tenure group
select
    case
        when s.tenuremonths <= 12 then 'New (0-12 Months)'
        when s.tenuremonths <= 24 then 'Early (13-24 Months)'
        when s.tenuremonths <= 48 then 'Established (25-48 Months)'
        else 'Long-term (49+ Months)'
    end as tenuregroup,
    count(*) as totalcustomers,
    count(case when c.churnlabel = 'Yes' then 1 end) as churnedcustomers,
    round(
        count(case when c.churnlabel = 'Yes' then 1 end) * 100.0 / count(*),
        2
    ) as churnrate
from subscription s
join churn c on s.customerid = c.customerid
group by
    case
        when s.tenuremonths <= 12 then 'New (0-12 Months)'
        when s.tenuremonths <= 24 then 'Early (13-24 Months)'
        when s.tenuremonths <= 48 then 'Established (25-48 Months)'
        else 'Long-term (49+ Months)'
    end
order by churnrate desc;


-- churn by tech support
select
    s.techsupport,
    count(*) as totalcustomers,
    count(case when c.churnlabel = 'Yes' then 1 end) as churnedcustomers,
    round(
        count(case when c.churnlabel = 'Yes' then 1 end) * 100.0 / count(*),
        2
    ) as churnrate
from services s
join churn c on s.customerid = c.customerid
group by s.techsupport
order by churnrate desc;
