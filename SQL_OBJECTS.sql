USE [Testing_MovieStore]
GO
/****** Object:  User [sa1]    Script Date: 04/01/2024 10:38:02 ******/
CREATE USER [sa1] FOR LOGIN [sa1] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  Table [dbo].[tbl_movie]    Script Date: 04/01/2024 10:38:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_movie](
	[idmovie] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[status] [bit] NOT NULL,
	[launch] [bit] NOT NULL,
	[datecreate] [datetime] NOT NULL,
 CONSTRAINT [PK_tbl_movie] PRIMARY KEY CLUSTERED 
(
	[idmovie] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_rel_control_movie]    Script Date: 04/01/2024 10:38:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_rel_control_movie](
	[idcontrol] [int] IDENTITY(1,1) NOT NULL,
	[iduser] [int] NOT NULL,
	[idmovie] [int] NOT NULL,
	[date_initial] [datetime] NOT NULL,
	[date_final] [datetime] NOT NULL,
	[devolution] [datetime] NULL,
 CONSTRAINT [PK_tbl_rel_control_movie] PRIMARY KEY CLUSTERED 
(
	[idcontrol] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_user]    Script Date: 04/01/2024 10:38:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_user](
	[iduser] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[status] [bit] NOT NULL,
	[datecreate] [datetime] NOT NULL,
 CONSTRAINT [PK_user] PRIMARY KEY CLUSTERED 
(
	[iduser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[prc_movie_insert]    Script Date: 04/01/2024 10:38:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Pedro Henrique Priuli>
-- Create date: <Create Date, 18-06-2020,>
-- Description:	<Description, Rental movie registration table,>
-- =============================================
/*
 DECLARE @X INT
 EXEC prc_movie_insert 
	  'Fear The Walking Dead - Complete Season',
	  1,
	  @X OUTPUT
 SELECT @X
 */
-- =============================================
CREATE PROCEDURE [dbo].[prc_movie_insert]
	-- Add the parameters for the stored procedure here
	@name_varchar varchar(50),
	@launch_bit bit,
	@idmovie_int int OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	

    -- Insert statements for procedure here
	INSERT INTO tbl_movie (
		[name],
		[status],
		launch,
		datecreate
	)VALUES(
		@name_varchar,
		1,
		@launch_bit,
		getdate()
	);

	SET @idmovie_int = SCOPE_IDENTITY()	

END
GO
/****** Object:  StoredProcedure [dbo].[prc_rel_control_movie_history_select]    Script Date: 04/01/2024 10:38:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Pedro Henrique Priuli>
-- Create date: <Create Date, 20-06-2020,>
-- Description:	<Description, Rental movie registration table,>
-- =============================================
CREATE PROCEDURE [dbo].[prc_rel_control_movie_history_select]
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT

		tbl1.iduser,
		tbl1.name,
		tbl1.status,
		tbl1.datecreate,
		COUNT(tbl2.idcontrol) AS pendence

	FROM [dbo].[tbl_user] tbl1
	LEFT JOIN [dbo].[tbl_rel_control_movie] tbl2 on (tbl2.iduser = tbl1.iduser)
	WHERE  tbl2.devolution IS NULL
	GROUP BY 

		tbl1.iduser,
		tbl1.name,
		tbl1.status,
		tbl1.datecreate
		ORDER BY tbl1.name,tbl1.datecreate
		--HAVING count(tbl2.idcontrol) > 0
END
GO
/****** Object:  StoredProcedure [dbo].[prc_rel_control_movie_insert]    Script Date: 04/01/2024 10:38:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Pedro Henrique Priuli>
-- Create date: <Create Date, 18-06-2020,>
-- Description:	<Description, Loan control record table,>
-- =============================================
/*
 DECLARE @X INT
 EXEC prc_rel_control_movie_insert 
	  1,
	  1,
	  null,
	  @X OUTPUT
 SELECT @X
 */
-- =============================================
CREATE PROCEDURE [dbo].[prc_rel_control_movie_insert]
	-- Add the parameters for the stored procedure here
	@iduser_int int,
	@idmovie_int int,
	@date_final_date datetime = NULL

AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	

BEGIN TRY

	DECLARE @success_int INT = 0

	IF(@date_final_date <> NULL AND @date_final_date < GETDATE())
	BEGIN
		SET @date_final_date = GETDATE()
	END

    -- Insert statements for procedure here

	IF NOT EXISTS(
		SELECT 1 FROM tbl_rel_control_movie
		WHERE iduser = @iduser_int
		AND idmovie = @idmovie_int
		AND devolution is null
	)
	BEGIN
	INSERT INTO tbl_rel_control_movie(
		iduser,
		idmovie,
		date_initial,
		date_final,
		devolution
	)VALUES(
		@iduser_int,
		@idmovie_int,
		getdate(),
		IIF( ISNULL(@date_final_date,0) = 0 , DATEADD(day, 2, getdate()) , @date_final_date),
		NULL
	);

		SET @success_int = 1

	END
	ELSE
	BEGIN
		SET @success_int = 2
	END

	SELECT @success_int

END TRY  
BEGIN CATCH  
     
	 SELECT -1

END CATCH  

END
GO
/****** Object:  StoredProcedure [dbo].[prc_user_insert]    Script Date: 04/01/2024 10:38:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Pedro Henrique Priuli>
-- Create date: <Create Date, 17-06-2020,>
-- Description:	<Description, User and customer registration table,>
-- =============================================
/*
 DECLARE @X INT
 EXEC prc_user_insert 
	  'Pedro Henrique Priuli'
	  @X OUTPUT
 SELECT @X
 */
-- =============================================
CREATE PROCEDURE [dbo].[prc_user_insert]
	-- Add the parameters for the stored procedure here
	@name_varchar varchar(50),
	@iduser_int int OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	

    -- Insert statements for procedure here
	INSERT INTO tbl_user (
		[name],
		[status],
		datecreate
	)VALUES(
		@name_varchar,
		1,
		getdate()
	);

	SET @iduser_int = SCOPE_IDENTITY()	

END
GO
