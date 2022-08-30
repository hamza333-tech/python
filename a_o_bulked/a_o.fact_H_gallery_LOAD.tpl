
--
-- Tables that have change-history but not language translation. Incomplete set includes so far:
-- core.ArtworkType
--
-- This application creates a cache of Type_UserList rows that map LoginID to LoginName 
-- and subs in LoginNames where LoginValues are used in the tables.
-- It also has language translations that are moved out to the Translation table.
-- 
-- core.Gallery
--

USE Migration;

STOP APPLICATION a_o_Fact_H_gallery_LOAD;
UNDEPLOY APPLICATION a_o_Fact_H_gallery_LOAD;
DROP APPLICATION a_o_Fact_H_gallery_LOAD CASCADE;
CREATE APPLICATION a_o_Fact_H_gallery_LOAD;

CREATE OR REPLACE SOURCE SQL_DBSource_fact_gallery_ USING Global.DatabaseReader ( 
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


--
-- CQ = Continuous Query
--
-- Slightly tricky: Note we do two left outer joins here to get multiple translations of
-- LoginId to LoginName.
--

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

CREATE OR REPLACE TARGET CreatedRecord_gallery_Load USING Global.DatabaseWriter (
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


CREATE OR REPLACE TARGET ChangedRecord_gallery_Load USING Global.DatabaseWriter (
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

END APPLICATION a_o_Fact_H_gallery_LOAD;

