
--
-- 
-- Application a_o_fact_NH_NL_LOAD 
-- Simple fact tables with no LoginID/LoginName swap and no Translation
-- 
-- dbo.Logins
--
--

USE Migration;

STOP APPLICATION a_o_fact_NH_NL_LOAD;
UNDEPLOY APPLICATION a_o_fact_NH_NL_LOAD;
DROP APPLICATION a_o_fact_NH_NL_LOAD CASCADE;
CREATE APPLICATION a_o_fact_NH_NL_LOAD;


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
  Tables: '
	__SOURCE_DB__.dbo.Logins, __TARGET_DB__.business.logins columnmap(
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

END APPLICATION a_o_fact_NH_NL_LOAD;







