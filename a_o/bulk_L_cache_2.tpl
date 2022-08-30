-- this bulk loader runs seond to set up the caches. 
--
--
-- bulk_L_cache_2
--- a_o.cache_login_local.tpl
--- a_o.cache_login_external.tpl		

USE Migration;

STOP APPLICATION bulk_L_cache_2_LOAD; 
UNDEPLOY APPLICATION bulk_L_cache_2_LOAD;
DROP APPLICATION bulk_L_cache_2_LOAD CASCADE;
CREATE APPLICATION bulk_L_cache_2_LOAD;

-- FILE_INPUT a_o.cache_login_external.tpl		

-- Create a TYPE to hold CACHED Data
-- This is identical with the datastructure for the internal cache but renamed
-- to avoid confusion.
--
CREATE TYPE Type_UserList_External (
 id int KEY,
 login_name java.lang.String
);

CREATE EXTERNAL CACHE UserListExternal (
  Username: '__TARGET_UNAME__', 
  Password: '__TARGET_PWD__',
  Password_encrypted: '__PWD_ENCRYPT__',
  FetchSize: __EXTERN_FETCH_SZ__, 
  SkipInvalid: __SKIP_INVALID__,
  connectionRetryPolicy: 'timeOut=__CONN_RETRY_TO__, retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: 'Default',
  KeyToMap: 'id',
  Table: '__TARGET_DB__.business.logins',
  AdapterName: 'DatabaseReader',
  Columns: 'id,login_name' 
)
OF Type_UserList_External;


-- FILE_INPUT a_o.cache_login_local.tpl


CREATE TYPE Type_UserList (
 id int KEY,
 login_name java.lang.String
);

--
-- CREATE the cache table UserList of Type_UserList objects from a SQL Statement and REFRESH every n hours
-- Note that it has a "keytomap" that is the ChangedBy field of the Type.
--
CREATE OR REPLACE CACHE UserList USING Global.DatabaseReader ( 
  DatabaseProviderType: 'Default', 
  FetchSize: __FETCH_SZ__, 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__',
  Query: 'SELECT id, login_name FROM business.logins', 
  Password: '__TARGET_PWD__', 
  Username: '__TARGET_UNAME__', 
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__, 
  Password_encrypted: '__PWD_ENCRYPT__' ) 
QUERY ( 
  Keytomap: 'id',
  Skipinvalid: '__SKIP_INVALID__',
  RefreshInterval: '__REFRESH_INTERVAL__' ) 
OF Type_UserList;


END APPLICATION bulk_L_cache_2_LOAD;
