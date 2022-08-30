
--
-- 
-- Application PricePhrase 

USE Migration;

STOP APPLICATION pricephrase_CDC;
UNDEPLOY APPLICATION pricephrase_CDC;
DROP APPLICATION pricephrase_CDC CASCADE;
CREATE APPLICATION pricephrase_CDC;

--
-- Standard Reader. Nothing special.
-- Why DatabaseReader v MSSqlReader?
-- 
CREATE OR REPLACE SOURCE pricephrase_CDC_source USING Global.MSSqlReader ( 
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
  Tables: 'dbo.PricePhrase',
  cdcRoleName: 'STRIIM_READER',
  Username: '__SOURCE_UNAME__', 
  IntegratedSecurity: __INTEG_SEC__,
  FilterTransactionBoundaries: __FLTR_TRANS_BNDRS__,
  ConnectionPoolSize: __CONNECT_POOL_SZ__,
  SendBeforeImage: __SEND_BEFORE_IMAGE__,
  AutoDisableTableCDC: __AUTO_DISABLE_TBL_CDC__
) 
OUTPUT TO output_pricephrase_CDC;


CREATE OR REPLACE CQ PricePhrase_EN_CQ_Name
INSERT INTO PricePhrase_EN_stream_Name
SELECT
putUserData(t,'Language','EN','Aux','0','Text',data[1] )
FROM output_pricephrase_CDC t;

CREATE OR REPLACE CQ PricePhrase_DE_CQ_Name
INSERT INTO PricePhrase_DE_stream_Name
SELECT
putUserData(t,'Language','DE','Aux','0','Text',data[2] )
FROM output_pricephrase_CDC t;

CREATE OR REPLACE CQ PricePhrase_CQ_FR_CQ_Name 
INSERT INTO PricePhrase_FR_stream_Name
SELECT
putUserData(t,'Language','FR','Aux','0','Text',data[3] )
FROM output_pricephrase_CDC t;

-- The core.PricePhrase Table
--
CREATE OR REPLACE TARGET PricePhrase_CDC_target_SS USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'
	dbo.PricePhrase, __TARGET_DB__.core.PricePhrase columnmap(
		PricePhraseId=PricePhrase_id, 
		PricePhraseGUID=PricePhraseGUID 
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
INPUT FROM output_pricephrase_CDC;


-- core.Translation table English Name Value  
--
CREATE OR REPLACE TARGET pricephrase_target_EN_name USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.PricePhrase, __TARGET_DB__.core.Translation columnmap(
		GUID=PricePhraseGUID, 
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
INPUT FROM PricePhrase_EN_stream_Name;


-- core.Translation table German Name Value  
--
CREATE OR REPLACE TARGET pricephrase_target_DE_name USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.PricePhrase, __TARGET_DB__.core.Translation columnmap(
		GUID=PricePhraseGUID, 
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
INPUT FROM PricePhrase_DE_stream_Name;

-- core.Translation table French Name Value  
--
CREATE OR REPLACE TARGET pricephrase_target_FR_name USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.PricePhrase, __TARGET_DB__.core.Translation columnmap(
		GUID=PricePhraseGUID, 
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
INPUT FROM PricePhrase_FR_stream_Name;

END APPLICATION pricephrase_CDC;


