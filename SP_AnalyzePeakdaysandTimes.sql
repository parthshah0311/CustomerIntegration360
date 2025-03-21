USE [customer360]
GO
/****** Object:  StoredProcedure [dbo].[AnalyzePeakDaysAndTimes]    Script Date: 19-03-2025 17:17:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[AnalyzePeakDaysAndTimes]
AS
BEGIN
    SET NOCOUNT ON;

    -- Using MERGE to update or insert peak day and time data for both In-Store and Online orders
    MERGE INTO dbo.AnalyticsPeakTimes AS target
    USING (
        -- In-Store Orders
        SELECT 
            DATENAME(WEEKDAY, o.DateTime) AS DayOfWeek,
            DATEPART(HOUR, o.DateTime) AS HourOfDay,
            'In-Store' AS Channel,
            COUNT(o.OrderID) AS PeakOrders
        FROM dbo.Orders o
        JOIN dbo.StoreTransaction t ON o.CustomerID = t.CustomerID  -- Link Orders and Transactions by CustomerID
        JOIN dbo.Store s ON t.StoreID = s.StoreID  -- Link Transactions and Store by StoreID
        WHERE o.Status = 'Completed'
        GROUP BY DATENAME(WEEKDAY, o.DateTime), DATEPART(HOUR, o.DateTime)

        UNION ALL

        -- Online Orders
        SELECT 
            DATENAME(WEEKDAY, o.DateTime) AS DayOfWeek,
            DATEPART(HOUR, o.DateTime) AS HourOfDay,
            'Online' AS Channel,
            COUNT(o.OrderID) AS PeakOrders
        FROM dbo.Orders o
        WHERE o.Status = 'Completed'
        GROUP BY DATENAME(WEEKDAY, o.DateTime), DATEPART(HOUR, o.DateTime)
    ) AS source
    ON target.DayOfWeek = source.DayOfWeek
       AND target.HourOfDay = source.HourOfDay
       AND target.Channel = source.Channel

    -- Update existing records only if PeakOrders has changed
    WHEN MATCHED AND target.PeakOrders <> source.PeakOrders
    THEN UPDATE SET target.PeakOrders = source.PeakOrders

    -- Insert new records if they don’t exist
    WHEN NOT MATCHED THEN 
        INSERT (DayOfWeek, HourOfDay, Channel, PeakOrders)
        VALUES (source.DayOfWeek, source.HourOfDay, source.Channel, source.PeakOrders);
END;
