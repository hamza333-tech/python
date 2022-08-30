
--
-- Tables that have both change-history and language translation. Incomplete set includes so far:
-- core.Specialties
--
-- This application creates a cache of Type_UserList rows that map LoginID to LoginName 
-- and subs in LoginNames where LoginValues are used in the tables.
-- It also has language translations that are moved out to the Translation table.
-- 

USE Migration;

STOP APPLICATION a_o_fact_H_L_LOAD;
UNDEPLOY APPLICATION a_o_fact_H_L_LOAD;
DROP APPLICATION a_o_fact_H_L_LOAD CASCADE;
CREATE APPLICATION a_o_fact_H_L_LOAD;

CREATE OR REPLACE SOURCE SQL_DBSource_H_L USING Global.DatabaseReader ( 
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  DatabaseName: '__SOURCE_DB__', 
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: 'Specialties KeyColumns(Specialty_id)'
)
OUTPUT TO SQL_DBSource_H_L_OutputStream;

--
-- CQ = Continuous Query
--
-- Create the CQ Operation, Join the source (dbo.Specialties) table with the cache UserList table
-- on the 22nd field of the source (ChangedBy) to the LoginId field of the cached data.
-- And substitute the LoginName field of from the cache row into the LoginName field of the 
-- target row.  NOTE COLUMN COUNT IS FROM 0, NOT 1.
--
-- Do it on this way for WAEvent, it's better
--
-- POSSIBLE PROBLEM HAVE I used putuserdata() and @userdatacorrectly?
--
CREATE OR REPLACE CQ CQ_JOIN_USERS_Specialties 
INSERT INTO LoginCache 
SELECT putuserdata (s,'LoginName',U.login_name)
FROM SQL_DBSource_H_L_OutputStream s
join UserList U
where to_int(s.data[22]) = U.id;

-- Need to add ChangeDescription to the SourceTable.
--
--Save Data to TARGET
--use COLUMNMAP to sve the Original Username to a Field Called ChangedBy
--
-- 
CREATE OR REPLACE TARGET SQL_Target USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Password: '__TARGET_PWD__', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__',   
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: 'Postgres',
  CDDLAction: 'Process', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Tables: '__SOURCE_DB__.dbo.Specialties,core.specialties columnmap(
	id=specialty_id,
	specialty_ref_id=specialty_ref_id,
	old_id=old_id,
	representation=representation,
	specialty_type_id=SpecialtyTypeId,
	internal_name=InternalName,
	exclude_from_auto_tagging=ExcludeFromAutoTagging,
	period_from=PeriodFrom,
	period_to=PeriodTo,
	desc_guid=DescGUID,
	sort_guid=SortGUID,
	aliases_guid=AliasesGUID,
	keywords_guid=KeywordsGUID)', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM LoginCache;

CREATE OR REPLACE TARGET a_o_fact_h_l_load_CreatedRecord USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Password: '__TARGET_PWD__', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: 'Postgres',
  CDDLAction: 'Process', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Tables: '__SOURCE_DB__.dbo.Specialties,core.history_created columnmap(
	reference_id=specialty_id,
	table_name=\'specialties\', 
	created_date=CreatedDate)', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM LoginCache;

CREATE OR REPLACE TARGET a_o_fact_h_l_load_ChangedRecord USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Password: '__TARGET_PWD__', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: 'Postgres',
  CDDLAction: 'Process', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Tables: '__SOURCE_DB__.dbo.Specialties,core.history_changed columnmap(
	reference_id=specialty_id,
	table_name=\'specialties\', 
	changed_date=ChangedDate,
	changed_by=@userdata(LoginName),
	change_comment=FormerValues)', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM LoginCache;

CREATE OR REPLACE TARGET a_o_ops_fact_H_L_LOAD_target_DE1 USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'
        __SOURCE_DB__.dbo.Specialties, __TARGET_DB__.core.Translation columnmap(
                guid=DescGUID,
                text=Desc_german,
                language=\'DE\');
      __SOURCE_DB__.dbo.Specialties, __TARGET_DB__.core.Translation columnmap(
                guid=SortGUID,
                text=Sort_german,
                language=\'DE\');
        __SOURCE_DB__.dbo.Specialties, __TARGET_DB__.core.Translation columnmap(
                guid=SortGUID,
                text=Keywords_german,
                language=\'DE\');
        __SOURCE_DB__.dbo.Specialties, __TARGET_DB__.core.Translation columnmap(
                guid=AliasesGUID,
                text=Keywords_german,
                language=\'DE\')',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: 'Postgres',
  CDDLAction: 'Process',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Password: '__TARGET_PWD__',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  adapterName: 'DatabaseWriter' )
INPUT FROM SQL_DBSource_H_L_OutputStream;

CREATE OR REPLACE TARGET a_o_ops_fact_H_L_LOAD_target_FR1 USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'
        __SOURCE_DB__.dbo.Specialties, __TARGET_DB__.core.Translation columnmap(
                guid=DescGUID,
                text=Desc_french,
                language=\'FR\');
        __SOURCE_DB__.dbo.Specialties, __TARGET_DB__.core.Translation columnmap(
                guid=SortGUID,
                text=Sort_french,
                language=\'FR\');
        __SOURCE_DB__.dbo.Specialties, __TARGET_DB__.core.Translation columnmap(
                guid=SortGUID,
                text=Keywords_french,
                language=\'FR\');
        __SOURCE_DB__.dbo.Specialties, __TARGET_DB__.core.Translation columnmap(
                guid=AliasesGUID,
                text=Keywords_french,
                language=\'FR\')
',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: 'Postgres',
  CDDLAction: 'Process',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Password: '__TARGET_PWD__',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  adapterName: 'DatabaseWriter' )
INPUT FROM SQL_DBSource_H_L_OutputStream;

CREATE OR REPLACE TARGET a_o_ops_fact_H_L_LOAD_target_EN1 USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=3',
  Tables:'
        __SOURCE_DB__.dbo.Specialties, __TARGET_DB__.core.Translation columnmap(
               guid=DescGUID,
               text=Desc_english,
               language=\'EN\');
       __SOURCE_DB__.dbo.Specialties, __TARGET_DB__.core.Translation columnmap(
               guid=SortGUID,
               text=Sort_english,
               language=\'EN\');
        __SOURCE_DB__.dbo.Specialties, __TARGET_DB__.core.Translation columnmap(
               guid=SortGUID,
               text=Keywords_english,
               language=\'EN\');
        __SOURCE_DB__.dbo.Specialties, __TARGET_DB__.core.Translation columnmap(
               guid=AliasesGUID,
               text=Keywords_english,
               language=\'EN\')
',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: 'Postgres',
  CDDLAction: 'Process',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Password: '__TARGET_PWD__',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  adapterName: 'DatabaseWriter' )
INPUT FROM SQL_DBSource_H_L_OutputStream;

END APPLICATION a_o_fact_H_L_LOAD;



