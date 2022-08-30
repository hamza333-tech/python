
--
--
--
-- Application a_o_dim_NH_NL_images_LOAD
--
-- business.images
--

USE Migration;

STOP APPLICATION a_o_dim_NH_NL_images_LOAD;
UNDEPLOY APPLICATION a_o_dim_NH_images_NL_LOAD;
DROP APPLICATION a_o_dim_NH_NL_images_LOAD CASCADE;
CREATE APPLICATION a_o_dim_NH_NL_images_LOAD;


CREATE OR REPLACE SOURCE a_o_dim_NH_NL__imagesLOAD_source USING Global.DatabaseReader (
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:__SOURCE_DB_VEND__://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: '
        __SOURCE_DB__.dbo.Images'
)
OUTPUT TO a_o_dim_NH_NL_images_LOAD;


--
CREATE OR REPLACE TARGET a_o_dim_core_salesman_LOAD_target USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables: '
        __SOURCE_DB__.dbo.Images, __TARGET_DB__.core.images columnmap(
        id=Image_id,
        artwork_id=Artwork_id,
        sort_order=Sortorder)',
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
INPUT FROM a_o_dim_NH_NL_images_LOAD;

END APPLICATION a_o_dim_NH_NL_images_LOAD;
-- 
