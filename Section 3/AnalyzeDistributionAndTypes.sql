use AdventureWorksDW2017
GO
-- Choosing distribution key and method


-- First let's look at what round-robin would look like
select cp.[distribution],count(*) distributionRecords from (
select row_number() over(order by (select null)) rowNum from FactTransactionHistory) subq
cross apply(select rowNum%60 [distribution]) cp
group by [distribution]
order by [distribution];



-- Now if we wanted to explore hash key distribution, what should we pick?

select cs.name, tt.name from sys.columns cs inner join sys.types tt
on cs.system_type_id=tt.system_type_id where object_id=OBJECT_ID('FactTransactionHistory');


-- Analyze ProductKey
select count(distinct ProductKey)
from FactTransactionHistory;



select cp.[distribution],sum(recordCount) distributionRecords from
(select DENSE_RANK() over(order by ProductKey) rowNum, count(*) recordCount from FactTransactionHistory
group by ProductKey) subq
cross apply(select rowNum%60 [distribution]) cp
group by [distribution]
order by [distribution];


 
-- However, distribution is not everything, you have to think about the query patterns as well
select OBJECT_NAME(object_id) from sys.columns where name='ProductKey';



-- Analyzing data types
select OBJECT_NAME(object_id),cs.name from sys.columns cs 
inner join sys.types ts on cs.system_type_id=ts.system_type_id where ts.name in('nvarchar','nchar')
and (OBJECT_NAME(object_id) like 'Dim%' or OBJECT_NAME(object_id) like 'Fact%');



-- since English columns don't require Unicode we should change it to varchar to use up half the space
alter table DimBigProduct alter column EnglishProductName varchar(80);
