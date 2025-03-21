USE [customer360]
GO
/****** Object:  StoredProcedure [dbo].[SegmentCustomers]    Script Date: 19-03-2025 17:18:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SegmentCustomers]
AS
BEGIN
    SET NOCOUNT ON;

    -- Prepare the latest customer segmentation data
    WITH CustomerData AS (
        SELECT 
            o.CustomerID,
            SUM(o.Amount) AS TotalSpend,  -- Calculate total spend per customer
            COUNT(o.OrderID) AS PurchaseFrequency  -- Count the number of orders per customer
        FROM dbo.Orders o
        GROUP BY o.CustomerID
    )
    
    -- Use MERGE to update existing records and insert new ones
    MERGE INTO dbo.CustomerSegments AS target
    USING (
        SELECT 
            c.CustomerID,
            CASE
                WHEN c.TotalSpend >= (SELECT MAX(TotalSpend) 
                                      FROM (SELECT SUM(o.Amount) AS TotalSpend 
                                            FROM dbo.Orders o 
                                            GROUP BY o.CustomerID) AS TotalSpends) 
                THEN 'High-Value Customers'
                WHEN c.PurchaseFrequency = 1 THEN 'One-Time Buyers'
                WHEN l.TierLevel = 'Platinum' THEN 'Loyalty Champions'
                ELSE 'Regular Customers'
            END AS Segment,
            c.TotalSpend,
            c.PurchaseFrequency,
            l.TierLevel
        FROM CustomerData c
        JOIN dbo.Loyaltyacc l ON c.CustomerID = l.CustomerID
    ) AS source
    ON target.CustomerID = source.CustomerID

    -- Update existing records if data has changed
    WHEN MATCHED AND 
         (target.Segment <> source.Segment OR 
          target.TotalSpend <> source.TotalSpend OR 
          target.PurchaseFrequency <> source.PurchaseFrequency OR 
          target.TierLevel <> source.TierLevel)
    THEN 
        UPDATE SET 
            target.Segment = source.Segment,
            target.TotalSpend = source.TotalSpend,
            target.PurchaseFrequency = source.PurchaseFrequency,
            target.TierLevel = source.TierLevel

    -- Insert new records if CustomerID doesn't exist
    WHEN NOT MATCHED THEN
        INSERT (CustomerID, Segment, TotalSpend, PurchaseFrequency, TierLevel)
        VALUES (source.CustomerID, source.Segment, source.TotalSpend, source.PurchaseFrequency, source.TierLevel);
END;
