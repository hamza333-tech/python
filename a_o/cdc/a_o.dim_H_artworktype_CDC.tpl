
--
-- Tables that have change-history but not language translation. Incomplete set includes so far:
-- core.ArtworkType
--
-- ArtworkType
--

USE Migration;

STOP APPLICATION artnet_ops_dim_H_artworktype_CDC;
UNDEPLOY APPLICATION artnet_ops_dim_H_artworktype_CDC;
DROP APPLICATION artnet_ops_dim_H_artworktype_CDC CASCADE;
CREATE APPLICATION artnet_ops_dim_H_artworktype_CDC;

CREATE OR REPLACE SOURCE SQL_DBSource_DIM_H_artworktype_CDC USING Global.MSSqlReader ( 
  TransactionSupport: __TRNS_SUPPORT__,
  Compression: __COMPRN__,
  FetchTransactionMetadata: __FETCH_TX_META__,
  ConnectionRetryPolicy: 'timeOut=__CONN_RETRY_TO__, retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Username: '__SOURCE_UNAME__',
  Password_encrypted: '__PWD_ENCRYPT__',
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  DatabaseName:__SOURCE_DB__,
  FetchSize: __FETCH_SZ__,
  adapterName: 'MSSqlReader',
  StartPosition: '__LSN__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  cdcRoleName: 'STRIIM_READER',
  IntegratedSecurity: __INTEG_SEC__,
  FilterTransactionBoundaries: __FLTR_TRANS_BNDRS__,
  ConnectionPoolSize: __CONNECT_POOL_SZ__,
  SendBeforeImage: __SEND_BEFORE_IMAGE__,
  AutoDisableTableCDC: __AUTO_DISABLE_TBL_CDC__,
  Tables: 'dbo.ArtworkType'
)
OUTPUT TO SQL_DBSource_DIM_H_artworktype_CDC_OutputStream;

CREATE OR REPLACE CQ CQ_JOIN_USERS_ArtworkType_CDC 
INSERT INTO LoginCacheArtworkType 
SELECT putuserdata (s,'LoginName',U.login_name)
FROM SQL_DBSource_DIM_H_artworktype_CDC_OutputStream s
join UserListExternal U
where to_int(s.data[3]) = U.id;

--
--Save Data to TARGET
--use COLUMNMAP to save the Original Username to a Field Called ChangedBy
--
CREATE OR REPLACE TARGET SQL_Target_H_artworktype USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Password: '__TARGET_PWD__', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  IgnorableExceptioncode: 'NO_OP_DELETE',
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
INPUT FROM SQL_DBSource_DIM_H_artworktype_CDC_OutputStream;

CREATE OR REPLACE TARGET CreatedRecord USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  IgnorableExceptioncode: 'NO_OP_DELETE',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: 'Postgres',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: '__SOURCE_DB__.dbo.ArtworkType,core.created columnmap(
        reference_id=ArtworkTypeId,
        table_name=\'ArtworkType\',
        created_date=CreatedDate)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCacheArtworkType;

CREATE OR REPLACE TARGET ChangedRecord USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  IgnorableExceptioncode: 'NO_OP_DELETE',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: 'Postgres',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: '__SOURCE_DB__.dbo.ArtworkType,core.changed columnmap(
        reference_id=ArtworkTypeId,
        table_name=\'ArtworkType\',
        changed_date=ChangedDate,
        changed_by=@userdata(LoginName),
        change_comment=FormerValues)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCacheArtworkType;

END APPLICATION artnet_ops_dim_H_artworktype_CDC;

