

-- Application PriceSatatus 

USE Migration;

STOP APPLICATION pricestatus_CDC;
UNDEPLOY APPLICATION pricestatus_CDC;
DROP APPLICATION pricestatus_CDC CASCADE;
CREATE APPLICATION pricestatus_CDC;

--
-- Standard Reader. Nothing special.
-- 
CREATE OR REPLACE SOURCE pricestatus_CDC_source USING Global.MSSqlReader ( 
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
  Tables: 'dbo.PriceStatus',
  cdcRoleName: 'STRIIM_READER',
  Username: '__SOURCE_UNAME__', 
  IntegratedSecurity: __INTEG_SEC__,
  FilterTransactionBoundaries: __FLTR_TRANS_BNDRS__,
  ConnectionPoolSize: __CONNECT_POOL_SZ__,
  SendBeforeImage: __SEND_BEFORE_IMAGE__,
  AutoDisableTableCDC: __AUTO_DISABLE_TBL_CDC__
) 
OUTPUT TO output_pricestatus_CDC;


CREATE OR REPLACE CQ PriceStatus_EN_CQ_Desc
INSERT INTO PriceStatus_EN_stream_Desc
SELECT
putUserData(t,'Language','EN','Aux','0','Text',data[1] )
FROM output_pricestatus_CDC t;

CREATE OR REPLACE CQ PriceStatus_DE_CQ_Desc
INSERT INTO PriceStatus_DE_stream_Desc
SELECT
putUserData(t,'Language','DE','Aux','0','Text',data[2] )
FROM output_pricestatus_CDC t;

CREATE OR REPLACE CQ PriceStatus_CQ_FR_CQ_Desc 
INSERT INTO PriceStatus_FR_stream_Desc
SELECT
putUserData(t,'Language','FR','Aux','0','Text',data[3] )
FROM output_pricestatus_CDC t;

-- The core.PriceStatus Table
--
CREATE OR REPLACE TARGET PriceStatus_CDC_target_SS USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'
	dbo.PriceStatus, __TARGET_DB__.core.PriceStatus columnmap(
		PriceStatusID=PriceStatus_id, 
		PriceStatusGUID=PriceStatusGUID 
  )',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  CDDLAction: 'Process', 
  BatchPolicy: '__BATCH_POLICY__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:sqlserver://__TARGET_IP_PORT__;DatabaseName=__TARGET_DB__', 
  DatabaseProviderType: 'SQLServer', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM output_pricestatus_CDC;


-- core.Translation table English Desc Value  
--
CREATE OR REPLACE TARGET pricestatus_target_EN_name USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.PriceStatus, __TARGET_DB__.core.Translation columnmap(
		GUID=PriceStatusGUID, 
		Text=@USERDATA(Text), 
		Language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  CDDLAction: 'Process', 
  BatchPolicy: '__BATCH_POLICY__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:sqlserver://__TARGET_IP_PORT__;DatabaseName=__TARGET_DB__', 
  DatabaseProviderType: 'SQLServer', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM PriceStatus_EN_stream_Desc;


-- core.Translation table German Desc Value  
--
CREATE OR REPLACE TARGET pricestatus_target_DE_name USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.PriceStatus, __TARGET_DB__.core.Translation columnmap(
		GUID=PriceStatusGUID, 
		Text=@USERDATA(Text), 
		Language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  CDDLAction: 'Process', 
  BatchPolicy: '__BATCH_POLICY__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:sqlserver://__TARGET_IP_PORT__;DatabaseName=__TARGET_DB__', 
  DatabaseProviderType: 'SQLServer', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM PriceStatus_DE_stream_Desc;

-- core.Translation table French Desc Value  
--
CREATE OR REPLACE TARGET pricestatus_target_FR_name USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.PriceStatus, __TARGET_DB__.core.Translation columnmap(
		GUID=PriceStatusGUID, 
		Text=@USERDATA(Text), 
		Language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  CDDLAction: 'Process', 
  BatchPolicy: '__BATCH_POLICY__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:sqlserver://__TARGET_IP_PORT__;DatabaseName=__TARGET_DB__', 
  DatabaseProviderType: 'SQLServer', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM PriceStatus_FR_stream_Desc;

END APPLICATION pricestatus_CDC;


