

--
-- Dimension type tables with history and translations
-- Currently has only
-- 	core.Artist_Modifier
--
USE Migration;

STOP APPLICATION a_o_H_L_LOAD;
UNDEPLOY APPLICATION a_o_H_L_LOAD;
DROP APPLICATION a_o_H_L_LOAD CASCADE;
CREATE APPLICATION a_o_H_L_LOAD;

CREATE OR REPLACE SOURCE Source_dim_H_L_LOAD USING Global.DatabaseReader ( 
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  DatabaseName: '__SOURCE_DB__', 
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: 'dbo.Artist_Modifier KeyColumns(Artist_modifier_id)'
)
OUTPUT TO Source_dim_H_L_LOAD_OS;

CREATE OR REPLACE CQ CQ_Load_Artist_Modifier_Changed
INSERT INTO LoginCacheChanged 
SELECT putuserdata (s,'LoginName',U.login_name)
FROM Source_dim_H_L_LOAD_OS s
join UserList U
where to_int(s.data[9]) = U.id;

CREATE OR REPLACE CQ CQ_Load_Artist_Modifier_Created 
INSERT INTO LoginCacheCreated 
SELECT putuserdata (s,'LoginName',U.login_name)
FROM Source_dim_H_L_LOAD_OS s
join UserList U
where to_int(s.data[10]) = U.id;

-- Need to add ChangeDescription to the SourceTable.
--
--Save Data to TARGET
--use COLUMNMAP to sve the Original Username to a Field Called ChangedBy
--

CREATE OR REPLACE TARGET ArtistModifier_SQL_Target USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Password: '__TARGET_PWD__', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  CDDLAction: 'Process', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Tables: '__SOURCE_DB__.dbo.Artist_Modifier,__TARGET_DB__.core.artist_modifier columnmap(
	id=Artist_modifier_id,
	name=Artist_modifier_name,
	guid=NameGUID
  )', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM Source_dim_H_L_LOAD_OS;

CREATE OR REPLACE TARGET ArtistModifierCreatedRecord USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Password: '__TARGET_PWD__', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  CDDLAction: 'Process', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter',
  Tables: '__SOURCE_DB__.dbo.Artist_Modifier,core.history_created columnmap(
	reference_id=Artist_Modifier_id,
	table_name=\'artist_modifier\', 
	created_by=@userdata(LoginName),
	created_date=Created_Date)' 
) 
INPUT FROM LoginCacheCreated;

CREATE OR REPLACE TARGET ArtistModifierChangedRecord USING Global.DatabaseWriter ( 
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Password: '__TARGET_PWD__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  CDDLAction: 'Process', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter',
  Tables: '__SOURCE_DB__.dbo.Artist_Modifier,core.history_changed columnmap(
	reference_id=Artist_Modifier_id,
	table_name=\'artist_modifier\', 
	changed_date=Changed_Date,
	changed_by=@userdata(LoginName),
	change_comment=FormerValues)' 
  ) 
INPUT FROM LoginCacheChanged;

CREATE OR REPLACE TARGET artnet_ops_dim_H_L_LOAD_target_DE1 USING Global.DatabaseWriter(
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  Password_encrypted: '__PWD_ENCRYPT__',
  CheckPointTable: '__CHKPOINT__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  adapterName: 'DatabaseWriter', 
  Tables:'__SOURCE_DB__.dbo.Artist_Modifier, __TARGET_DB__.core.translation columnmap(
          guid=NameGUID,
          text=Artist_modifier_name_de,
          language=\'DE\')'
)
INPUT FROM Source_dim_H_L_LOAD_OS;

CREATE OR REPLACE TARGET artnet_ops_dim_H_L_LOAD_target_FR1 USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  CDDLAction: 'Process',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Password: '__TARGET_PWD__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  adapterName: 'DatabaseWriter', 
  Tables:' __SOURCE_DB__.dbo.Artist_Modifier, __TARGET_DB__.core.translation columnmap(
                guid=NameGUID,
                text=Artist_modifier_name_fr,
                language=\'FR\')'
  )
INPUT FROM Source_dim_H_L_LOAD_OS;

CREATE OR REPLACE TARGET artnet_ops_dim_H_L_LOAD_target_EN1 USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=3',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  CDDLAction: 'Process',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Password: '__TARGET_PWD__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  adapterName: 'DatabaseWriter', 
  Tables:'
        __SOURCE_DB__.dbo.Artist_modifier, __TARGET_DB__.core.translation columnmap(
                guid=NameGUID,
                text=Artist_modifier_name_en,
                language=\'EN\')'
)
INPUT FROM Source_dim_H_L_LOAD_OS;

END APPLICATION a_o_H_L_LOAD;



