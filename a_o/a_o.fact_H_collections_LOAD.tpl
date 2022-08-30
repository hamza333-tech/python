
--  Collections table Collections table
-- 
--

USE Migration;

STOP APPLICATION a_o_Fact_H_collections_LOAD;
UNDEPLOY APPLICATION a_o_Fact_H_collections_LOAD;
DROP APPLICATION a_o_Fact_H_collections_LOAD CASCADE;
CREATE APPLICATION a_o_Fact_H_collections_LOAD;

CREATE OR REPLACE SOURCE SQL_DBSource_Fact_H_collections USING Global.DatabaseReader ( 
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  DatabaseName: '__SOURCE_DB__', 
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: '__SOURCE_DB__.dbo.Collections KeyColumns(Collection_id)'
)
OUTPUT TO SQL_DBSource_Fact_H_collections_OutputStream;


--
-- CQ = Continuous Query
--
-- Slightly tricky: Note we do N left outer joins here to get N translations of
-- LoginId to LoginName.
--

CREATE OR REPLACE CQ CQ_JOIN_USERS_collections_ChangedBy 
INSERT INTO LoginCache
SELECT putuserdata(s,'Created_By',Q.login_name,'Changed_By',R.login_name)
FROM SQL_DBSource_Fact_H_collections_OutputStream s 
LEFT JOIN UserList Q on to_int(s.data[48]) = Q.id
LEFT JOIN UserList R on to_int(s.data[50]) = R.id;


CREATE OR REPLACE TARGET SQL_Target_Fact_H_collections USING Global.DatabaseWriter ( 
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
  Tables: '__SOURCE_DB__.dbo.Collections,core.collections columnmap(
	 id=Collection_Id
	,collection_name=Collection_name
	,start=Start
	,finish=Finish
	,collection_type_id=Collection_type_id
	,c_unique=C_unique
	,status_id=Status_id
	,description=Description
	,gallery_id=Gallery_id
	,art_fair_id=Art_Fair_Id
	,feature_image_id=Feature_image_id
	,ref_num=Ref_num
	,contact=Contact
	,contact_phone=Contact_phone
	,contact_fax=Contact_fax
	,language_id=Language_id
	,unit=Unit
	,price_status_id=PriceStatus_id
	,received_price_list=Received_price_list
	,currency_id=Currency_id
	,due_date=Due_date
	,lot_entry=Lot_entry
	,lot_edit=Lot_edit
	,price_entry=Price_entry
	,price_edit=Price_edit
	,sale_code=Sale_code
	,lot_entry_login_id=Lot_entry_login_id
	,lot_edit_login_id=Lot_edit_login_id
	,price_entry_login_id=Price_entry_login_id
	,price_edit_login_id=price_edit_login_id
	,scanner=Scanner
	,current_upcoming=Current_upcoming
	,contact_email=Contact_email
	,pdf_catalog_id=PDF_catalog_id
	,publish=Publish
	,opening_date=Opening_date
	,city_id=City_id
	,url=Url
	,is_linked=is_linked
	,address_comment=Address_comment
	,catalog_received=Catalog_received
	,awc_sort_order=awc_sortorder
	,specialist_name=Specialist_name
	,specialist_title=Specialist_title
	,specialist_email=Specialist_email
	,specialist_phone=Specialist_phone
	,show_in_member_site=Show_in_member_site
	,show_in_member_site_count=Showinmembersite_count
	,participate_in_tracking=participate_in_tracking
	,events_calendar=EventsCalendar
	,show_in_calendar=ShowInCalendar
	,sale_url=SaleUrl
	,show_in_ahms=ShowInAHMS
	,lot_to_be_edited_date=LotToBeEditedDate
	,lot_to_be_edited_by_login_id=LotToBeEditedByLoginId
	,is_new_address=isNewAddress
	,state_id=state_id
	,country_id=country_id
	,postal_code=Postalcode
	,geo_coordinates=Geocordinates
	,seo_name=seo_name
	,image_caption=ImageCaption
	,start_preview_time=StartPreviewTime
	,end_preview_time=EndPreviewTime
	,catalog_image=CatalogueImage
	,venue=Venue
	,press_release=PressRelease
	,is_featured=isFeatured
	,pier=Pier
	,hall=Hall
	,section=Section
	,address_comment_2=address_comment2
  )', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM LoginCache;
--INPUT FROM SQL_DBSource_Fact_H_collections_OutputStream;

CREATE OR REPLACE TARGET CreatedRecordCollectionLoad USING Global.DatabaseWriter (
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
  Tables: '__SOURCE_DB__.dbo.collections,core.history_created columnmap(
        reference_id=Collection_id,
        table_name=\'collections\',
	created_by=@userdata(Created_by),
	created_date=Created_Date)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCache;


CREATE OR REPLACE TARGET ChangedRecordCollections USING Global.DatabaseWriter (
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
  Tables: '__SOURCE_DB__.dbo.collections,core.history_changed columnmap(
        reference_id=Collection_id,
        table_name=\'collections\',
	changed_by=@userdata(Changed_by),
	changed_date=Changed_Date,
        change_comment=FormerValues)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter')
INPUT FROM LoginCache;

END APPLICATION a_o_Fact_H_collections_LOAD;

