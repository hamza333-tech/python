
--
-- 
-- Artist is in its own application for now because it is somewhat more complex than other
-- fact_NH_NL_LOAD cases. It produces a core.Artist row, but may also produce a core.Collaborations row.
--
--
-- It can be moved to arnet_ops.fact_NH_NL_LOAD.tpl later if warrented.
-- 
-- dbo.Artist
--
--

USE Migration;

STOP APPLICATION a_o_fact_Artist_LOAD;
UNDEPLOY APPLICATION a_o_fact_Artist_LOAD;
DROP APPLICATION a_o_fact_Artist_LOAD CASCADE;
CREATE APPLICATION a_o_fact_Artist_LOAD;

CREATE OR REPLACE SOURCE SQL_DBSource_Fact_H_Artist USING Global.DatabaseReader (
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
SELECT putuserdata(s,'CreatedName', R.login_name, 'ChangedName', H.login_name,'ApprovalName',A.login_name)
FROM  SQL_DBSource_Fact_H_Artist_OutputStream s
left join UserList R on to_int(s.data[11]) = R.id
left join UserList H on to_int(s.data[13]) = H.id
left join UserList A on to_int(s.data[15]) = A.id;

--
CREATE OR REPLACE TARGET a_o_fact_Artist_LOAD_target USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Tables: '
	__SOURCE_DB__.dbo.Artist, core.Artist columnmap(
          id=Artist_id
        , last=Last
        , first=First
        , sort_name=Sortname
        , status_id=Status_id
        , year_born=Year_born
        , year_died=Year_died
        , year_born_modifier_id=Year_born_modifier_id
        , year_died_modifier_id=Year_died_modifier_id
        , nationality_id=Nationality_id
        , aliases=Aliases
        , gallery_id=Gallery_id
        , start_letter=Start_letter
        , school_of=School_of
        , notes=notes
        , flags=flags
        , display_directory=DisplayDirectory
        , suppress_lots=SuppressLots
        , suppress_images=SuppressImages
        , artist_seo_name=artist_seo_name
        , is_collaboration=isCollaboration
        , is_locked_for_artist_admin=isLockedForArtistAdmin
        , gender_id=GenderId
        , month_born=MonthBorn
        , day_born=DayBorn
        , month_died=MonthDied
        , day_died=DayDied
        , cause_of_death=CauseOfDeath
        , overwrite_related_artists_alg=OverwriteRelatedArtistsAlg
        , overwrite_related_categories_alg=OverwriteRelatedCategoriesAlg
  )',
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM SQL_DBSource_Fact_H_Artist_OutputStream;



CREATE OR REPLACE TARGET Artist_CreatedRecord_LOAD USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: '__SOURCE_DB__.dbo.Artist,core.history_created columnmap(
        reference_id=Artist_id,
        table_name=\'artist\',
	created_by=@userdata(CreatedName),
        created_date=Created_Date)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCache;

CREATE OR REPLACE TARGET Artist_ApprovalRecord_LOAD USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: '__SOURCE_DB__.dbo.Artist,core.history_approval columnmap(
        reference_id=Artist_id,
        table_name=\'artist\',
	approved_by=@userdata(ApprovedName),
        approval_date=Approved_Date)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCache;

CREATE OR REPLACE TARGET Artist_ChangedRecord_LOAD USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: '__SOURCE_DB__.dbo.Artist,core.history_changed columnmap(
        reference_id=Artist_Id,
        table_name=\'artist\',
        changed_date=Changed_Date,
        changed_by=@userdata(ChangedName),
        change_comment=FormerValues)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCache;


END APPLICATION a_o_fact_Artist_LOAD;
