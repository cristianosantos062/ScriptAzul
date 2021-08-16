/****** Object:  Table [ADM_BDADOS].[TB3IPROCESS_DETAIL]    Script Date: 15/06/2021 16:40:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ADM_BDADOS].[TB3IDATA_COLLECTION](
	[collection_time] datetime NULL,
	[data_collection] date NULL,
	[time_collection] time NULL,
	[hr_collection] smallint NULL,
	[mm_collection] smallint NULL) 
ON [PRIMARY]
GO


DECLARE @coleta datetime
SET @coleta = GETDATE()

SELECT @coleta AS [collection_time]
		,CAST( @coleta as date) AS [data_collection]
		,CAST( @coleta as time) AS [time_collection]
		,DATEPART(HH, @coleta) AS [hr_collection]
		,DATEPART(MM, @coleta) AS [mm_collection]
