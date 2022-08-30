
USE Migration;

STOP APPLICATION  a_o_dim_NH_NL_CDC; 
UNDEPLOY APPLICATION a_o_dim_NH_NL_CDC;
DROP APPLICATION a_o_dim_NH_NL_CDC CASCADE;
CREATE APPLICATION a_o_dim_NH_NL_CDC USE EXCEPTIONSTORE TTL : '7d' ;

CREATE FLOW a_o_dim_NH_NL_CDC_SourceFlow ;

CREATE OR REPLACE SOURCE a_o_dim_NH_NL_CDC_SOURCE USING Global.MSSqlReader ( 
  TransactionSupport: __TRNS_SUPPORT__, 
  FetchTransactionMetadata: __FETCH_TX_META__, 
  ConnectionRetryPolicy: 'timeOut=__CONN_RETRY_TO__, retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  Username: '__SOURCE_UNAME__', 
  FetchSize: __FETCH_SZ__, 
  adapterName: 'MSSqlReader', 
  Password: '__SOURCE_PWD__', 
  ConnectionPoolSize: __CONNECT_POOL_SZ__, 
  StartPosition: '__LSN__', 
  Compression: __COMPRN__, 
  DatabaseName: '__SOURCE_DB__', 
  cdcRoleName: 'STRIIM_READER', 
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__', 
  IntegratedSecurity: __INTEG_SEC__, 
  FilterTransactionBoundaries: __FLTR_TRANS_BNDRS__, 
  Tables: '
        dbo.salesman;
        dbo.marketing_source;
        dbo.login_type;
        dbo.currency;
        dbo.artwork_sorting;
        dbo.coordinators;
        dbo.gallery_type;
        dbo.status;
	dbo.customer_source;
	dbo.language;
	dbo.collection_Type;
	dbo.trading_status', 
  SendBeforeImage: __SEND_BEFORE_IMAGE__, 
  AutoDisableTableCDC: __AUTO_DISABLE_TBL_CDC__) 
OUTPUT TO a_o_dim_NH_NL_CDC_OutputStream;

CREATE OR REPLACE TARGET a_o_business_Salesman_CDC_target USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Tables: '
        __SOURCE_DB__.dbo.Salesman, __TARGET_DB__.business.salesman columnmap(
        id=Salesman_id,
        name=SalesmanFullName, 
        initials=SalesmanInitials, 
        commission=Commission, 
        login_id=Salesman_Login_Id,
        is_deleted=isDeleted);
        __SOURCE_DB__.dbo.Marketing_source, __TARGET_DB__.business.marketing_source columnmap(
        id=Marketing_Source_id, 
        name=Marketing_Source_Name);
        __SOURCE_DB__.dbo.Login_type, __TARGET_DB__.business.login_type columnmap(
        id=Login_type_id,
        name=Login_type_name);
        __SOURCE_DB__.dbo.Currency,__TARGET_DB__.core.currency columnmap(
        id=Currency_id,
        name=Currency_name,
        description=Description,
        is_active=Active_ind,
        symbol=Symbol);
        __SOURCE_DB__.dbo.ArtworkSorting,__TARGET_DB__.core.artwork_sorting columnmap(
        id=ArtworkSortingId,
        name=Name);
        __SOURCE_DB__.dbo.Coordinators,__TARGET_DB__.business.coordinators columnmap(
        id=coordinator_id,
        login_id=coordinator_login_id,
        name=Coordinator_name,
        initials=coordinator_initials,
        commission=Commission,
        picture=Picture,
        occupation=Occupation,
        phone=Phone,
        is_deleted=isDeleted);
        __SOURCE_DB__.dbo.gallery_type, __TARGET_DB__.core.gallery_type columnmap(
        id=gallery_type_id,
        name=gallery_type_name);
        __SOURCE_DB__.dbo.Status, __TARGET_DB__.core.status columnmap(
        id=status_id,
        name=status_name);
        __SOURCE_DB__.dbo.Customer_source, __TARGET_DB__.business.customer_source columnmap(
        id=Customer_source_id,
        name=Customer_source_name);
        __SOURCE_DB__.dbo.Language, __TARGET_DB__.core.language columnmap(
        id=Language_id,
        name=Language_name);
        __SOURCE_DB__.dbo.Collection_Type, __TARGET_DB__.core.collection_type columnmap(
        id=collection_type_id,
        name=collection_type_name);
        __SOURCE_DB__.dbo.Trading_Status, __TARGET_DB__.business.trading_status columnmap(
        id=Trading_status_id,
        name=Trading_status_name)',
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  CDDLAction: 'Process', 
  Username: '__TARGET_UNAME__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  DatabaseProviderType: 'SQLServer', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  IgnorableExceptionCode: 'NO_OP_DELETE',
  adapterName: 'DatabaseWriter' ) 
INPUT FROM a_o_dim_NH_NL_CDC_OutputStream;

END FLOW a_o_dim_NH_NL_CDC_SourceFlow;

END APPLICATION a_o_dim_NH_NL_CDC;

