USE [FaresDB]
GO

/****** Object:  Trigger [dbo].[Trigger_Replicate_Insert]    Script Date: 07/01/2020 22:03:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[Trigger_Replicate_Insert]
   ON  [dbo].[FareTypes]
   For Insert
AS 
BEGIN
	-- Set NOCOUNT ON added to prevent extra Result Sets from
	-- interfering with SELECT statements.
	Set NOCOUNT ON;

    -- Insert statements for trigger here
	Declare @FileName nvarchar(255);
	Declare @String nvarchar(max);
	
	Set @String = (select * from inserted FOR JSON AUTO)
	
	Declare @Result varchar(max);
	
	Set @Filename =  (select dbo.GenerateFileName('I'))
	
	Set @Result = (select dbo.[WriteDataToFile](@Filename, @String))
		
	if (@Result <> '0')
	Begin 
	
		Declare @ErrorMessage nvarchar(max)	
		Declare @LogString nvarchar(max); 
		Set @LogString = (select * from inserted FOR JSON AUTO);
		Set @ErrorMessage = (select Right(@Result,(Len(@Result)+1) - (CHARINDEX('#',@Result)+1)))

		exec [dbo].[LogError] '[FareTypes]',@ErrorMessage,@LogString,'Insert'
	End 
END
GO

ALTER TABLE [dbo].[FareTypes] ENABLE TRIGGER [Trigger_Replicate_Insert]
GO

