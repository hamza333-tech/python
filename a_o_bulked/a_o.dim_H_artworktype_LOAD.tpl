
--

USE Migration;

STOP APPLICATION a_o_dim_H_artworktype_LOAD;
UNDEPLOY APPLICATION a_o_dim_H_artworktype_LOAD;
DROP APPLICATION a_o_dim_H_artworktype_LOAD CASCADE;
CREATE APPLICATION a_o_dim_H_artworktype_LOAD;

CREATE OR REPLACE SOURCE SQL_DBSource_H_artworktype USING Global.DatabaseReader ( 
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  DatabaseName: '__SOURCE_DB__', 
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: 'ArtworkType KeyColumns(ArtworkTypeID)'
)
OUTPUT TO SQL_DBSource_H_artworktype_OutputStream;

CREATE OR REPLACE CQ CQ_JOIN_USERS_ArtworkType_LOAD 
INSERT INTO LoginCacheArtworkType 
SELECT putuserdata (s,'LoginName',U.login_name)
FROM SQL_DBSource_H_artworktype_OutputStream s
join UserList U
where to_int(s.data[3]) = U.id;

CREATE OR REPLACE TARGET SQL_Target_H USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Password: '__TARGET_PWD__', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: 'Postgres',
  CDDLAction: 'Process', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Tables: '
	__SOURCE_DB__.dbo.ArtworkType,core.artwork_type columnmap(
	id=ArtworkTypeID,
	name=ArtworkTypeName)', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM  SQL_DBSource_H_artworktype_OutputStream;

CREATE OR REPLACE TARGET CreatedRecord USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: 'Postgres',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: '__SOURCE_DB__.dbo.ArtworkType,core.history_created columnmap(
        reference_id=ArtworkTypeId,
        table_name=\'artwork_type\',
        created_date=CreatedDate)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM SQL_DBSource_H_artworktype_OutputStream;

CREATE OR REPLACE TARGET ChangedRecordArtworkType USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: 'Postgres',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: '__SOURCE_DB__.dbo.ArtworkType,core.history_changed columnmap(
        reference_id=ArtworkTypeId,
        table_name=\'artwork_type\',
        changed_date=ChangedDate,
        changed_by=@userdata(LoginName),
        change_comment=FormerValues)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCacheArtworkType;


END APPLICATION a_o_dim_H_artworktype_LOAD;

