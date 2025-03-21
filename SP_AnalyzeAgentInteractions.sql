USE [customer360]
GO
/****** Object:  StoredProcedure [dbo].[AnalyzeAgentInteractions]    Script Date: 19-03-2025 17:17:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[AnalyzeAgentInteractions]
AS
BEGIN
    SET NOCOUNT ON;

    -- Merge new or updated agent interaction data into the AgentInteractionAnalytics table
    MERGE INTO dbo.AgentInteractionAnalytics AS target
    USING (
        SELECT 
            a.AgentID,
            COUNT(cs.InteractionID) AS TotalInteractions,
            -- Avoid division by zero by using NULLIF
            CASE 
                WHEN COUNT(cs.InteractionID) = 0 THEN 0 
                ELSE SUM(CASE WHEN cs.ResolutionStatus = 'Resolved' THEN 1 ELSE 0 END) * 100.0 / COUNT(cs.InteractionID) 
            END AS ResolutionSuccessRate
        FROM dbo.Agent a
        LEFT JOIN dbo.CustomerService cs ON a.AgentID = cs.AgentID
        GROUP BY a.AgentID
    ) AS source
    ON target.AgentID = source.AgentID

    -- If AgentID exists and data has changed, update the record
    WHEN MATCHED AND 
         (target.TotalInteractions <> source.TotalInteractions OR 
          target.ResolutionSuccessRate <> source.ResolutionSuccessRate)
    THEN 
        UPDATE SET 
            target.TotalInteractions = source.TotalInteractions,
            target.ResolutionSuccessRate = source.ResolutionSuccessRate

    -- If AgentID does not exist, insert a new record
    WHEN NOT MATCHED THEN 
        INSERT (AgentID, TotalInteractions, ResolutionSuccessRate)
        VALUES (source.AgentID, source.TotalInteractions, source.ResolutionSuccessRate);

END;
