---
---


-- core.specialty_2_taxonomy_scope
-- core.specialty_type;

---
USE Migration;
-- bulk_H_specialty_type_5.tpl

STOP APPLICATION  bulk_H_5_specialty_type_LOAD;
UNDEPLOY APPLICATION bulk_H_5_specialty_type_LOAD;
DROP APPLICATION bulk_H_5_specialty_type_LOAD CASCADE;
CREATE APPLICATION bulk_H_5_specialty_type_LOAD;


CREATE OR REPLACE SOURCE SQL_DBSource_H_specialty_type_LOAD USING Global.DatabaseReader ( 
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  DatabaseName: '__SOURCE_DB__', 
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: '__SOURCE_DB__.dbo.SpecialtyTaxonomyScope KeyColumns(SpecialtyTaxonomyScopeId);
	   __SOURCE_DB__.dbo.SpecialtyType KeyColumns(SpecialtyTypeId)'
)
OUTPUT TO SQL_DBSource_H_specialty_type_LOAD_OutputStream;

-- specialty_type needs changed and created

CREATE OR REPLACE TARGET Target_H_specialty_type_x_LOAD USING Global.DatabaseWriter ( 
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
  Tables: '__SOURCE_DB__.dbo.SpecialtyType,__TARGET_DB__.core.specialty_type columnmap(
	   id = SpecialtyTypeId
	  ,name = SpecialtyTypeName 
	  ,hierarchy_depth_limit = HeirarchyDepthLimit 
	  ,is_active = isActive 
	  ,is_mergeable = isMergeable 
	  ,is_sortable = isSortable 
	  ,is_artwork_type_applicable = isArtworkTypeApplicable 
	  ,is_taxonomy_scope_applicable = isTaxonomyScopeApplicable 
	  ,is_period_applicable = isPeriodApplicable 
	  ,is_related_specialty_applicable = isRelatedSpecialtyApplicable 
	  ,is_deletable = isDeletable 
	  ,related_specialty_type = RelatedSpecialtyType 
	  ,exclude_from_auto_tagging_applicable = ExcludeFromAutoTaggingApplicable); 
	__SOURCE_DB__.dbo.SpecialtyTaxonomyScope, __TARGET_DB__.core.specialty_2_taxonomy_scope columnmap(
	  id=SpecialtyTaxonomyScopeId	
	 ,taxonomy_scope_id=TaxonomyScopeId
	 ,specialty_id=SpecialtyId)', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM  SQL_DBSource_H_specialty_type_LOAD_OutputStream;

END APPLICATION bulk_H_5_specialty_type_LOAD;

