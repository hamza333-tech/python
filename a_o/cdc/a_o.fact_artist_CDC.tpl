
--
-- 
-- Artist is in its own application for now because it is somewhat more complex than other
-- fact_NH_NL_CDC cases. It produces a core.Artist row, but may also produce a core.Collaborations row.
--
--
-- It can be moved to arnet_ops.fact_NH_NL_CDC.tpl later if warrented.
-- 
-- dbo.Artist
--
--

USE Migration;

STOP APPLICATION artnet_ops_fact_Artist_CDC;
UNDEPLOY APPLICATION artnet_ops_fact_Artist_CDC;
DROP APPLICATION artnet_ops_fact_Artist_CDC CASCADE;
CREATE APPLICATION artnet_ops_fact_Artist_CDC;

CREATE OR REPLACE SOURCE SQL_DBSource_Fact_H_Artist USING Global.MSSqlReader(
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  DatabaseName: '__SOURCE_DB__',
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: '__SOURCE_DB__.dbo.Artist KeyColumns(Artist_id)'
)
OUTPUT TO SQL_DBSource_Fact_H_Artist_OutputStream;

--
CREATE OR REPLACE CQ CQ_JOIN_USERS_Artist
INSERT INTO LoginCache
SELECT putuserdata(s,'CreatedName', R.LoginName, 'ChangedName', H.LoginName,'ApprovalName',A.LoginName)
FROM  SQL_DBSource_Fact_H_Artist_OutputStream s
left join UserListExternal R on to_int(s.data[11]) = R.LoginID
left join UserListExternal H on to_int(s.data[13]) = H.LoginID
left join UserListExternal A on to_int(s.data[15]) = A.LoginID;

--
CREATE OR REPLACE TARGET artnet_ops_fact_Artist_CDC_target USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Tables: '
	__SOURCE_DB__.dbo.Artist, core.Artist columnmap(
          ArtistID=Artist_id
        , Last=Last
        , First=First
        , SortName=Sortname
        , StatusID=Status_id
        , YearBorn=Year_born
        , YearDied=Year_died
        , YearBornModifierID=Year_born_modifier_id
        , YearDiedModifierID=Year_died_modifier_id
        , NationalityID=Nationality_id
        , Aliases=Aliases
        , GalleryID=Gallery_id
        , StartLetter=Start_letter
        , SchoolOf=School_of
        , Notes=notes
        , Flags=flags
        , DisplayDirectory=DisplayDirectory
        , SuppressLots=SuppressLots
        , SuppressImages=SuppressImages
        , ArtistSeoName=artist_seo_name
        , isCollaboration=isCollaboration
        , IsLockedForArtistAdmin=isLockedForArtistAdmin
        , GenderID=GenderId
        , MonthBorn=MonthBorn
        , DayBorn=DayBorn
        , MonthDied=MonthDied
        , DayDied=DayDied
        , CauseOfDeath=CauseOfDeath
        , OverwriteRelatedArtistsAlg=OverwriteRelatedArtistsAlg
        , OverwriteRelatedCategoriesAlg=OverwriteRelatedCategoriesAlg
  )',
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:sqlserver://__TARGET_IP_PORT__;DatabaseName=__TARGET_DB__', 
  DatabaseProviderType: 'SQLServer', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM SQL_DBSource_Fact_H_Artist_OutputStream;



CREATE OR REPLACE TARGET Artist_CreatedRecord_CDC USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__TARGET_IP_PORT__;databaseName=__TARGET_DB__',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: '__SOURCE_DB__.dbo.Artist,core.Created columnmap(
        Reference=Artist_id,
        Table=\'Artist\',
	CreatedBy=@userdata(CreatedName),
        CreatedDate=Created_Date)',
  DatabaseProviderType: 'SQLServer',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCache;

CREATE OR REPLACE TARGET Artist_ApprovalRecord_CDC USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__TARGET_IP_PORT__;databaseName=__TARGET_DB__',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: '__SOURCE_DB__.dbo.Artist,core.Approval columnmap(
        Reference=Artist_id,
        Table=\'Artist\',
	ApprovedBy=@userdata(ApprovedName),
        ApprovalDate=Approved_Date)',
  DatabaseProviderType: 'SQLServer',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCache;

CREATE OR REPLACE TARGET Artist_ChangedRecord_CDC USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__TARGET_IP_PORT__;databaseName=__TARGET_DB__',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: '__SOURCE_DB__.dbo.Artist,core.Changed columnmap(
        Reference=Artist_Id,
        Table=\'Artist\',
        ChangedDate=Changed_Date,
        ChangedBy=@userdata(ChangedName),
        FormerValues=FormerValues)',
  DatabaseProviderType: 'SQLServer',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCache;


END APPLICATION artnet_ops_fact_Artist_CDC;
