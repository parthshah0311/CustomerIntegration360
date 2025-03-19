CREATE TABLE dbo.AnalyticsAOV (
    ProductID INT,
    Category NVARCHAR(100),
    Location NVARCHAR(100),
    AverageOrderValue DECIMAL(18, 2)
);
CREATE TABLE dbo.CustomerSegments (
    CustomerID INT,
    Segment NVARCHAR(100),
    TotalSpend DECIMAL(18, 2),
    PurchaseFrequency INT,
    TierLevel NVARCHAR(50)
);
CREATE TABLE dbo.AnalyticsPeakTimes (
    DayOfWeek NVARCHAR(20),
    HourOfDay INT,
    Channel NVARCHAR(20),  -- 'In-Store' or 'Online'
    PeakOrders INT
);
CREATE TABLE dbo.AgentInteractionAnalytics (
    AgentID INT,
    TotalInteractions INT,
    ResolutionSuccessRate DECIMAL(5, 2)  -- Percentage of successful resolutions
);
