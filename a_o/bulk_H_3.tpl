
-- this bulk loader runs 
-- a_o.fact_H_gallery_LOAD.tpl
-- a_o.dim_H_artworktype_LOAD.tpl
-- a_o.dim_H_gender_LOAD.tpl
-- a_o.fact_artist_LOAD.tpl
-- a_o.fact_H_L_LOAD.tpl (specialties)
-- a_o.fact_H_artwork_LOAD.tpl
-- a_o.dim_H_L_artist_modifier_LOAD.tpl

-- history_created, history_changed, history_approval
-- collections

-- gallery
-- artwork_type
-- gender
-- artist
-- specialties
-- artwork
-- artwork_gallery
-- artwork_display
-- artist_modifier
--
-- This is HISTORY so it needs the login and the caches.

USE Migration;

-- bulk_H_3

STOP APPLICATION bulk_H_3_LOAD;
UNDEPLOY APPLICATION bulk_H_3_LOAD;
DROP APPLICATION bulk_H_3_LOAD CASCADE;
CREATE APPLICATION bulk_H_3_LOAD;

-- FILE_INPUT a_o.fact_H_collections_LOAD.tpl

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

CREATE OR REPLACE TARGET CreatedRecordCollectionsLoad USING Global.DatabaseWriter (
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




-- FILE_INPUT a_o.fact_H_gallery_LOAD.tpl


CREATE OR REPLACE SOURCE SQL_DBSource_fact_gallery USING Global.DatabaseReader ( 
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  DatabaseName: '__SOURCE_DB__', 
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: '__SOURCE_DB__.dbo.Gallery KeyColumns(Gallery_id)'
)
OUTPUT TO SQL_DBSource_fact_gallery_OutputStream;


CREATE OR REPLACE CQ CQ_JOIN_USERS_ChangedBy 
INSERT INTO LoginCache
SELECT putuserdata(s,'CreatedUser',R.login_name, 'ChangedUser', H.login_name)
FROM SQL_DBSource_fact_gallery_OutputStream s 
LEFT JOIN UserList R on to_int(s.data[28]) = R.id
LEFT JOIN UserList H on to_int(s.data[30]) = H.id;


CREATE OR REPLACE TARGET SQL_Target_Fact_H_gallery USING Global.DatabaseWriter ( 
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
  Tables: '__SOURCE_DB__.dbo.Gallery,core.gallery columnmap(
	id=Gallery_id,
	gallery_name=Gallery_name,
	gallery_type_id=Gallery_type_id,
	sort_name=Sortname,
	letter=Letter,
	status_id=Status_id,
	logo=Logo,
	homepage_col_id=HomepageCol_id,
	feature_image=FeatureImage,
	customer_source_id=Customer_source_id,
	salesman_id=Salesman_id,
	customer_source_date=Customer_source_date,
	marketing_source_id=Marketing_source_id,
	coordinator_id=Coordinator_id,
	feature_image=FeatureImage,
	new_gal_pub=New_gal_pub,
	show_address=Show_address,	
	aliases=Aliases,
	currency_id=Currency_id,
	measurement_unit=MeasurementUnit,
	awc_artist_id=AWC_Artist_id,
	metatag=Metatag,
	auction_house_directory=Auction_House_Directory,
	bill_dept_email=Bill_dept_email,
	show_in_auction_house=Show_In_Auction_House,
	selected_cat_index=SelectedCatIndex,
	default_language_id=Default_language_id,
	participate_in_tracking=Participate_In_Tracking,
	is_new=isNew,
	display_dart_ads=displayDartAds,
	show_prop_url=Show_Prop_Url,
	exclude_ma=ExcludeMA,
	share_widget=ShareWidget,
	premium_gallery_member=PremiumGalleryMember,
	nickname=NickName,
	address_in_header=AddressInHeader,
	homepage_url=HomePageUrl,
	homepage_description=HomePageDescription,
	link_name=LinkName,
	seo_name=SEO_Name,
	no_override_homepage_values=NoOverrideHomePageValues,
	homepage_url_de=HomePageUrlDE,
	homepage_url=HomePageURLFR,
	square_logo=SquareLogo,
	default_artworks_sorting_id=DefaultArtworksSortingId,
	is_gallery_portal=isGalleryPortal,
	is_hidden_in_admin=isHiddenInAdmin
  )', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM LoginCache;

CREATE OR REPLACE TARGET CreatedRecordGalleryLoad USING Global.DatabaseWriter (
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
  Tables: '__SOURCE_DB__.dbo.Gallery,core.history_created columnmap(
        reference_id=Gallery_id,
        table_name=\'gallery\',
	created_by=@userdata(CreatedUser),
	created_date=Created_Date)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCache;


CREATE OR REPLACE TARGET ChangedRecordGalleryLoad USING Global.DatabaseWriter (
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
  Tables: '__SOURCE_DB__.dbo.Gallery,core.history_changed columnmap(
        reference_id=Gallery_id,
        table_name=\'gallery\',
	changed_by=@userdata(ChangedUser),
	changed_date=Changed_Date,
        change_comment=FormerValues)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter')
INPUT FROM LoginCache;

-- FILE_INPUT a_o.dim_H_artworktype_LOAD.tpl

CREATE OR REPLACE SOURCE SQL_DBSource_H_artworktype USING Global.DatabaseReader ( 
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  DatabaseName: '__SOURCE_DB__', 
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: '__SOURCE_DB__.dbo.ArtworkType KeyColumns(ArtworkTypeID)'
)
OUTPUT TO SQL_DBSource_H_artworktype_OutputStream;

CREATE OR REPLACE CQ CQ_JOIN_USERS_ArtworkType_LOAD 
INSERT INTO LoginCacheArtworkType 
SELECT putuserdata (s,'LoginName',U.login_name)
FROM SQL_DBSource_H_artworktype_OutputStream s
join UserList U
where to_int(s.data[3]) = U.id;

CREATE OR REPLACE TARGET SQL_Target_H USING Global.DatabaseWriter ( 
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
  Tables: '__SOURCE_DB__.dbo.ArtworkType,core.artwork_type columnmap(
	id=ArtworkTypeID,
	name=ArtworkTypeName)', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM  SQL_DBSource_H_artworktype_OutputStream;

CREATE OR REPLACE TARGET CreatedRecord USING Global.DatabaseWriter (
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
  Tables: '__SOURCE_DB__.dbo.ArtworkType,core.history_created columnmap(
        reference_id=ArtworkTypeId,
        table_name=\'artwork_type\',
        created_date=CreatedDate)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM SQL_DBSource_H_artworktype_OutputStream;

CREATE OR REPLACE TARGET ChangedRecordArtworkType USING Global.DatabaseWriter (
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
  Tables: '__SOURCE_DB__.dbo.ArtworkType,core.history_changed columnmap(
        reference_id=ArtworkTypeId,
        table_name=\'artwork_type\',
        changed_date=ChangedDate,
        changed_by=@userdata(LoginName),
        change_comment=FormerValues)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCacheArtworkType;

-- FILE_INPUT a_o.dim_H_gender_LOAD.tpl

CREATE OR REPLACE SOURCE SQL_DBSource_H_gender USING Global.DatabaseReader ( 
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  DatabaseName: '__SOURCE_DB__', 
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: '__SOURCE_DB__.dbo.Gender KeyColumns(GenderId)'
)
OUTPUT TO SQL_DBSource_H_gender_OutputStream;

--
-- CQ = Continuous Query
--
-- Gender CQ
CREATE OR REPLACE CQ CQ_JOIN_USERS_Gender 
INSERT INTO LoginCacheGender 
SELECT putuserdata (s,'LoginName',U.login_name)
FROM SQL_DBSource_H_gender_OutputStream s
join UserList U
where to_int(s.data[4]) = U.id;

CREATE OR REPLACE TARGET SQL_Target_H_gender USING Global.DatabaseWriter ( 
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
  Tables: '__SOURCE_DB__.dbo.Gender,core.gender columnmap(
        id=GenderID,
        name=GenderName)', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM  SQL_DBSource_H_gender_OutputStream;

CREATE OR REPLACE TARGET CreatedRecordGender USING Global.DatabaseWriter (
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
  Tables: ' __SOURCE_DB__.dbo.Gender,core.history_created columnmap(
        reference_id=GenderId,
        table_name=\'gender\',
        created_date=CreatedDate)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM SQL_DBSource_H_gender_OutputStream;

CREATE OR REPLACE TARGET ChangedRecordGender USING Global.DatabaseWriter (
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
  Tables: ' __SOURCE_DB__.dbo.Gender,core.history_changed columnmap(
        reference_id=GenderId,
        table_name=\'gender\',
        changed_date=ChangedDate,
        changed_by=@userdata(LoginName),
        change_comment=FormerValues
	)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCacheGender;

-- FILE_INPUT a_o.fact_artist_LOAD.tpl

CREATE OR REPLACE SOURCE SQL_DBSource_Fact_H_Artist USING Global.DatabaseReader (
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  DatabaseName: '__SOURCE_DB__',
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: '__SOURCE_DB__.dbo.Artist KeyColumns(Artist_id)'
)
OUTPUT TO SQL_DBSource_Fact_H_Artist_OutputStream;

--
CREATE OR REPLACE CQ CQ_JOIN_USERS_Artist
INSERT INTO LoginCache
SELECT putuserdata(s,'CreatedName', R.login_name, 'ChangedName', H.login_name,'ApprovalName',A.login_name)
FROM  SQL_DBSource_Fact_H_Artist_OutputStream s
left join UserList R on to_int(s.data[11]) = R.id
left join UserList H on to_int(s.data[13]) = H.id
left join UserList A on to_int(s.data[15]) = A.id;

--
CREATE OR REPLACE TARGET a_o_fact_Artist_LOAD_target USING Global.DatabaseWriter ( 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Tables: '
	__SOURCE_DB__.dbo.Artist, core.Artist columnmap(
          id=Artist_id
        , last=Last
        , first=First
        , sort_name=Sortname
        , status_id=Status_id
        , year_born=Year_born
        , year_died=Year_died
        , year_born_modifier_id=Year_born_modifier_id
        , year_died_modifier_id=Year_died_modifier_id
        , nationality_id=Nationality_id
        , aliases=Aliases
        , gallery_id=Gallery_id
        , start_letter=Start_letter
        , school_of=School_of
        , notes=notes
        , flags=flags
        , display_directory=DisplayDirectory
        , suppress_lots=SuppressLots
        , suppress_images=SuppressImages
        , artist_seo_name=artist_seo_name
        , is_collaboration=isCollaboration
        , is_locked_for_artist_admin=isLockedForArtistAdmin
        , gender_id=GenderId
        , month_born=MonthBorn
        , day_born=DayBorn
        , month_died=MonthDied
        , day_died=DayDied
        , cause_of_death=CauseOfDeath
        , overwrite_related_artists_alg=OverwriteRelatedArtistsAlg
        , overwrite_related_categories_alg=OverwriteRelatedCategoriesAlg
  )',
  CheckPointTable: '__CHKPOINT__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__',
  CDDLAction: 'Process', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  Password: '__TARGET_PWD__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM SQL_DBSource_Fact_H_Artist_OutputStream;



CREATE OR REPLACE TARGET Artist_CreatedRecord_LOAD USING Global.DatabaseWriter (
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
  Tables: '__SOURCE_DB__.dbo.Artist,core.history_created columnmap(
        reference_id=Artist_id,
        table_name=\'artist\',
	created_by=@userdata(CreatedName),
        created_date=Created_Date)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCache;

CREATE OR REPLACE TARGET Artist_ApprovalRecord_LOAD USING Global.DatabaseWriter (
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
  Tables: '__SOURCE_DB__.dbo.Artist,core.history_approval columnmap(
        reference_id=Artist_id,
        table_name=\'artist\',
	approved_by=@userdata(ApprovedName),
        approval_date=Approved_Date)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCache;

CREATE OR REPLACE TARGET Artist_ChangedRecord_LOAD USING Global.DatabaseWriter (
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
  Tables: '__SOURCE_DB__.dbo.Artist,core.history_changed columnmap(
        reference_id=Artist_Id,
        table_name=\'artist\',
        changed_date=Changed_Date,
        changed_by=@userdata(ChangedName),
        change_comment=FormerValues)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCache;


-- FILE_INPUT a_o.fact_H_L_LOAD.tpl

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
  Tables: '__SOURCE_DB__.dbo.Specialties KeyColumns(specialty_id)'
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
-- This passes tests. Add test for all GUID fields populated.
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
INPUT FROM SQL_DBSource_H_L_OutputStream;

-- THIS WORKS
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
INPUT FROM SQL_DBSource_H_L_OutputStream;

-- THIS WORKS
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

CREATE OR REPLACE TARGET a_o_ops_fact_H_L_LOAD_spec_tgt_de_desc USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'__SOURCE_DB__.dbo.Specialties, core.translation columnmap(
                guid=DescGUID,
                text=desc_german,
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

CREATE OR REPLACE TARGET a_o_ops_fact_H_L_LOAD_spec_tgt_de_sort USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'__SOURCE_DB__.dbo.Specialties, core.translation columnmap(
                guid=SortGUID,
                text=Sort_German,
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

CREATE OR REPLACE TARGET a_o_ops_fact_H_L_LOAD_spec_tgt_de_keywords USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'__SOURCE_DB__.dbo.Specialties, core.translation columnmap(
                guid=KeywordsGUID,
                text=keywords_german,
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

CREATE OR REPLACE TARGET a_o_ops_fact_H_L_LOAD_spec_tgt_de_aliases USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'__SOURCE_DB__.dbo.Specialties, core.translation columnmap(
                guid=AliasesGUID,
                text=aliases_german,
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


CREATE OR REPLACE TARGET a_o_ops_fact_H_L_LOAD_spec_tgt_fr_desc USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'__SOURCE_DB__.dbo.Specialties, core.translation columnmap(
                guid=DescGUID,
                text=Desc_french,
                language=\'FR\')',
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

CREATE OR REPLACE TARGET a_o_ops_fact_H_L_LOAD_spec_tgt_fr_sort USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'__SOURCE_DB__.dbo.Specialties, core.translation columnmap(
                guid=SortGUID,
                text=Sort_french,
                language=\'FR\')',
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

CREATE OR REPLACE TARGET a_o_ops_fact_H_L_LOAD_spec_tgt_fr_keywords USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'__SOURCE_DB__.dbo.Specialties, core.translation columnmap(
                guid=KeywordsGUID,
                text=Keywords_french,
                language=\'FR\')',
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

CREATE OR REPLACE TARGET a_o_ops_fact_H_L_LOAD_spec_tgt_fr_aliases USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Tables:'__SOURCE_DB__.dbo.Specialties, core.translation columnmap(
                guid=AliasesGUID,
                text=Aliases_french,
                language=\'FR\')',
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

CREATE OR REPLACE TARGET a_o_ops_fact_H_L_LOAD_spec_tgt_en_desc USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=3',
  Tables:'__SOURCE_DB__.dbo.Specialties, core.translation columnmap(
               guid=DescGUID,
               text=desc_english,
               language=\'EN\')',
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

CREATE OR REPLACE TARGET a_o_ops_fact_H_L_LOAD_spec_tgt_en_sort USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=3',
  Tables:'__SOURCE_DB__.dbo.Specialties, core.translation columnmap(
               guid=SortGUID,
               text=sort_english,
               language=\'EN\')',
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

CREATE OR REPLACE TARGET a_o_ops_fact_H_L_LOAD_spec_tgt_en_keywords USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=3',
  Tables:'__SOURCE_DB__.dbo.Specialties, core.translation columnmap(
               guid=KeywordsGUID,
               text=keywords_english,
               language=\'EN\')',
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

CREATE OR REPLACE TARGET a_o_ops_fact_H_L_LOAD_spec_tgt_en_aliases USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=3',
  Tables:'__SOURCE_DB__.dbo.Specialties, core.translation columnmap(
               guid=AliasesGUID,
               text=aliases_english,
               language=\'EN\')',
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

-- FILE_INPUT a_o.fact_H_artwork_LOAD.tpl
--

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

-- FILE_INPUT a_o.dim_H_L_artist_modifier_LOAD.tpl

CREATE OR REPLACE SOURCE Source_dim_H_L_LOAD USING Global.DatabaseReader ( 
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  DatabaseName: '__SOURCE_DB__', 
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: '__SOURCE_DB__.dbo.Artist_Modifier KeyColumns(Artist_modifier_id)'
)
OUTPUT TO Source_dim_H_L_LOAD_OS;

CREATE OR REPLACE CQ CQ_Load_Artist_Modifier_Changed
INSERT INTO LoginCacheChanged 
SELECT putuserdata (s,'LoginName',U.login_name)
FROM Source_dim_H_L_LOAD_OS s
join UserList U
where to_int(s.data[9]) = U.id;

CREATE OR REPLACE CQ CQ_Load_Artist_Modifier_Created 
INSERT INTO LoginCacheCreated 
SELECT putuserdata (s,'LoginName',U.login_name)
FROM Source_dim_H_L_LOAD_OS s
join UserList U
where to_int(s.data[10]) = U.id;

-- Need to add ChangeDescription to the SourceTable.
--
--Save Data to TARGET
--use COLUMNMAP to sve the Original Username to a Field Called ChangedBy
--

CREATE OR REPLACE TARGET ArtistModifier_SQL_Target USING Global.DatabaseWriter ( 
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
  Tables: '__SOURCE_DB__.dbo.Artist_Modifier,core.artist_modifier columnmap(
	id=Artist_modifier_id,
	name=Artist_modifier_name,
	guid=NameGUID
  )', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM Source_dim_H_L_LOAD_OS;

CREATE OR REPLACE TARGET ArtistModifierCreatedRecord USING Global.DatabaseWriter ( 
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
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter',
  Tables: '__SOURCE_DB__.dbo.Artist_Modifier,core.history_created columnmap(
	reference_id=Artist_Modifier_id,
	table_name=\'artist_modifier\', 
	created_by=@userdata(LoginName),
	created_date=Created_Date)' 
) 
INPUT FROM LoginCacheCreated;

CREATE OR REPLACE TARGET ArtistModifierChangedRecord USING Global.DatabaseWriter ( 
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  ConnectionRetryPolicy: 'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__', 
  Password: '__TARGET_PWD__', 
  Password_encrypted: '__PWD_ENCRYPT__', 
  CheckPointTable: '__CHKPOINT__', 
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  CDDLAction: 'Process', 
  Username: '__TARGET_UNAME__', 
  StatementCacheSize: '__STMT_CACHE_SIZE__', 
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  adapterName: 'DatabaseWriter',
  Tables: '__SOURCE_DB__.dbo.Artist_Modifier,core.history_changed columnmap(
	reference_id=Artist_Modifier_id,
	table_name=\'artist_modifier\', 
	changed_date=Changed_Date,
	changed_by=@userdata(LoginName),
	change_comment=FormerValues)' 
  ) 
INPUT FROM LoginCacheChanged;

CREATE OR REPLACE TARGET artnet_ops_dim_H_L_LOAD_target_DE1 USING Global.DatabaseWriter(
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  Password: '__TARGET_PWD__',
  Password_encrypted: '__PWD_ENCRYPT__',
  CheckPointTable: '__CHKPOINT__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  CDDLAction: 'Process',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  adapterName: 'DatabaseWriter', 
  Tables:'__SOURCE_DB__.dbo.Artist_Modifier, core.translation columnmap(
          guid=NameGUID,
          text=Artist_modifier_name_de,
          language=\'DE\')'
)
INPUT FROM Source_dim_H_L_LOAD_OS;

CREATE OR REPLACE TARGET artnet_ops_dim_H_L_LOAD_target_FR1 USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=__CONN_RETRY_MAX_RT__',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  CDDLAction: 'Process',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Password: '__TARGET_PWD__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  adapterName: 'DatabaseWriter', 
  Tables:' __SOURCE_DB__.dbo.Artist_Modifier, core.translation columnmap(
                guid=NameGUID,
                text=Artist_modifier_name_fr,
                language=\'FR\')'
  )
INPUT FROM Source_dim_H_L_LOAD_OS;

CREATE OR REPLACE TARGET artnet_ops_dim_H_L_LOAD_target_EN1 USING Global.DatabaseWriter(
  ConnectionRetryPolicy:'retryInterval=__CONN_RETRY_INT__, maxRetries=3',
  CheckPointTable: '__CHKPOINT__',
  Password_encrypted: '__PWD_ENCRYPT__',
  CDDLAction: 'Process',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  Username: '__TARGET_UNAME__',
  StatementCacheSize: '__STMT_CACHE_SIZE__',
  CommitPolicy: 'EventCount:__COMMIT_EVNT_CNT__,Interval:__COMMIT_INTRVL__',
  Password: '__TARGET_PWD__',
  ConnectionURL: 'jdbc:__TARGET_DB_VEND__://__TARGET_IP_PORT__/OPS_Artnet?stringtype=unspecified',
  DatabaseProviderType: '__DATABASE_PROVIDER_TYPE__', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  adapterName: 'DatabaseWriter', 
  Tables:'
        __SOURCE_DB__.dbo.Artist_modifier, core.translation columnmap(
                guid=NameGUID,
                text=Artist_modifier_name_en,
                language=\'EN\')'
)
INPUT FROM Source_dim_H_L_LOAD_OS;



END APPLICATION bulk_H_3_LOAD;

