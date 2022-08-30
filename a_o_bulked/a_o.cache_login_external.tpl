
USE Migration;

STOP APPLICATION artnet_login_cache_external;
UNDEPLOY APPLICATION artnet_login_cache_external;;
DROP APPLICATION artnet_login_cache_external CASCADE;
CREATE APPLICATION artnet_login_cache_external;

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


END APPLICATION artnet_login_cache_external;

