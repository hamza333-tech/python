
--
-- Application a_o_dim_L_nationality_LOAD 
-- Simple dimension tables with language translations but no history 
-- dbo.Nationality

USE Migration;

STOP APPLICATION a_o_dim_L_nationality_LOAD;
UNDEPLOY APPLICATION a_o_dim_L_nationality_LOAD;
DROP APPLICATION a_o_dim_L_nationality_LOAD CASCADE;
CREATE APPLICATION a_o_dim_L_nationality_LOAD;

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
  Tables:'
        __SOURCE_DB__.dbo.Nationality, __TARGET_DB__.core.nationality columnmap(
                id=Nationality_id,
                name_guid=NameGUID,
                aliases_guid=AliasesGUID)'
)
INPUT FROM output_a_o_dim_L_nationality_LOAD_x;


CREATE OR REPLACE TARGET a_o_dim_L_nationality_LOAD_DE1_x USING Global.DatabaseWriter(
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
  Tables:' __SOURCE_DB__.dbo.Nationality, __TARGET_DB__.core.translation columnmap(
                guid=NameGUID,
                text=Nationality_name_DE,
                language=\'DE\')'
)
INPUT FROM output_a_o_dim_L_nationality_LOAD_x;

CREATE OR REPLACE TARGET a_o_dim_L_nationality_LOAD_EN1_x USING Global.DatabaseWriter(
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
  Tables:'
	__SOURCE_DB__.dbo.Nationality, __TARGET_DB__.core.translation columnmap(
        guid=NameGUID,
        text=Nationality_name_US,
        language= \'EN\')'
)
INPUT FROM output_a_o_dim_L_nationality_LOAD_x;

CREATE OR REPLACE TARGET a_o_dim_L_nationality_LOAD_FR1_x USING Global.DatabaseWriter(
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
  Tables:' 
        __SOURCE_DB__.dbo.Nationality, __TARGET_DB__.core.translation columnmap(
        guid=NameGUID,
        text=Nationality_name_FR,
        language=\'FR\')'
)
INPUT FROM output_a_o_dim_L_nationality_LOAD_x;





CREATE OR REPLACE TARGET a_o_dim_L_nationality_LOAD_DE2_x USING Global.DatabaseWriter(
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
  Tables:' __SOURCE_DB__.dbo.Nationality, __TARGET_DB__.core.translation columnmap(
                guid=AliasesGUID,
                text=Nationality_aliases_DE,
                language=\'DE\')'
)
INPUT FROM output_a_o_dim_L_nationality_LOAD_x;

CREATE OR REPLACE TARGET a_o_dim_L_nationality_LOAD_EN2_x USING Global.DatabaseWriter(
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
  Tables:'
        __SOURCE_DB__.dbo.Nationality, __TARGET_DB__.core.translation columnmap(
        guid=AliasesGUID,
        text=Nationality_aliases_US,
        language= \'EN\')'
)
INPUT FROM output_a_o_dim_L_nationality_LOAD_x;

CREATE OR REPLACE TARGET a_o_dim_L_nationality_LOAD_FR2_x USING Global.DatabaseWriter(
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
  Tables:'
        __SOURCE_DB__.dbo.Nationality, __TARGET_DB__.core.translation columnmap(
        guid=AliasesGUID,
        text=Nationality_aliases_FR,
        language=\'FR\')'
)
INPUT FROM output_a_o_dim_L_nationality_LOAD_x;






END APPLICATION a_o_dim_L_nationality_LOAD;
