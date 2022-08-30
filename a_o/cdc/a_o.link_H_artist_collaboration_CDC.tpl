
--

USE Migration;

STOP APPLICATION artnet_link_H_CDC;
UNDEPLOY APPLICATION artnet_link_H_CDC;
DROP APPLICATION artnet_link_H_CDC CASCADE;
CREATE APPLICATION artnet_link_H_CDC;

CREATE OR REPLACE SOURCE SQL_DBSource_link_H_CDC USING Global.MSSqlReader ( 
  DatabaseName: '__SOURCE_DB__',
  TransactionSupport: __TRNS_SUPPORT__,
  IntegratedSecurity: __INTEG_SEC__,
  adapterName: 'MSSqlReader',
  cdcRoleName: 'STRIIM_READER',
  Password: '__SOURCE_PWD__',
  Password_encrypted: '__PWD_ENCRYPT__',
  Username: '__SOURCE_UNAME__',
  Compression: __COMPRN__,
  ConnectionPoolSize: __CONNECT_POOL_SZ__,
  FetchTransactionMetadata: __FETCH_TX_META__,
  ConnectionRetryPolicy: 'timeOut=__CONN_RETRY_TO__, retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  StartPosition: '__LSN__',
  FetchSize: __FETCH_SZ__,
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  FilterTransactionBoundaries: __FLTR_TRANS_BNDRS__,
  SendBeforeImage: __SEND_BEFORE_IMAGE__,
  AutoDisableTableCDC: __AUTO_DISABLE_TBL_CDC__,
  Tables: 'dbo.ArtistCollaboration KeyColumns(RowID)'
)
OUTPUT TO SQL_DBSource_link_H_CDC_OutputStream;

CREATE OR REPLACE CQ CQ_ArtistCollaborationCreatedByCdc 
INSERT INTO LoginCacheArtistCollaborationCreatedBy 
SELECT putuserdata (s,'LoginName',U.LoginName)
FROM SQL_DBSource_link_H_CDC_OutputStream s
join UserList U
where to_int(s.data[4]) = U.LoginID;

CREATE OR REPLACE CQ CQ_ArtistCollaborationChangedByCdc 
INSERT INTO LoginCacheArtistCollaborationChangedBy 
SELECT putuserdata (s,'LoginName',U.LoginName)
FROM SQL_DBSource_link_H_CDC_OutputStream s
join UserList U
where to_int(s.data[6]) = U.LoginID;

CREATE OR REPLACE TARGET Target_link_H_ArtistCollaboration_CDC USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Password: '__TARGET_PWD__', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  ConnectionURL: 'jdbc:sqlserver://__TARGET_IP_PORT__;databaseName=__TARGET_DB__', 
  CDDLAction: 'Process', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Tables: '
	dbo.ArtistCollaboration,__TARGET_DB__.core.ArtistCollaboration columnmap(
	RowID=RowId,
	ArtistIDCollaboration=ArtistIdCollaboration,
	ArtistIDSolo=ArtistIdSolo,
	SortOrder=SortOrder
  )', 
  IgnorableExceptioncode : 'NO_OP_DELETE',
  DatabaseProviderType: 'SQLServer', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM  SQL_DBSource_link_H_CDC_OutputStream;

CREATE OR REPLACE TARGET Target_link_H_ArtistCollaboration_CDC_Created USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__TARGET_IP_PORT__;databaseName=__TARGET_DB__',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: 'dbo.ArtistCollaboration,__TARGET_DB__.core.Created columnmap(
        Reference=RowId,
        Table=\'ArtistCollaboration\',
        CreatedBy=@userdata(LoginName),
        CreatedDate=CreatedDate)',
  IgnorableExceptioncode : 'NO_OP_DELETE',
  DatabaseProviderType: 'SQLServer',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCacheArtistCollaborationCreatedBy;

CREATE OR REPLACE TARGET Target_link_H_ArtistCollaboration_CDC_Changed USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__TARGET_IP_PORT__;databaseName=__TARGET_DB__',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: 'dbo.ArtistCollaboration,__TARGET_DB__.core.Changed columnmap(
        Reference=RowId,
        Table=\'ArtistCollaboration\',
        ChangedDate=ChangedDate,
        ChangedBy=@userdata(LoginName),
        FormerValues=FormerValues)',
  IgnorableExceptioncode : 'NO_OP_DELETE',
  DatabaseProviderType: 'SQLServer',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCacheArtistCollaborationChangedBy;


END APPLICATION artnet_link_H_CDC;

