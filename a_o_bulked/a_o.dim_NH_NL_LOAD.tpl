
--
-- 
-- Application a_o_dim_NH_NL_LOAD 
-- Simple dimension tables with no history and no login_id FK
-- 
-- core.artwork_sorting
-- business.coordinators
-- core.currency
-- core.gallery_type
-- business.login_type
-- business.marketing_source
-- business.salesman
-- core.status
-- business.customer_source
-- business.trading_Status
-- business.collection_type
-- core.language
--

USE Migration;

STOP APPLICATION a_o_dim_NH_NL_LOAD;
UNDEPLOY APPLICATION a_o_dim_NH_NL_LOAD;
DROP APPLICATION a_o_dim_NH_NL_LOAD CASCADE;
CREATE APPLICATION a_o_dim_NH_NL_LOAD;


CREATE OR REPLACE SOURCE a_o_dim_NH_NL_LOAD_source USING Global.DatabaseReader ( 
  Password: '__SOURCE_PWD__', 
  DatabaseProviderType: 'Default', 
  FetchSize: __FETCH_SZ__, 
  adapterName: 'DatabaseReader', 
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__, 
  Password_encrypted: '__PWD_ENCRYPT__', 
  ConnectionURL: 'jdbc:__SOURCE_DB_VEND__://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__', 
  Username: '__SOURCE_UNAME__', 
  Tables: '
	__SOURCE_DB__.dbo.salesman;
	__SOURCE_DB__.dbo.marketing_source;
	__SOURCE_DB__.dbo.login_type;
	__SOURCE_DB__.dbo.currency;
	__SOURCE_DB__.dbo.ArtworkSorting;
	__SOURCE_DB__.dbo.coordinators;
	__SOURCE_DB__.dbo.gallery_type;
	__SOURCE_DB__.dbo.status;
	__SOURCE_DB__.dbo.customer_source;
	__SOURCE_DB__.dbo.language;
	__SOURCE_DB__.dbo.collection_type;
	__SOURCE_DB__.dbo.trading_status'
 ) 
OUTPUT TO a_o_dim_NH_NL_LOAD;


--
CREATE OR REPLACE TARGET a_o_business_Salesman_LOAD_target USING Global.DatabaseWriter ( 
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
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified', 
  DatabaseProviderType: 'SQLServer', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM a_o_dim_NH_NL_LOAD;

END APPLICATION a_o_dim_NH_NL_LOAD;







