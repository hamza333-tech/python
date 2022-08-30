
--
-- 
-- Application nationality excerpted artnet_ops.dim_L_CDC.tpl
-- dbo.Nationality

USE Migration;

STOP APPLICATION nationality_CDC;
UNDEPLOY APPLICATION nationality_CDC;
DROP APPLICATION nationality_CDC CASCADE;
CREATE APPLICATION nationality_CDC;

--
-- Standard Reader. Nothing special.
-- Why DatabaseReader v MSSqlReader?
-- 
CREATE OR REPLACE SOURCE nationality_CDC_source USING Global.MSSqlReader ( 
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
  Tables: 'dbo.Nationality',
  cdcRoleName: 'STRIIM_READER',
  Username: '__SOURCE_UNAME__', 
  IntegratedSecurity: __INTEG_SEC__,
  FilterTransactionBoundaries: __FLTR_TRANS_BNDRS__,
  ConnectionPoolSize: __CONNECT_POOL_SZ__,
  SendBeforeImage: __SEND_BEFORE_IMAGE__,
  AutoDisableTableCDC: __AUTO_DISABLE_TBL_CDC__
) 
OUTPUT TO output_nationality_CDC;


CREATE OR REPLACE CQ EN_CQ_Name
INSERT INTO EN_stream_Name
SELECT
putUserData(t,'Language','EN','Aux','0','Text',data[1] )
FROM output_nationality_CDC t;

CREATE OR REPLACE CQ EN_CQ_Aliases
INSERT INTO EN_stream_Aliases
SELECT
putUserData(t,'Language','EN','Aux','0','Text',data[2] )
FROM output_nationality_CDC t;

CREATE OR REPLACE CQ DE_CQ_Name 
INSERT INTO DE_stream_Name
SELECT
putUserData(t,'Language','DE','Aux','0','Text',data[3] )
FROM output_nationality_CDC t;

CREATE OR REPLACE CQ DE_CQ_Aliases
INSERT INTO DE_stream_Aliases 
SELECT
putUserData(t,'Language','DE','Aux','0','Text',data[4] )
FROM output_nationality_CDC t;

CREATE OR REPLACE CQ FR_CQ_Name 
INSERT INTO FR_stream_Name 
SELECT
putUserData(t,'Language','FR','Aux','0','Text',data[5] )
FROM output_nationality_CDC t;

CREATE OR REPLACE CQ FR_CQ_Aliases 
INSERT INTO FR_stream_Aliases 
SELECT
putUserData(t,'Language','FR','Aux','0','Text',data[6] )
FROM output_nationality_CDC t;

-- The core.Nationality Table
--
CREATE OR REPLACE TARGET nationality_CDC_targetSS_SS USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'
	dbo.Nationality, __TARGET_DB__.core.Nationality columnmap(
		NationalityID=Nationality_id, 
		NameGUID=NameGUID, 
		AliasesGUID=AliasesGUID
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
INPUT FROM output_nationality_CDC;


-- core.Translation table English Name Values  
--
CREATE OR REPLACE TARGET nationality_target_EN_name USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Nationality, __TARGET_DB__.core.Translation columnmap(
		GUID=NameGUID, 
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
INPUT FROM EN_stream_Name;

-- core.Translation table English Aliases Values  
--
CREATE OR REPLACE TARGET nationality_target_EN_aliases USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Nationality, __TARGET_DB__.core.Translation columnmap(
		GUID=AliasesGUID, 
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
INPUT FROM EN_stream_Aliases;

-- core.Translation table German Name Values  
--
CREATE OR REPLACE TARGET nationality_target_DE_Name USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Nationality, __TARGET_DB__.core.Translation columnmap(
		GUID=NameGUID, 
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
INPUT FROM DE_stream_Name;

-- core.Translation table German Aliases Values  
--
CREATE OR REPLACE TARGET nationality_target_DE_aliases USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Nationality, __TARGET_DB__.core.Translation columnmap(
		GUID=AliasesGUID, 
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
INPUT FROM DE_stream_Aliases;

-- core.Translation table French Name Values  
--
CREATE OR REPLACE TARGET nationality_target_FR_NAME USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Nationality, __TARGET_DB__.core.Translation columnmap(
		GUID=NameGUID, 
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
INPUT FROM FR_stream_Name;

-- core.Translation table French Aliases Value  
--
CREATE OR REPLACE TARGET nationality_target_FR_aliases USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Nationality, __TARGET_DB__.core.Translation columnmap(
		GUID=AliasesGUID, 
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
INPUT FROM FR_stream_Aliases;


END APPLICATION nationality_CDC;


