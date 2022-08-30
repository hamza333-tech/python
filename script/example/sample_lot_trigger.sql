

IF OBJECT_ID(N'[core].[TestOne]', N'U') IS NOT NULL
   DROP TABLE [core].[TestOne];
GO

CREATE TABLE [core].[TestOne] (
    [TestOnePK]  INT         NULL,
    [TestOnePK2] INT         NOT NULL IDENTITY (100000000,1),
    [VC1]        VARCHAR(10) NULL,
    [VC2]        VARCHAR(10) NULL
)

insert into core.TestOne (TestOnePK, VC1, VC2) values (null, 'value one', 'value two');
insert into core.TestOne (TestOnePK, VC1, VC2) values (123, 'value one', 'value two');
insert into core.TestOne (TestOnePK, VC1, VC2) values (124, 'value one', 'value two');
insert into core.TestOne (TestOnePK, VC1, VC2) values (125, 'value one', 'value two');

SELECT * FROM core.TestOne;

CREATE TRIGGER TestOneTrigger on core.TestOne
    AFTER INSERT
    NOT FOR REPLICATION
    AS
    UPDATE core.TestOne  set TestOnePK=TestOnePk2
    where TestOnePK IS NULL


