--
--
-- WHY IS THIS PULLED OUT OF ONE VERSION OF a_o.dim_L_LOAD.tpl
--
--
USE Migration;

STOP APPLICATION city_CDC;
UNDEPLOY APPLICATION city_CDC;
DROP APPLICATION city_CDC CASCADE;
CREATE APPLICATION city_CDC;

CREATE OR REPLACE SOURCE city_CDC_source USING Global.MSSqlReader ( 
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
  cdcRoleName: 'STRIIM_READER',
  Username: '__SOURCE_UNAME__', 
  IntegratedSecurity: __INTEG_SEC__,
  FilterTransactionBoundaries: __FLTR_TRANS_BNDRS__,
  ConnectionPoolSize: __CONNECT_POOL_SZ__,
  SendBeforeImage: __SEND_BEFORE_IMAGE__,
  AutoDisableTableCDC: __AUTO_DISABLE_TBL_CDC__,
  Tables: 'dbo.City'
 ) OUTPUT TO output_city_CDC;

CREATE OR REPLACE CQ City_EN_CQ_Name
INSERT INTO EN_stream_Name
SELECT putUserData(t,'Language','EN','Aux','0','Text',data[1] )
FROM output_city_CDC t;

CREATE OR REPLACE CQ City_EN_CQ_Aliases
INSERT INTO EN_stream_Aliases
SELECT putUserData(t,'Language','EN','Aux','0','Text',data[2] )
FROM output_city_CDC t;

CREATE OR REPLACE CQ City_DE_CQ_Name 
INSERT INTO DE_stream_Name
SELECT putUserData(t,'Language','DE','Aux','0','Text',data[3] )
FROM output_city_CDC t;

CREATE OR REPLACE CQ City_DE_CQ_Aliases
INSERT INTO DE_stream_Aliases 
SELECT putUserData(t,'Language','DE','Aux','0','Text',data[4] )
FROM output_city_CDC t;

CREATE OR REPLACE CQ City_FR_CQ_Name 
INSERT INTO FR_stream_Name 
SELECT putUserData(t,'Language','FR','Aux','0','Text',data[7] )
FROM output_city_CDC t;

CREATE OR REPLACE CQ City_FR_CQ_Aliases 
INSERT INTO FR_stream_Aliases 
SELECT putUserData(t,'Language','FR','Aux','0','Text',data[8] )
FROM output_city_CDC t;

CREATE OR REPLACE CQ City_EN_CQ_CitySeo 
INSERT INTO EN_stream_CitySeo 
SELECT putUserData(t,'Language','EN','Aux','0','Text',data[9] )
FROM output_city_CDC t;

CREATE OR REPLACE CQ City_DE_CQ_CitySeo 
INSERT INTO DE_stream_CitySeo 
SELECT putUserData(t,'Language','DE','Aux','0','Text',data[10] )
FROM output_city_CDC t;

CREATE OR REPLACE CQ City_FR_CQ_CitySeo 
INSERT INTO FR_stream_CitySeo 
SELECT putUserData(t,'Language','FR','Aux','0','Text',data[11] )
FROM output_city_CDC t;


CREATE OR REPLACE TARGET city_CDC_target_SS USING Global.DatabaseWriter( 
  Tables:'dbo.City, __TARGET_DB__.core.City columnmap(
		CityId=City_id, 
		CountryID=Country_id,
		StateId=State_id,
		NameGUID=NameGUID, 
		AliasesGUID=AliasesGUID,
		CitySeoGUID=CitySeoGUID
  )',
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
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
  adapterName: 'DatabaseWriter') INPUT FROM output_city_CDC;

CREATE OR REPLACE TARGET city_target_EN_name USING Global.DatabaseWriter( 
  Tables:'dbo.City, __TARGET_DB__.core.Translation columnmap(
		GUID=NameGUID, 
		Text=@USERDATA(Text), 
		Language=@USERDATA(Language))',
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
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
  adapterName: 'DatabaseWriter' ) INPUT FROM EN_stream_Name;

CREATE OR REPLACE TARGET city_target_DE_Name USING Global.DatabaseWriter( 
  Tables:'dbo.City, __TARGET_DB__.core.Translation columnmap(
		GUID=NameGUID, 
		Text=@USERDATA(Text), 
		Language=@USERDATA(Language))',
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
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
  adapterName: 'DatabaseWriter' ) INPUT FROM DE_stream_Name;

CREATE OR REPLACE TARGET city_target_FR_NAME USING Global.DatabaseWriter( 
  Tables:'dbo.City, __TARGET_DB__.core.Translation columnmap(
		GUID=NameGUID, 
		Text=@USERDATA(Text), 
		Language=@USERDATA(Language))',
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
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
  adapterName: 'DatabaseWriter' ) INPUT FROM FR_stream_Name;

CREATE OR REPLACE TARGET city_target_EN_aliases USING Global.DatabaseWriter( 
  Tables:'dbo.City, __TARGET_DB__.core.Translation columnmap(
		GUID=AliasesGUID, 
		Text=@USERDATA(Text), 
		Language=@USERDATA(Language))',
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
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
  adapterName: 'DatabaseWriter' ) INPUT FROM EN_stream_Aliases;

CREATE OR REPLACE TARGET city_target_DE_aliases USING Global.DatabaseWriter( 
  Tables:'dbo.City, __TARGET_DB__.core.Translation columnmap(
		GUID=AliasesGUID, 
		Text=@USERDATA(Text), 
		Language=@USERDATA(Language))',
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
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
  adapterName: 'DatabaseWriter' ) INPUT FROM DE_stream_Aliases;

CREATE OR REPLACE TARGET city_target_FR_aliases USING Global.DatabaseWriter( 
  Tables:'dbo.City, __TARGET_DB__.core.Translation columnmap(
		GUID=AliasesGUID, 
		Text=@USERDATA(Text), 
		Language=@USERDATA(Language))',
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
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
  adapterName: 'DatabaseWriter' ) INPUT FROM FR_stream_Aliases;

CREATE OR REPLACE TARGET city_target_EN_CitySeo USING Global.DatabaseWriter( 
  Tables:'dbo.City, __TARGET_DB__.core.Translation columnmap(
		GUID=CitySeoGUID, 
		Text=@USERDATA(Text), 
		Language=@USERDATA(Language))',
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
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
  adapterName: 'DatabaseWriter' ) INPUT FROM EN_stream_CitySeo;

CREATE OR REPLACE TARGET city_target_DE_CitySeo USING Global.DatabaseWriter( 
  Tables:'dbo.City, __TARGET_DB__.core.Translation columnmap(
		GUID=CitySeoGUID, 
		Text=@USERDATA(Text), 
		Language=@USERDATA(Language))',
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
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
  adapterName: 'DatabaseWriter' ) INPUT FROM DE_stream_CitySeo;

CREATE OR REPLACE TARGET city_target_FR_CitySeo USING Global.DatabaseWriter( 
  Tables:'dbo.City, __TARGET_DB__.core.Translation columnmap(
		GUID=CitySeoGUID, 
		Text=@USERDATA(Text), 
		Language=@USERDATA(Language))',
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
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
  adapterName: 'DatabaseWriter' ) INPUT FROM FR_stream_CitySeo;

END APPLICATION city_CDC;


