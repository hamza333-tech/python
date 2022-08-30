
--
--
-- Gender load

USE Migration;

STOP APPLICATION     a_o_dim_H_gender_CDC;
UNDEPLOY APPLICATION a_o_dim_H_gender_CDC;
DROP APPLICATION     a_o_dim_H_gender_CDC CASCADE;
CREATE APPLICATION   a_o_dim_H_gender_CDC;

CREATE OR REPLACE SOURCE SQL_DBSource_H_gender_CDC USING Global.MSSqlReader ( 
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
  Tables: 'dbo.Gender KeyColumns(GenderId)'
)
OUTPUT TO SQL_DBSource_H_gender_OutputStream_CDC;


--
-- Gender CQ
CREATE OR REPLACE CQ CQ_JOIN_USERS_Gender_CDC 
INSERT INTO LoginCache 
SELECT putuserdata (s,'LoginName',U.login_name)
FROM SQL_DBSource_H_gender_OutputStream_CDC s
left join UserList U
on to_int(s.data[4]) = U.id;

--
-- Gender
--
CREATE OR REPLACE TARGET SQL_Target_H USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Password: '__TARGET_PWD__', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  ConnectionURL: 'jdbc:sqlserver://__TARGET_IP_PORT__;databaseName=__TARGET_DB__', 
  CDDLAction: 'Process', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Tables: 'dbo.Gender,__TARGET_DB__.core.Gender columnmap(
	id=GenderID,
	name=GenderName)', 
  IgnorableExceptioncode : 'NO_OP_DELETE', 
  DatabaseProviderType: 'SQLServer', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM  SQL_DBSource_H_gender_OutputStream_CDC;

-- Created Gender
CREATE OR REPLACE TARGET CreatedRecord_CDC USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__TARGET_IP_PORT__;databaseName=__TARGET_DB__',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: 'dbo.Gender,__TARGET_DB__.core.Created columnmap(
        reference=GenderId,
        table_name=\'Gender\',
        created_date=CreatedDate)',
  DatabaseProviderType: 'SQLServer',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM SQL_DBSource_H_gender_OutputStream_CDC;

CREATE OR REPLACE TARGET ChangedRecordGender_CDC USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__TARGET_IP_PORT__;databaseName=__TARGET_DB__',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: 'dbo.Gender, __TARGET_DB__.core.Changed columnmap(
        reference=GenderId,
        table_name=\'Gender\',
        changed_date=ChangedDate,
        changed_by=@userdata(LoginName),
        change_comment=FormerValues)',
  DatabaseProviderType: 'SQLServer',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCache;


END APPLICATION a_o_dim_H_gender_CDC;

