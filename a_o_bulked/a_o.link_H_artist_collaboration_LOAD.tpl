
--

USE Migration;

STOP APPLICATION a_o_H_collab_LOAD;
UNDEPLOY APPLICATION a_o_H_collab_LOAD;
DROP APPLICATION a_o_H_collab_LOAD CASCADE;
CREATE APPLICATION a_o_H_collab_LOAD;

CREATE OR REPLACE SOURCE SQL_DBSource_H_collab_LOAD USING Global.DatabaseReader ( 
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  DatabaseName: '__SOURCE_DB__', 
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: 'ArtistCollaboration KeyColumns(RowID)'
)
OUTPUT TO SQL_DBSource_H_collab_LOAD_OutputStream;

CREATE OR REPLACE CQ CQ_ArtistCollaborationCreatedByLoad 
INSERT INTO LoginCacheArtistCollaborationCreatedBy 
SELECT putuserdata (s,'LoginName',U.login_name)
FROM SQL_DBSource_H_collab_LOAD_OutputStream s
join UserList U
where to_int(s.data[4]) = U.id;

CREATE OR REPLACE CQ CQ_ArtistCollaborationChangedByLoad 
INSERT INTO LoginCacheArtistCollaborationChangedBy 
SELECT putuserdata (s,'LoginName',U.login_name)
FROM SQL_DBSource_H_collab_LOAD_OutputStream s
join UserList U
where to_int(s.data[6]) = U.id;

CREATE OR REPLACE TARGET Target_H_collab_ArtistCollaboration_LOAD USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Password: '__TARGET_PWD__', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__',
  CDDLAction: 'Process', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Tables: '
	__SOURCE_DB__.dbo.ArtistCollaboration,__TARGET_DB__.core.artist_collaboration columnmap(
	 id=RowID
	,artist_id_collaboration=ArtistIdCollaboration
	,artist_id_solo=ArtistIdSolo
	,sort_order=SortOrder
  )', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM  SQL_DBSource_H_collab_LOAD_OutputStream;

CREATE OR REPLACE TARGET Target_H_collab_ArtistCollaboration_LOAD_Created USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: '__SOURCE_DB__.dbo.ArtistCollaboration,__TARGET_DB__.core.history_created columnmap(
        reference_id=RowId,
        table_name=\'artist_collaboration\',
        created_by=@userdata(LoginName),
        created_date=CreatedDate)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCacheArtistCollaborationCreatedBy;

CREATE OR REPLACE TARGET Target_H_collab_ArtistCollaboration_LOAD_Changed USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: '__SOURCE_DB__.dbo.ArtistCollaboration,__TARGET_DB__.core.history_changed columnmap(
        reference_id=RowId,
        table_name=\'artist_collaboration\',
        changed_date=ChangedDate,
        changed_by=@userdata(LoginName),
        change_comment=FormerValues)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCacheArtistCollaborationChangedBy;


END APPLICATION a_o_H_collab_LOAD;

