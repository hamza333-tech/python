
--
-- 
-- Application SaleSatus 

USE Migration;

STOP APPLICATION salestatus_CDC;
UNDEPLOY APPLICATION salestatus_CDC;
DROP APPLICATION salestatus_CDC CASCADE;
CREATE APPLICATION salestatus_CDC;

--
-- Standard Reader. Nothing special.
-- Why DatabaseReader v MSSqlReader?
-- 
CREATE OR REPLACE SOURCE salestatus_CDC_source USING Global.MSSqlReader ( 
  TransactionSupport: __TRNS_SUPPORT__,
  Compression: __COMPRN__,
  FetchTransactionMetadata: __FETCH_TX_META__,
  ConnectionRetryPolicy: 'timeOut=__CONN_RETRY_TO__, retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password_encrypted: '__PWD_ENCRYPT__', 
  Password: '__SOURCE_PWD__', 
  DatabaseProviderType: 'Default', 
  DatabaseName:__SOURCE_DB__,
  FetchSize: __FETCH_SZ__, 
  adapterName: 'MSSqlReader', 
  StartPosition: '__LSN__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__', 
  Tables: 'dbo.SaleStatus',
  cdcRoleName: 'STRIIM_READER',
  Username: '__SOURCE_UNAME__', 
  IntegratedSecurity: __INTEG_SEC__,
  FilterTransactionBoundaries: __FLTR_TRANS_BNDRS__,
  ConnectionPoolSize: __CONNECT_POOL_SZ__,
  SendBeforeImage: __SEND_BEFORE_IMAGE__,
  AutoDisableTableCDC: __AUTO_DISABLE_TBL_CDC__
) 
OUTPUT TO output_salestatus_CDC;


CREATE OR REPLACE CQ SaleStatus_EN_CQ_Name
INSERT INTO SaleStatus_EN_stream_Name
SELECT
putUserData(t,'Language','EN','Aux','0','Text',data[1] )
FROM output_salestatus_CDC t;

CREATE OR REPLACE CQ SaleStatus_DE_CQ_Name
INSERT INTO SaleStatus_DE_stream_Name
SELECT
putUserData(t,'Language','DE','Aux','0','Text',data[2] )
FROM output_salestatus_CDC t;

CREATE OR REPLACE CQ SaleStatus_CQ_FR_CQ_Name 
INSERT INTO SaleStatus_FR_stream_Name
SELECT
putUserData(t,'Language','FR','Aux','0','Text',data[3] )
FROM output_salestatus_CDC t;

-- The business.SaleStatus Table
--
CREATE OR REPLACE TARGET SaleStatus_CDC_target_SS USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'
	dbo.SaleStatus, __TARGET_DB__.business.SaleStatus columnmap(
		SaleStatusID=SaleStatus_id, 
		GUID=GUID 
  )',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM output_salestatus_CDC;


-- core.Translation table English Name Value  
--
CREATE OR REPLACE TARGET salestatus_target_EN_name USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.SaleStatus, __TARGET_DB__.core.Translation columnmap(
		GUID=GUID, 
		Text=@USERDATA(Text), 
		Language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM SaleStatus_EN_stream_Name;


-- core.Translation table German Name Value  
--
CREATE OR REPLACE TARGET salestatus_target_DE_name USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.SaleStatus, __TARGET_DB__.core.Translation columnmap(
		GUID=GUID, 
		Text=@USERDATA(Text), 
		Language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM SaleStatus_DE_stream_Name;

-- core.Translation table French Name Value  
--
CREATE OR REPLACE TARGET salestatus_target_FR_name USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.SaleStatus, __TARGET_DB__.core.Translation columnmap(
		GUID=GUID, 
		Text=@USERDATA(Text), 
		Language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM SaleStatus_FR_stream_Name;

END APPLICATION salestatus_CDC;


