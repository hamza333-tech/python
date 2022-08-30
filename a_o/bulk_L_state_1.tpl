
STOP APPLICATION bulk_L_state_1_LOAD ;
UNDEPLOY APPLICATION  bulk_L_state_1_LOAD;
DROP APPLICATION  bulk_L_state_1_LOAD CASCADE;
CREATE APPLICATION  bulk_L_state_1_LOAD;

CREATE OR REPLACE SOURCE a_o_dim_L_state_LOAD_source USING Global.DatabaseReader(
  Password: '__SOURCE_PWD__', 
  DatabaseProviderType: 'Default', 
  FetchSize: __FETCH_SZ__, 
  adapterName: 'DatabaseReader', 
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__, 
  Password_encrypted: '__PWD_ENCRYPT__', 
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__', 
  Username: '__SOURCE_UNAME__', 
  Tables: '__SOURCE_DB__.dbo.State'
  ) 
OUTPUT TO output_a_o_dim_L_state_LOAD;

CREATE OR REPLACE TARGET a_o_dim_L_state_LOAD_SS USING Global.DatabaseWriter(
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
  Tables:'__SOURCE_DB__.dbo.State,__TARGET_DB__.core.state columnmap(
		id=State_id,
		name_guid=NameGUID,
		aliases_guid=AliasesGUID,
		state_seo_guid=stateSEOGUID,
		country_id=Country_id,
		abbr=Abbr)' 
)
INPUT FROM output_a_o_dim_L_state_LOAD;


CREATE OR REPLACE TARGET a_o_dim_L_state_name_de USING Global.DatabaseWriter(
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
  Tables:'__SOURCE_DB__.dbo.State, __TARGET_DB__.core.translation columnmap(
	guid=NameGUID, 
	text=State_name_DE, 
	language=\'DE\')'
)
INPUT FROM output_a_o_dim_L_state_LOAD;

CREATE OR REPLACE TARGET a_o_dim_L_state_name_en USING Global.DatabaseWriter(
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
  Tables:'__SOURCE_DB__.dbo.State, __TARGET_DB__.core.translation columnmap(
	guid=NameGUID, 
	text=State_name_US, 
	language=\'EN\')'
)
INPUT FROM output_a_o_dim_L_state_LOAD;

CREATE OR REPLACE TARGET a_o_dim_L_state_name_fr USING Global.DatabaseWriter(
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
  Tables:'__SOURCE_DB__.dbo.State, __TARGET_DB__.core.translation columnmap(
	guid=NameGUID, 
	text=State_name_FR, 
	language=\'FR\')'
)
INPUT FROM output_a_o_dim_L_state_LOAD;


CREATE OR REPLACE TARGET a_o_dim_L_state_aliases_de USING Global.DatabaseWriter(
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
  Tables:'__SOURCE_DB__.dbo.State, __TARGET_DB__.core.translation columnmap(
	guid=AliasesGUID, 
	text=StateAliasDe, 
	language=\'DE\')'
) 
INPUT FROM output_a_o_dim_L_state_LOAD;

CREATE OR REPLACE TARGET a_o_dim_L_state_aliases_fr USING Global.DatabaseWriter(
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
  Tables:'__SOURCE_DB__.dbo.State, __TARGET_DB__.core.translation columnmap(
	guid=AliasesGUID, 
	text=StateAliasFr, 
	language=\'FR\')'
) 
INPUT FROM output_a_o_dim_L_state_LOAD;

CREATE OR REPLACE TARGET a_o_dim_L_state_aliases_en USING Global.DatabaseWriter(
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
  Tables:'__SOURCE_DB__.dbo.State, __TARGET_DB__.core.translation columnmap(
	guid=AliasesGUID, 
	text=StateAliasEn, 
	language=\'EN\')'
) 
INPUT FROM output_a_o_dim_L_state_LOAD;




CREATE OR REPLACE TARGET a_o_dim_L_state_seo_en USING Global.DatabaseWriter(
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
  Tables:'__SOURCE_DB__.dbo.State, __TARGET_DB__.core.translation columnmap(
	guid=StateSEOGUID, 
	text=StateSeoEn, 
	language=\'EN\')'
 ) 
INPUT FROM output_a_o_dim_L_state_LOAD;

CREATE OR REPLACE TARGET a_o_dim_L_state_seo_de USING Global.DatabaseWriter(
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
  Tables:'__SOURCE_DB__.dbo.State, __TARGET_DB__.core.translation columnmap(
	guid=StateSEOGUID, 
	text=StateSeoDe, 
	language=\'DE\')'
 ) 
INPUT FROM output_a_o_dim_L_state_LOAD;

CREATE OR REPLACE TARGET a_o_dim_L_state_seo_fr USING Global.DatabaseWriter(
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
  Tables:'__SOURCE_DB__.dbo.State, __TARGET_DB__.core.translation columnmap(
	guid=StateSEOGUID, 
	text=StateSeoFr, 
	language=\'FR\')'
 ) 
INPUT FROM output_a_o_dim_L_state_LOAD;

END APPLICATION  bulk_L_state_1_LOAD;
