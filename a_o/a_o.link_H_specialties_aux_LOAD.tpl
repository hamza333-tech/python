---
--- This application loads a lot of small tables that are associated with Specialties
---
---
---
---
USE Migration;

STOP APPLICATION a_o_link_H_specialties_aux_LOAD;
UNDEPLOY APPLICATION a_o_link_H_specialties_aux_LOAD;
DROP APPLICATION a_o_link_H_specialties_aux_LOAD CASCADE;
CREATE APPLICATION a_o_link_H_specialties_aux_LOAD;

CREATE OR REPLACE SOURCE SQL_DBSource_link_H_spec_LOAD USING Global.DatabaseReader ( 
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  DatabaseName: '__SOURCE_DB__', 
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: '
	   Specialties2Market_Alert KeyColumns(Specialty_id, Market_Alert_id);
	   SpecialtyTaxonomyScope KeyColumns(SpecialtyTaxonomyScopeId)'
  ) OUTPUT TO SQL_DBSource_link_H_spec_LOAD_OutputStream;


CREATE OR REPLACE TARGET Target_link_H_spec_LOAD USING Global.DatabaseWriter ( 
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
	__SOURCE_DB__.dbo.SpecialtyTaxonomyScope, __TARGET_DB__.core.specialty_2_taxonomy_scope columnmap(
	  id=SpecialtyTaxonomyScopeId	
	 ,taxonomy_scope_id=TaxonomyScopeId
	 ,specialty_id=SpecialtyId);
	__SOURCE_DB__.dbo.Specialties2Market_Alert,__TARGET_DB__.core.specialties_2_market_alert columnmap(
	  market_alert_id=Market_alert_id
	 ,specialty_id=Specialty_id)', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM  SQL_DBSource_link_H_spec_LOAD_OutputStream;

END APPLICATION a_o_link_H_specialties_aux_LOAD;

