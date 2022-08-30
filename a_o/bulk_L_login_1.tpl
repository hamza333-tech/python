-- this bulk loader runs first because many things need the logins table
-- a_o.fact_NH_NL_LOAD;
-- a_o.dim_NH_NL_LOAD;
-- a_o.dim_L_nationality_LOAD.tpl			
-- a_o.dim_L_city_LOAD.tpl				
--
--
-- logins
-- salesman;
-- marketing_source;
-- login_type;
-- currency;
-- artwork_sorting;
-- coordinators;
-- gallery_type;
-- status;
-- customer_source;
-- language;
-- collection_type;
-- trading_status'
-- nationality'
-- city
-- country


-- bulk_L_login_1
--
-- Logins plain tables with Language support
-- Run this first to set up for history..
-- 

USE Migration;

STOP APPLICATION bulk_L_login_1_LOAD ;
UNDEPLOY APPLICATION  bulk_L_login_1_LOAD;
DROP APPLICATION  bulk_L_login_1_LOAD CASCADE;
CREATE APPLICATION  bulk_L_login_1_LOAD;

-- FILE_INPUT a_o.fact_NH_NL_LOAD;

CREATE OR REPLACE SOURCE a_o_fact_NH_NL_LOAD_source USING Global.DatabaseReader ( 
  Password: '__SOURCE_PWD__', 
  DatabaseProviderType: 'Default', 
  FetchSize: __FETCH_SZ__, 
  adapterName: 'DatabaseReader', 
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__, 
  Password_encrypted: '__PWD_ENCRYPT__', 
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__', 
  Username: '__SOURCE_UNAME__', 
  Tables: ' __SOURCE_DB__.dbo.Logins') 
OUTPUT TO a_o_fact_NH_NL_LOAD;


-- note, Login_id is OK in business schema tables.
--
CREATE OR REPLACE TARGET a_o_fact_NH_NL_LOAD_target USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Tables: '__SOURCE_DB__.dbo.Logins, __TARGET_DB__.business.logins columnmap(
	id=Login_id,
	legacy_login_id=Login_id, 
	login_type_id=Login_Type_id, 
	group_ind=Group_ind, 
	last_login=Last_login, 
	login_name=Login_name, 
	password=Password, 
	password_hint=Password_hint,
	email=Email,
	first_name=FirstName,
	middle_initial=MiddleInitial, 
	last_name=LastName,
	company_name=CompanyName, 
	last_password_change=LastPasswordChange,
	reason_to_join_id=ReasonToJoinID,
	member_type_id=Member_type_id, 
	active_ind=Active_ind, 
	customer_num=CustomerNum, 
	is_business_purpose=isBusinessPurpose,
	url=Url,
	company_type_id=Company_type_id, 
	gallery_num=GalleryNum, 
	salesman_id=Salesman_id, 
	coordinator_id=Coordinator_id, 
	last_login_to_gp=LastLoginToGP, 
	user_id=Userid)',
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM a_o_fact_NH_NL_LOAD;


-- FILE_INPUT a_o.dim_NH_NL_LOAD;

-- 
-- Application a_o_dim_NH_NL_LOAD 
-- Simple dimension tables with no history and no login_id FK
-- 
-- business.salesman
-- business.marketing_source
-- business.login_type
-- core.currency
-- core.artwork_sorting
-- business.coordinators
-- core.gallery_type
-- core.status
-- business.customer_source
-- core.language
-- business.collection_type
-- business.trading_status
--



CREATE OR REPLACE SOURCE a_o_dim_NH_NL_LOAD_source USING Global.DatabaseReader ( 
  Password: '__SOURCE_PWD__', 
  DatabaseProviderType: 'Default', 
  FetchSize: __FETCH_SZ__, 
  adapterName: 'DatabaseReader', 
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__, 
  Password_encrypted: '__PWD_ENCRYPT__', 
  ConnectionURL: 'jdbc:__SOURCE_DB_VEND__://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__', 
  Username: '__SOURCE_UNAME__', 
  Tables: '__SOURCE_DB__.dbo.Salesman;
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
  Tables: '__SOURCE_DB__.dbo.Salesman, __TARGET_DB__.business.salesman columnmap(
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


-- FILE_INPUT a_o.dim_L_nationality_LOAD.tpl			

CREATE OR REPLACE SOURCE a_o_dim_L_nationality_LOAD_source USING Global.DatabaseReader(
  Password: '__SOURCE_PWD__', 
  DatabaseProviderType: 'Default', 
  FetchSize: __FETCH_SZ__, 
  adapterName: 'DatabaseReader', 
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__, 
  Password_encrypted: '__PWD_ENCRYPT__', 
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__', 
  Username: '__SOURCE_UNAME__', 
  Tables: ' __SOURCE_DB__.dbo.Nationality'
) 
OUTPUT TO output_a_o_dim_L_nationality_LOAD_x;

CREATE OR REPLACE TARGET a_o_dim_L_nationality_LOAD_SS USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter',  
  Tables:'__SOURCE_DB__.dbo.Nationality, __TARGET_DB__.core.nationality columnmap(
                id=Nationality_id,
                name_guid=NameGUID,
                aliases_guid=AliasesGUID)'
)
INPUT FROM output_a_o_dim_L_nationality_LOAD_x;


CREATE OR REPLACE TARGET a_o_dim_L_nationality_nationality_trn_de_name USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter', 
  Tables:'__SOURCE_DB__.dbo.Nationality, __TARGET_DB__.core.translation columnmap(
                guid=NameGUID,
                text=Nationality_name_DE,
                language=\'DE\')'
)
INPUT FROM output_a_o_dim_L_nationality_LOAD_x;

CREATE OR REPLACE TARGET a_o_dim_L_nationality_nationality_trn_de_aliases USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter', 
  Tables:'__SOURCE_DB__.dbo.Nationality, __TARGET_DB__.core.translation columnmap(
                guid=AliasesGUID,
                text=Nationality_aliases_DE,
                language=\'DE\')'
)
INPUT FROM output_a_o_dim_L_nationality_LOAD_x;

CREATE OR REPLACE TARGET a_o_dim_L_nationality_trn_en_name USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter', 
  Tables:'__SOURCE_DB__.dbo.Nationality, __TARGET_DB__.core.translation columnmap(
           guid=NameGUID,
           text=Nationality_name_US,
           language= \'EN\')'
)
INPUT FROM output_a_o_dim_L_nationality_LOAD_x;

CREATE OR REPLACE TARGET a_o_dim_L_nationality_trn_en_aliases USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter', 
  Tables:'__SOURCE_DB__.dbo.Nationality, __TARGET_DB__.core.translation columnmap(
           guid=AliasesGUID,
           text=Nationality_aliases_US,
           language= \'EN\')'
)
INPUT FROM output_a_o_dim_L_nationality_LOAD_x;

CREATE OR REPLACE TARGET a_o_dim_L_nationality_trn_fr_name USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter', 
  Tables:'__SOURCE_DB__.dbo.Nationality, __TARGET_DB__.core.translation columnmap(
        guid=NameGUID,
        text=Nationality_name_FR,
        language= \'FR\')'
)
INPUT FROM output_a_o_dim_L_nationality_LOAD_x;

CREATE OR REPLACE TARGET a_o_dim_L_nationality_trn_fr_aliases USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter', 
  Tables:'__SOURCE_DB__.dbo.Nationality, __TARGET_DB__.core.translation columnmap(
        guid=AliasesGUID,
        text=Nationality_aliases_FR,
        language= \'FR\')'
)
INPUT FROM output_a_o_dim_L_nationality_LOAD_x;


-- FILE_INPUT a_o.dim_L_city_LOAD.tpl				

CREATE OR REPLACE SOURCE a_o_dim_L_LOAD_source USING Global.DatabaseReader(
  Password: '__SOURCE_PWD__', 
  DatabaseProviderType: 'Default', 
  FetchSize: __FETCH_SZ__, 
  adapterName: 'DatabaseReader', 
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__, 
  Password_encrypted: '__PWD_ENCRYPT__', 
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__', 
  Username: '__SOURCE_UNAME__', 
  Tables: '__SOURCE_DB__.dbo.City'
  ) 
OUTPUT TO output_a_o_dim_L_LOAD;

CREATE OR REPLACE TARGET a_o_dim_L_LOAD_SS USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter',  
  Tables:'__SOURCE_DB__.dbo.City, __TARGET_DB__.core.city columnmap(
		id=City_id,
		country_id=Country_id,
		state_id=State_id,
		name_guid=NameGUID,
		aliases_guid=AliasesGUID,
		city_seo_guid=CitySeoGUID)'
)
INPUT FROM output_a_o_dim_L_LOAD;

CREATE OR REPLACE TARGET a_o_dim_L_LOAD_city_name_de USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter', 
  Tables:'__SOURCE_DB__.dbo.City, __TARGET_DB__.core.translation columnmap(
	guid=NameGuid, 
	text=City_name_DE, 
	language=\'DE\')'
)
INPUT FROM output_a_o_dim_L_LOAD;


CREATE OR REPLACE TARGET a_o_dim_L_LOAD_city_name_us USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter', 
  Tables:'__SOURCE_DB__.dbo.City, __TARGET_DB__.core.translation columnmap(
        guid=NameGUID,
        text=City_name_US,
        language= \'EN\')'
)
INPUT FROM output_a_o_dim_L_LOAD;


CREATE OR REPLACE TARGET a_o_dim_L_LOAD_city_name_fr USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter', 
  Tables:'__SOURCE_DB__.dbo.City, __TARGET_DB__.core.translation columnmap(
        guid=NameGUID,
        text=City_name_FR,
        language=\'FR\')'
)
INPUT FROM output_a_o_dim_L_LOAD;


CREATE OR REPLACE TARGET a_o_dim_L_LOAD_city_aliases_de USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter', 
  Tables:'__SOURCE_DB__.dbo.City, __TARGET_DB__.core.translation columnmap(
	guid=AliasesGUID, 
	text=City_aliases_DE, 
	language=\'DE\')'
) 
INPUT FROM output_a_o_dim_L_LOAD;

CREATE OR REPLACE TARGET a_o_dim_L_LOAD_city_aliases_fr USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter', 
  Tables:'__SOURCE_DB__.dbo.City, __TARGET_DB__.core.translation columnmap(
        guid=AliasesGUID,
        text=City_aliases_FR,
        language=\'FR\')'
) 
INPUT FROM output_a_o_dim_L_LOAD;

CREATE OR REPLACE TARGET a_o_dim_L_LOAD_city_aliases_en USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter', 
  Tables:'__SOURCE_DB__.dbo.City, __TARGET_DB__.core.translation columnmap(
        guid=AliasesGUID,
        text=City_aliases_US,
        language=\'EN\')'
) 
INPUT FROM output_a_o_dim_L_LOAD;


CREATE OR REPLACE TARGET a_o_dim_L_LOAD_city_seo_en USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter',
  Tables:'__SOURCE_DB__.dbo.City, __TARGET_DB__.core.translation columnmap(
	guid=CitySeoGUID, 
	text=CitySeoEn, 
	language=\'EN\')'
 ) 
INPUT FROM output_a_o_dim_L_LOAD;

CREATE OR REPLACE TARGET a_o_dim_L_LOAD_city_seo_fr USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter',
  Tables:'__SOURCE_DB__.dbo.City, __TARGET_DB__.core.translation columnmap(
	guid=CitySeoGUID, 
	text=CitySeoFr, 
	language=\'FR\')'
 ) 
INPUT FROM output_a_o_dim_L_LOAD;


CREATE OR REPLACE TARGET a_o_dim_L_LOAD_city_seo_de USING Global.DatabaseWriter(
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter',
  Tables:'__SOURCE_DB__.dbo.City, __TARGET_DB__.core.translation columnmap(
	guid=CitySeoGUID, 
	text=CitySeoDe, 
	language=\'DE\')'
 ) 
INPUT FROM output_a_o_dim_L_LOAD;



END APPLICATION  bulk_L_login_1_LOAD;
