USE [customer360]
GO
/****** Object:  StoredProcedure [dbo].[CalculateAverageOrderValue]    Script Date: 19-03-2025 17:18:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CalculateAverageOrderValue]
AS
BEGIN
    SET NOCOUNT ON;

    -- Merge aggregated AOV data into the AnalyticsAOV table
    MERGE INTO dbo.AnalyticsAOV AS target
    USING (
        SELECT 
            o.ProductID,
            p.Category,
            s.Location,  -- Store Location from the Store table
            SUM(o.Amount) / NULLIF(COUNT(o.OrderID), 0) AS AverageOrderValue  -- Prevent division by zero
        FROM dbo.Orders o
        JOIN dbo.Product p ON o.ProductID = p.ProductID
        JOIN dbo.StoreTransaction t ON o.CustomerID = t.CustomerID  -- Connect Orders and Transactions via CustomerID
        JOIN dbo.Store s ON t.StoreID = s.StoreID  -- Connect Transactions and Store via StoreID
        GROUP BY 
            o.ProductID, 
            p.Category, 
            s.Location
    ) AS source
    ON target.ProductID = source.ProductID 
       AND target.Category = source.Category 
       AND target.Location = source.Location

    -- Update existing records if AverageOrderValue has changed
    WHEN MATCHED AND target.AverageOrderValue <> source.AverageOrderValue
    THEN 
        UPDATE SET target.AverageOrderValue = source.AverageOrderValue

    -- Insert new records if they don’t exist
    WHEN NOT MATCHED THEN 
        INSERT (ProductID, Category, Location, AverageOrderValue)
        VALUES (source.ProductID, source.Category, source.Location, source.AverageOrderValue);

END;

