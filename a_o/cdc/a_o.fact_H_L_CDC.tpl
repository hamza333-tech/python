
-- 
-- Application a_o_fact_h_l_specialties excerpted a_o.dim_L_CDC.tpl
--
-- dbo.Specialties
--

USE Migration;

STOP APPLICATION a_o_fact_h_l_specialties_CDC;
UNDEPLOY APPLICATION a_o_fact_h_l_specialties_CDC;
DROP APPLICATION a_o_fact_h_l_specialties_CDC CASCADE;
CREATE APPLICATION a_o_fact_h_l_specialties_CDC;

--
-- Standard Reader. Nothing special.
-- Why DatabaseReader v MSSqlReader?
-- 
CREATE OR REPLACE SOURCE a_o_fact_h_l_specialties_CDC_source USING Global.MSSqlReader ( 
  TransactionSupport: __TRNS_SUPPORT__,
  Compression: __COMPRN__,
  FetchTransactionMetadata: __FETCH_TX_META__,
  ConnectionRetryPolicy: 'timeOut=__CONN_RETRY_TO__, retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password_encrypted: '__PWD_ENCRYPT__', 
  Password: '__SOURCE_PWD__', 
  DatabaseProviderType: 'Default', 
  DatabaseName:__SOURCE_DB__,
  FetchSize: __FETCH_SZ__, 
  adapterName: 'MSSqlReader', 
  StartPosition: '__LSN__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__', 
  Tables: 'dbo.Specialties',
  cdcRoleName: 'STRIIM_READER',
  Username: '__SOURCE_UNAME__', 
  IntegratedSecurity: __INTEG_SEC__,
  FilterTransactionBoundaries: __FLTR_TRANS_BNDRS__,
  ConnectionPoolSize: __CONNECT_POOL_SZ__,
  SendBeforeImage: __SEND_BEFORE_IMAGE__,
  AutoDisableTableCDC: __AUTO_DISABLE_TBL_CDC__
) 
OUTPUT TO output_a_o_fact_h_l_specialties_CDC;

-- 20 is the index of the ChangeBy field in the inbound record.
-- Note, it's the index of the relevant field in the TABLE not in the insert statement, doh.
--
CREATE OR REPLACE CQ CQ_JOIN_USERS_Specialties
INSERT INTO LoginCache
SELECT putuserdata (s,'LoginName',U.login_name)
FROM output_a_o_fact_h_l_specialties_CDC s
left JOIN UserListExternal AS U
   on to_int(s.data[22]) = U.id;


CREATE OR REPLACE TARGET Specialties_Created_Record_CDC USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: 'Postgres',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: 'dbo.Specialties,__TARGET_DB__.core.Created columnmap(
        reference_id=Specialty_Id,
        table_name=\'Specialties\',
        created_date=CreatedDate)',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCache;


CREATE OR REPLACE TARGET Specialties_ChangedRecord_CDC USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: 'Postgres',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: 'dbo.Specialties,__TARGET_DB__.core.Changed columnmap(
        reference_id=Specialty_Id,
        table_name=\'Specialties\',
        changed_date=ChangedDate,
        changed_by=@userdata(LoginName),
        former_values=FormerValues)',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCache;



-- DESC
-- SORT
-- ALIASES
-- KEYWORDS

-- English  
--
CREATE OR REPLACE CQ Specialties_EN_CQ_Desc_CDC
INSERT INTO Specialties_EN_stream_desc_CDC
SELECT
putUserData(t,'Language','EN','Aux','0','Text',data[2] )
FROM output_a_o_fact_h_l_specialties_CDC t;

CREATE OR REPLACE CQ Specialties_EN_CQ_Aliases_CDC
INSERT INTO Specialties_EN_stream_aliases_CDC
SELECT
putUserData(t,'Language','EN','Aux','0','Text',data[6] )
FROM output_a_o_fact_h_l_specialties_CDC t;

CREATE OR REPLACE CQ Specialties_EN_CQ_Keywords_CDC
INSERT INTO Specialties_EN_stream_keywords_CDC
SELECT
putUserData(t,'Language','EN','Aux','0','Text',data[13] )
FROM output_a_o_fact_h_l_specialties_CDC t;

CREATE OR REPLACE CQ Specialties_EN_CQ_Sort
INSERT INTO Specialties_EN_stream_sort_CDC
SELECT
putUserData(t,'Language','EN','Aux','0','Text',data[4] )
FROM output_a_o_fact_h_l_specialties_CDC t;


-- German DE
--
CREATE OR REPLACE CQ Specialties_DE_CQ_Desc_CDC
INSERT INTO Specialties_DE_stream_desc_CDC
SELECT
putUserData(t,'Language','DE','Aux','0','Text',data[3] )
FROM output_a_o_fact_h_l_specialties_CDC t;

CREATE OR REPLACE CQ Specialties_DE_CQ_Aliases_CDC
INSERT INTO Specialties_DE_stream_aliases_CDC
SELECT
putUserData(t,'Language','DE','Aux','0','Text',data[7] )
FROM output_a_o_fact_h_l_specialties_CDC t;

CREATE OR REPLACE CQ Specialties_DE_CQ_Keywords_CDC
INSERT INTO Specialties_DE_stream_keywords_CDC
SELECT
putUserData(t,'Language','DE','Aux','0','Text',data[14] )
FROM output_a_o_fact_h_l_specialties_CDC t;

CREATE OR REPLACE CQ Specialties_DE_CQ_Sort
INSERT INTO Specialties_DE_stream_sort_CDC
SELECT
putUserData(t,'Language','DE','Aux','0','Text',data[5] )
FROM output_a_o_fact_h_l_specialties_CDC t;

-- French FR
--
CREATE OR REPLACE CQ Specialties_FR_CQ_Desc_CDC
INSERT INTO Specialties_FR_stream_desc_CDC
SELECT
putUserData(t,'Language','FR','Aux','0','Text',data[10] )
FROM output_a_o_fact_h_l_specialties_CDC t;

CREATE OR REPLACE CQ Specialties_FR_CQ_Aliases_CDC
INSERT INTO Specialties_FR_stream_aliases_CDC
SELECT
putUserData(t,'Language','FR','Aux','0','Text',data[12] )
FROM output_a_o_fact_h_l_specialties_CDC t;

CREATE OR REPLACE CQ Specialties_FR_CQ_Keywords_CDC
INSERT INTO Specialties_FR_stream_keywords_CDC
SELECT
putUserData(t,'Language','FR','Aux','0','Text',data[15] )
FROM output_a_o_fact_h_l_specialties_CDC t;

CREATE OR REPLACE CQ Specialties_FR_CQ_Sort
INSERT INTO Specialties_FR_stream_sort_CDC
SELECT
putUserData(t,'Language','FR','Aux','0','Text',data[11] )
FROM output_a_o_fact_h_l_specialties_CDC t;


-- 
-- Dont forget you need to generate the Created and Changed tables
--
-- The core.Specialties Table
-- 
--
CREATE OR REPLACE TARGET a_o_fact_h_l_specialties_CDC_targetSS_SS USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
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
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM output_a_o_fact_h_l_specialties_CDC;


--ENGLISH Translation rows.
--
CREATE OR REPLACE TARGET a_o_fact_h_l_specialties_target_EN_desc_CDC USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Specialties, __TARGET_DB__.core.translation columnmap(
		guid=DescGUID, 
		text=@USERDATA(Text), 
		language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM Specialties_EN_stream_desc_CDC;

--
CREATE OR REPLACE TARGET a_o_fact_h_l_specialties_target_EN_aliases_CDC USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Specialties, __TARGET_DB__.core.translation columnmap(
		guid=AliasesGUID, 
		text=@USERDATA(Text), 
		language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM Specialties_EN_stream_aliases_CDC;

CREATE OR REPLACE TARGET a_o_fact_h_l_specialties_target_EN_sort_CDC USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Specialties, __TARGET_DB__.core.translation columnmap(
		guid=SortGUID, 
		text=@USERDATA(Text), 
		language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM Specialties_EN_stream_sort_CDC;

--
CREATE OR REPLACE TARGET a_o_fact_h_l_specialties_target_EN_keywords_CDC USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Specialties, __TARGET_DB__.core.translation columnmap(
		guid=KeywordsGUID, 
		text=@USERDATA(Text), 
		language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM Specialties_EN_stream_keywords_CDC;



-- German Tranlation rows. 
--
CREATE OR REPLACE TARGET a_o_fact_h_l_specialties_target_DE_desc_CDC USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Specialties, __TARGET_DB__.core.translation columnmap(
		guid=DescGUID, 
		text=@USERDATA(Text), 
		language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM Specialties_DE_stream_desc_CDC;

-- core.Translation table German Aliases Values  
--
CREATE OR REPLACE TARGET a_o_fact_h_l_specialties_target_DE_aliases_CDC USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Specialties, __TARGET_DB__.core.translation columnmap(
		guid=AliasesGUID, 
		text=@USERDATA(Text), 
		language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM Specialties_DE_stream_aliases_CDC;


-- core.Translation table German Sort 
--
CREATE OR REPLACE TARGET a_o_fact_h_l_specialties_target_DE_sort_CDC USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Specialties, __TARGET_DB__.core.translation columnmap(
                guid=SortGUID,
                text=@USERDATA(Text),
                language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM Specialties_DE_stream_sort_CDC;


-- core.Translation table German Keywords Values  
--
CREATE OR REPLACE TARGET a_o_fact_h_l_specialties_target_DE_keywords_CDC USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Specialties, __TARGET_DB__.core.translation columnmap(
		guid=KeywordsGUID, 
		text=@USERDATA(Text), 
		language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM Specialties_DE_stream_keywords_CDC;

-- FRENCH TRANSLATION ROWS

-- core.Translation table French Desc  
--
CREATE OR REPLACE TARGET a_o_fact_h_l_specialties_target_FR_desc_CDC USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Specialties, __TARGET_DB__.core.translation columnmap(
		guid=DescGUID, 
		text=@USERDATA(Text), 
		language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM Specialties_FR_stream_desc_CDC;


-- core.Translation table French Aliases Values  
--
CREATE OR REPLACE TARGET a_o_fact_h_l_specialties_target_FR_aliases_CDC USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Specialties, __TARGET_DB__.core.translation columnmap(
		guid=AliasesGUID, 
		text=@USERDATA(Text), 
		language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM Specialties_FR_stream_aliases_CDC;

-- core.Translation table French Sort Values
--
CREATE OR REPLACE TARGET a_o_fact_h_l_specialties_target_FR_sort_CDC USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Specialties, __TARGET_DB__.core.translation columnmap(
                guid=SortGUID,
                text=@USERDATA(Text),
                language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM Specialties_FR_stream_sort_CDC;


-- core.Translation table French Keywords Values  
--
CREATE OR REPLACE TARGET a_o_fact_h_l_specialties_target_FR_keywords_CDC USING Global.DatabaseWriter( 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'dbo.Specialties, __TARGET_DB__.core.translation columnmap(
		guid=KeywordsGUID, 
		text=@USERDATA(Text), 
		language=@USERDATA(Language))',
  IgnorableExceptioncode : 'NO_OP_DELETE', 
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
INPUT FROM Specialties_FR_stream_keywords_CDC;

END APPLICATION a_o_fact_h_l_specialties_CDC;


