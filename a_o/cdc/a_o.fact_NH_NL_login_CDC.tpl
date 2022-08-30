
USE Migration;

STOP APPLICATION  artnet_ops_fact_NH_NL_CDC; 
UNDEPLOY APPLICATION artnet_ops_fact_NH_NL_CDC;
DROP APPLICATION artnet_ops_fact_NH_NL_CDC CASCADE;
CREATE APPLICATION artnet_ops_fact_NH_NL_CDC USE EXCEPTIONSTORE TTL : '7d' ;

CREATE FLOW artnet_ops_fact_NH_NL_CDC_SourceFlow ;

CREATE OR REPLACE SOURCE artnet_ops_fact_NH_NL_CDC_SOURCE USING Global.MSSqlReader ( 
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
  Tables: 'dbo.Logins', 
  SendBeforeImage: __SEND_BEFORE_IMAGE__, 
  AutoDisableTableCDC: __AUTO_DISABLE_TBL_CDC__ ) 
OUTPUT TO artnet_ops_fact_NH_NL_CDC_OutputStream;

CREATE OR REPLACE TARGET artnet_ops_fact_NH_NL_LOAD_CDC_target USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Tables: '
        dbo.Logins,__TARGET_DB__.business.Logins columnmap(
        LoginID=Login_id,
        LegacyLoginId=Login_id,
        CreatedDate=Created_Date,
        ChangedDate=Changed_date,
        LoginTypeId=Login_Type_id,
        GroupInd=Group_ind,
        LastLogin=Last_login,
        LoginName=Login_name,
        Password=Password,
        PasswordHint=Password_hint,
        Email=Email,
        FirstName=FirstName,
        MiddleInitial=MiddleInitial,
        LastName=LastName,
        CompanyName=CompanyName,
        LastPasswordChange=LastPasswordChange,
        ReasonToJoinID=ReasonToJoinID,
        MemberTypeId=Member_type_id,
        ActiveInd=Active_ind,
        CustomerNum=CustomerNum,
        IsBusinessPurpose=isBusinessPurpose,
        Url=Url,
        CompanyTypeID=Company_type_id,
        GalleryNum=GalleryNum,
        SalesmanID=Salesman_id,
        CoordinatorID=Coordinator_id,
        LastLoginToGP=LastLoginToGP,
        UserID=Userid
	)',
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  CDDLAction: 'Process', 
  Username: '__TARGET_UNAME__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:sqlserver://__TARGET_IP_PORT__;DatabaseName=__TARGET_DB__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  DatabaseProviderType: 'SQLServer', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  IgnorableExceptionCode: 'NO_OP_DELETE',
  adapterName: 'DatabaseWriter' ) 
INPUT FROM artnet_ops_fact_NH_NL_CDC_OutputStream;

END FLOW artnet_ops_fact_NH_NL_CDC_SourceFlow;

END APPLICATION artnet_ops_fact_NH_NL_CDC;

