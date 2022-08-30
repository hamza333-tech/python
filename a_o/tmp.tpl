---
--- This application loads a lot of small tables that are associated with Specialties
---
---
---
---
USE Migration;

STOP APPLICATION test_LOAD;
UNDEPLOY APPLICATION test_LOAD;
DROP APPLICATION test_LOAD CASCADE;
CREATE APPLICATION test_LOAD;

CREATE OR REPLACE SOURCE SQL_DBSource_link_H_specialties_aux_LOAD USING Global.DatabaseReader ( 
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
	   __SOURCE_DB__.dbo.SpecialtyRelation KeyColumns(SpecialtyId);
	   __SOURCE_DB__.dbo.Specialties2MarketAlert KeyColumns(Specialty_id, Market_Alert_id);
	   __SOURCE_DB__.dbo.SpecialtyTaxonomyScore KeyColumns(TaxonomyScopeId, SpecialtyId)'
  )
OUTPUT TO SQL_DBSource_link_H_specialties_aux_LOAD_OutputStream;


-- consider putting created date in the tables to save pointless entries.
--
-- specialties_2_market_alert needs changed
-- specialties_2_gallery needs created, changed
-- specialties_2_event needs created, changed
-- specialties_2_artwork needs changed
-- specialties_2_artist needs changed
-- specialties_2_collection needs created, changed
-- specialties_2_relation needs changed and created
-- specialties_2_taxonomy_scope needs changed and created
-- specialties_2_artwork_type needs changed and created


CREATE OR REPLACE TARGET Target_link_H_specialties_aux_LOAD USING Global.DatabaseWriter ( 
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
	__SOURCE_DB__.dbo.SpecialtyRelation,__TARGET_DB__.core.specialty_2_relation columnmap(
	  id=SpecialtyRelationId	
	 ,related_specialty_id=RelatedSpecialtyId
	 ,specialty_id=SpecialtyId);
	__SOURCE_DB__.dbo.SpecialtyTaxonomyScope, __TARGET_DB__.core.specialty_2_taxonomy_scope columnmap(
	  id=SpecialtyTaxonomyScopeId	
	 ,taxonomy_scope_id=TaxonomyScopeId
	 ,specialty_id=SpecialtyId);
	__SOURCE_DB__.dbo.Specialties2MarketAlert,__TARGET_DB__.core.specialties_2_market_alert columnmap(
	  market_alert_id=Market_alert_id
	 ,specialty_id=Specialty_id)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM  SQL_DBSource_link_H_specialties_aux_LOAD_OutputStream;

END APPLICATION test_LOAD;

