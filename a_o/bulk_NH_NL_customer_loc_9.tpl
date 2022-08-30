
--
--
--
-- Application a_o_dim_NH_NL_customer_loc_LOAD
--
-- business.images
--

USE Migration;

STOP APPLICATION a_o_dim_NH_NL_customer_loc_LOAD;
UNDEPLOY APPLICATION a_o_dim_NH_customer_loc_NL_LOAD;
DROP APPLICATION a_o_dim_NH_NL_customer_loc_LOAD CASCADE;
CREATE APPLICATION a_o_dim_NH_NL_customer_loc_LOAD;


CREATE OR REPLACE SOURCE a_o_dim_NH_NL__customer_loc_LOAD_source USING Global.DatabaseReader (
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:__SOURCE_DB_VEND__://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: '__SOURCE_DB__.dbo.Customer_Type;
           __SOURCE_DB__.dbo.Customer_Location'
)
OUTPUT TO a_o_dim_NH_NL_customer_loc_LOAD;


--
CREATE OR REPLACE TARGET a_o_dim_core_LOAD_customer_loc_target USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables: '
        __SOURCE_DB__.dbo.Customer_Location, __TARGET_DB__.core.customer_location columnmap(
        id=Customer_location_id,
        customer_id=Customer_id,
        customer_type_id=Customer_Type_id,
        sort_order=Sortorder,
        director=Director,
        company=Company,
        contact_first=Contact_First,
        contact_last=Contact_Last,
        phone_1=Phone1,
        phone_2=Phone2,
        mobile=Mobile,
        fax=Fax,
        email=Email,
        url=Url,
        url_2=Url2,
        address_1=Address1,
        address_2=Address2,
        city_id=City_id,
        state_id=State_id,
        country_id=Country_id,
        postal_code=Postalcode,
        hours=Hours,
        euro_address=Euro_Address,
        display_city_id=Display_City_id,
        prop_url=Propurl,
        location_name=LocationName,
        geo_coordinates=GeoCoordinates)',
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
INPUT FROM a_o_dim_NH_NL_customer_loc_LOAD;

CREATE OR REPLACE TARGET a_o_dim_core_LOAD_customer_type_target USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables: '
        __SOURCE_DB__.dbo.Customer_Type, __TARGET_DB__.core.customer_type columnmap(
        id=Customer_TYpe_id,
        customer_type_name=Customer_Type_Name)',
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
INPUT FROM a_o_dim_NH_NL_customer_loc_LOAD;



END APPLICATION a_o_dim_NH_NL_customer_loc_LOAD;
-- 
