/*
This script creates two new tables in AdventureWorks:
dbo.DimBigProduct
dbo.FactTransactionHistory

credits: Adam Machanic for original script

*/


USE AdventureWorksDW2017
GO

SELECT
	p.ProductKey + (a.number * 1000) AS ProductKey,
	p.EnglishProductName + CONVERT(VARCHAR, (a.number * 1000)) AS EnglishProductName,
	p.ProductAlternateKey + '-' + CONVERT(VARCHAR, (a.number * 1000)) AS ProductAlternateKey,
	p.FinishedGoodsFlag,
	p.Color,
	p.SafetyStockLevel,
	p.ReorderPoint,
	p.StandardCost,
	p.ListPrice,
	p.Size,
	p.SizeUnitMeasureCode,
	p.WeightUnitMeasureCode,
	p.Weight,
	p.DaysToManufacture,
	p.ProductLine,
	p.Class,
	p.Style,
	p.ProductSubcategoryKey,
	p.ModelName,
	p.StartDate,
	p.EndDate
INTO DimBigProduct
FROM DimProduct AS p
CROSS JOIN master..spt_values AS a
WHERE
	a.type = 'p'
	AND a.number BETWEEN 1 AND 50
GO


ALTER TABLE DimBigProduct
ALTER COLUMN ProductKey INT NOT NULL	
GO

ALTER TABLE DimBigProduct
ADD CONSTRAINT pk_DimBigProduct PRIMARY KEY (ProductKey)
GO


SELECT 
	ROW_NUMBER() OVER 
	(
		ORDER BY 
			x.TransactionDate,
			(SELECT NEWID())
	) AS TransactionID,
	p1.ProductKey,
	x.TransactionDate OrderDate,
	x.Quantity,
	CONVERT(MONEY, p1.ListPrice * x.Quantity * RAND(CHECKSUM(NEWID())) * 2) AS ActualCost
INTO FactTransactionHistory
FROM
(
	SELECT
		p.ProductKey, 
		p.ListPrice,
		CASE
			WHEN p.ProductKey % 26 = 0 THEN 26
			WHEN p.ProductKey % 25 = 0 THEN 25
			WHEN p.ProductKey % 24 = 0 THEN 24
			WHEN p.ProductKey % 23 = 0 THEN 23
			WHEN p.ProductKey % 22 = 0 THEN 22
			WHEN p.ProductKey % 21 = 0 THEN 21
			WHEN p.ProductKey % 20 = 0 THEN 20
			WHEN p.ProductKey % 19 = 0 THEN 19
			WHEN p.ProductKey % 18 = 0 THEN 18
			WHEN p.ProductKey % 17 = 0 THEN 17
			WHEN p.ProductKey % 16 = 0 THEN 16
			WHEN p.ProductKey % 15 = 0 THEN 15
			WHEN p.ProductKey % 14 = 0 THEN 14
			WHEN p.ProductKey % 13 = 0 THEN 13
			WHEN p.ProductKey % 12 = 0 THEN 12
			WHEN p.ProductKey % 11 = 0 THEN 11
			WHEN p.ProductKey % 10 = 0 THEN 10
			WHEN p.ProductKey % 9 = 0 THEN 9
			WHEN p.ProductKey % 8 = 0 THEN 8
			WHEN p.ProductKey % 7 = 0 THEN 7
			WHEN p.ProductKey % 6 = 0 THEN 6
			WHEN p.ProductKey % 5 = 0 THEN 5
			WHEN p.ProductKey % 4 = 0 THEN 4
			WHEN p.ProductKey % 3 = 0 THEN 3
			WHEN p.ProductKey % 2 = 0 THEN 2
			ELSE 1 
		END AS ProductGroup
	FROM DimBigProduct p
) AS p1
CROSS APPLY
(
	SELECT
		transactionDate,
		CONVERT(INT, (RAND(CHECKSUM(NEWID())) * 100) + 1) AS Quantity
	FROM
	(
		SELECT 
			DATEADD(dd, number, '20130101') AS transactionDate,
			NTILE(p1.ProductGroup) OVER 
			(
				ORDER BY number
			) AS groupRange
		FROM master..spt_values
		WHERE 
			type = 'p'
	) AS z
	WHERE
		z.groupRange % 2 = 1
) AS x



ALTER TABLE FactTransactionHistory
ALTER COLUMN TransactionID INT NOT NULL
GO


ALTER TABLE FactTransactionHistory
ADD CONSTRAINT pk_FactTransactionHistory PRIMARY KEY (TransactionID)
GO


CREATE NONCLUSTERED INDEX IX_ProductId_TransactionDate
ON FactTransactionHistory
(
	ProductKey,
	OrderDate
)
INCLUDE 
(
	Quantity,
	ActualCost
)
GO


