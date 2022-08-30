
-- This file contains the snips you have to run to install a given TQL on a new environment.
-- THIS MAY ALL BE OBSOLETE. Setting up CHKPOINT and CDC is elsewhere.

USE Artnet
GO
IF OBJECT_ID(N'[CHKPOINT]', N'U') IS NOT NULL
   DROP TABLE [CHKPOINT];
GO

CREATE TABLE CHKPOINT (
id VARCHAR(100) PRIMARY KEY,
sourceposition VARBINARY(MAX),
pendingddl BIT,
ddl VARCHAR(MAX));

-- to enable CDC on the entire database
EXEC sys.sp_cdc_enable_db;

-- To see if a given table has CDC enabled
EXEC sys.sp_cdc_help_change_data_capture;
GO


-- For all tables: If the previous line doesn't show CDC enabled, you need to run this for
-- the appropriate table in this case, dbo.Coordinators

USE [Artnet];
EXEC sys.sp_cdc_enable_table
@source_schema = N'dbo',
@source_name = N'Coordinators',
@role_name = NULL;
GO

-- to disable CDC for the same table.
--
EXEC sys.sp_cdc_disable_table
  @source_schema = N'dbo',
  @source_name = N'Coordinators',
  @capture_instance = N'dbo_Coordinators';
GO

--- ArtnetType

Where is the test insert/delete code?

--- BUSINESS
--- business.COORDINATORS Table

USE [Artnet_SharedDevelopment];

INSERT INTO dbo.Coordinators (Coordinator_login_id, Coordinator_name, Coordinator_initials,
Commission, Picture, Occupation, Phone )
VALUES (11,'peter coates', 'PTC', 0.28, 'none', 'programmer','917 864 6619' )

DELETE FROM dbo.Coordinators WHERE Coordinator_name='peter coates'

USE [Ops_artnet];
SELECT * FROM business.Coordinators where Coordinator_name='peter coates'

-- business.Logins
-- Don't forget to modify the third field, Login_Name, for each insertion
insert into [dbo].[Logins]( Login_Type_id
	, Group_ind , Login_Name , Password , Password_hint
	, Email , FirstName , MiddleInitial , LastName , CompanyName
	, ReasonToJoinID , Member_type_id , Active_Ind , CustomerNum
	, IsBusinessPurpose , Url , Company_type_id , GalleryNum , Salesman_id
	, Coordinator_Id , UserId) values (
	    1,1,'zorch17','secretpassword', 'pwhint','coatespt@gmail.com','peter','t','coates',
	    'artnet',1,1,1,1,1,'http://artnet.com', 1,1,1,1,newid());

select * from dbo.Logins where email = 'coatespt@gmail.com'

delete from dbo.Logins where email = 'coatespt@gmail.com'

-- business.LoginType

INSERT INTO Login_type (Login_type_name) VALUES ('dweezel')
DELETE FROM Login_type WHERE Login_type_name = 'dweezel'

-- business.Salesman

INSERT INTO dbo.Salesman (SalesmanFullName, SalesmanInitials, Commission, Salesman_Login_Id, IsDeleted)
VALUES ('peter coates','T',.20, 11, 0);

DELETE FROM dbo.Salesman where SalesmanFullName='peter coates';


--- CORE

-- core.Currency

INSERT INTO dbo.Currency (Currency_name, Description, Active_ind, Symbol)
    VALUES ('BUX', 'american dinero',1,'BU')
DELETE FROM  dbo.Currency where Currency_name = 'BUX'

-- business.CustomerSource
INSERT INTO dbo.Customer_Source (Customer_source_name) VALUES ('peter coates')
DELETE FROM  dbo.Customer_Source WHERE Customer_source_name='peter coates'

-- core.GalleryType

insert into gallery_type (gallery_type_name) values ('moonunit')
delete from gallery_type where gallery_type_name='moonunit'

-- core.Status

INSERT INTO dbo.Status (status_name) VALUES ('differently-abled')
DELETE FROM dbo.Status where status_name = 'differently-abled'

-- WorkType  NEW TABLE MUST BE POPULATED

insert into core.WorkType (WorkTypeName, Description) values ('Painting','Painting');
insert into core.WorkType (WorkTypeName, Description) values ('WoP','Work on paper');
insert into core.WorkType (WorkTypeName, Description) values ('Watercolor','Watercolor painting');

update core.WorkType set LegacyWorkTypeID=WorkTypeID where WorkTypeID is not null;

select * from core.WorkType

-- Medium NEW TABLE MUST BE POPULATED

update core.Medium set LegacyMediumID=MediumID where MediumID is not null;

insert into core.medium (MediumName, Description) values ('Canvas','Stretched canvas');
insert into core.medium (MediumName, Description) values ('Wood panel','Wood panel of unspecified species');
insert into core.medium (MediumName, Description) values ('Masonite panel','Masonite hardboard panel');
insert into core.medium (MediumName, Description) values ('Cradled wooden panel','Wooden panel mounted on frame');

select * from core.Medium
-- Substrate NEW TABLE MUST BE POPULATED
These are examples. This set has to be computed and inserted 

insert into core.substrate (SubstrateName, Description) values ('Oil','Oil paint')
insert into core.substrate (SubstrateName, Description) values ('Acrylic','Acrylic paint')
insert into core.substrate (SubstrateName, Description) values ('Tempera','Tempera paint')
insert into core.substrate (SubstrateName, Description) values ('Alkyd','Alkyd oil paint')
insert into core.substrate (SubstrateName, Description) values ('Crayons','Crayola')

update core.Substrate set LegacySubstrateID=SubstrateID where SubstrateID is not null
select * from core.Substrate


-- Dimension NEW TABLE MUST BE POPULATED


insert into core.Dimension (DimensionName, Description) values ('1-D','Sound');
insert into core.Dimension (DimensionName, Description) values ('2-D','Two dimensional e.g. painting, drawing');
insert into core.Dimension (DimensionName, Description) values ('3-D','Sculpture');
insert into core.Dimension (DimensionName, Description) values ('Moving Image','Video, film, etc.');
insert into core.Dimension (DimensionName, Description) values ('Installation','Location-specific constructions in space.');
insert into core.Dimension (DimensionName, Description) values ('Conceptual','Dimensions N/A');

update core.Dimension set LegacyDimensionID=DimensionId where DimensionID is not null

select * from core.Dimension




INSERT INTO dbo.Nationality (
  Nationality_name_US,
  Nationality_name_FR,
  Nationality_name_DE,
  Nationality_aliases_DE,
  Nationality_aliases_FR,
  Nationality_aliases_US)
  VALUES ('US-Name', 'FR-name', 'DE-name', 'DE-alias', 'FR-alias', 'US-alias')

DELETE FROM Nationality where Nationality_id > 484
"





