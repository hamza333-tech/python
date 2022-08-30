USE Migration;

STOP APPLICATION a_o_Fact_H_artwork_LOAD;
UNDEPLOY APPLICATION a_o_Fact_H_artwork_LOAD;
DROP APPLICATION a_o_Fact_H_artwork_LOAD CASCADE;
CREATE APPLICATION a_o_Fact_H_artwork_LOAD;

CREATE OR REPLACE SOURCE SQL_DBSource_Fact_H_artwork USING Global.DatabaseReader ( 
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  DatabaseName: '__SOURCE_DB__', 
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: '__SOURCE_DB__.dbo.Artwork KeyColumns(Artwork_id)'
)
OUTPUT TO SQL_DBSource_Fact_H_artwork_OutputStream;


--
-- CQ = Continuous Query
-- Note, we do multiple LEFT JOIN operations to get multiple LoginID mappings. 
--

CREATE OR REPLACE CQ CQ_JOIN_USERS_gallery_ChangedBy 
INSERT INTO ArtworkLoginCache
SELECT putuserdata(s,'CreatedUser',R.login_name, 'ChangedUser', H.login_name)
FROM SQL_DBSource_Fact_H_artwork_OutputStream s 
LEFT JOIN UserList R on to_int(s.data[38]) = R.id
LEFT JOIN UserList H on to_int(s.data[40]) = H.id;


-- legacy Artwork to target Artwork
--
CREATE OR REPLACE TARGET SQL_Target_Fact_H_artwork USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Password: '__TARGET_PWD__', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  CDDLAction: 'Process', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Tables: '__SOURCE_DB__.dbo.Artwork,core.artwork columnmap(
	 id=Artwork_id
	,is_deleted=isDeleted
	,artwork_name=Artwork_Name
	,work_year_from=Workyear_from
	,work_year_to=Workyear_to
	,height=Height
	,width=Width
	,depth=Depth
	,edition=Edition 
	,artwork_type_id=Artwork_type_Id
	,measurement_type=MeasurementType
	,artwork_count=Artwork_count
	,artist_modifier_id=Artist_modifier_id
	,copyright=Copyright
	,work_year_from_modifier_id=Workyear_from_modifier_id
	,work_year_to_modifier_id=Workyear_to_modifier_id
	,work_year_from_addition=Workyear_from_addition
	,work_year_to_addition=Workyear_to_addition
	,work_year_modifier=Workyear_modifier
	,after_to_modifier=after_to_modifier
	,after_from_modifier=after_from_modifier
	,photo=photo
	,provenance=provenance
	,exhibition=exhibition
	,literature=literature
	,other_lable=otherLable
	,other=other
	,work_year_modifier_to=workyear_modifier_to
	,month_from=monthFrom
	,month_to=monthTo
	,day_from=dayFrom
	,day_to=dayTo
	,diameter=Diameter
	,is_installation_view=isInstallationView
	,is_dimensions_vary=isDimensionsVary
  )', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM SQL_DBSource_Fact_H_artwork_OutputStream;


-- Produced "Failure to bind" error even if the peccant field is removed from the columnmap() declaration.
-- This is because  #@%$! Striim tries to automatically move fields with the same name even if you
-- are using columnmap.  
-- In this case, the type declaration of the field was switch from INT to TINYINT which eliminated the 
-- casting error. This error should not have happened anyway, as it was INT-to-Int originally. Why should it require
-- a smaller integer type in the target?!
--
--
CREATE OR REPLACE TARGET SQL_Target_Fact_H_artworkgallery USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Password: '__TARGET_PWD__', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  CDDLAction: 'Process', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Tables: '__SOURCE_DB__.dbo.Artwork,core.artwork_gallery columnmap(
         id=Artwork_id
        ,status_id=Status_id     
        ,gallery_id=Gallery_id
	,price=Price
	,currency_id=Currency_id
	,sale_status_id=SaleStatus_id
	,artwork_type_id=Artwork_type_id
	,trading_status_id=Trading_status_id
	,price_usd=Price_USD
	,price_to=Price_to
	,price_to_usd=Price_to_usd
	,is_exclude_from_all_artworks=isExcludeFromAllArtworks
	,relisted_date=RelistedDate
	,currency_code=CurrencyCode
  )', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM SQL_DBSource_Fact_H_artwork_OutputStream;
	
-- REMOVED THIS FIELD FOR DIAGNOSTIC REAONS:  ShowHome = ShowHome
CREATE OR REPLACE TARGET SQL_Target_Fact_H_artworkDisplay USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Password: '__TARGET_PWD__', 
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  CDDLAction: 'Process', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Tables: '__SOURCE_DB__.dbo.Artwork,core.artwork_display columnmap(
         id=Artwork_id
	,sort_order = SortOrder
	,photo = Photo
	,is_exclude_from_all_artworks=isExcludeFromAllArtworks
	,is_installation_view=isInstallationView
  )', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM SQL_DBSource_Fact_H_artwork_OutputStream;

	
CREATE OR REPLACE TARGET CreatedRecordArtwork USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: '__SOURCE_DB__.dbo.Artwork,core.history_created columnmap(
        reference_id=Artwork_id,
        table_name=\'artwork\',
	created_by=@userdata(CreatedUser),
	created_date=Created_Date)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM ArtworkLoginCache;


CREATE OR REPLACE TARGET ChangedRecordArtwork USING Global.DatabaseWriter (
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Tables: '__SOURCE_DB__.dbo.Artwork,core.history_changed columnmap(
        reference_id=Artwork_id,
        table_name=\'artwork\',
	changed_by=@userdata(ChangedUser),
	changed_date=Changed_Date,
        change_comment=FormerValues)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter')
INPUT FROM ArtworkLoginCache;

END APPLICATION a_o_Fact_H_artwork_LOAD;
