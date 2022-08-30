
USE Migration;

STOP APPLICATION artnet_login_cache;
UNDEPLOY APPLICATION artnet_login_cache;;
DROP APPLICATION artnet_login_cache CASCADE;
CREATE APPLICATION artnet_login_cache;

-- Create a TYPE to hold CACHED Data
--
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

END APPLICATION artnet_login_cache;

