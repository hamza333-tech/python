
--

USE Migration;

--bulk_H_collab_lot_7
-- a_o.fact_H_lot_LOAD.tpl
-- a_o.link_H_artist_collaboration_LOAD.tpl


--  artist_collaboration
--  lot

STOP APPLICATION bulk_H_collab_lot_7_LOAD;
UNDEPLOY APPLICATION bulk_H_collab_lot_7_LOAD;
DROP APPLICATION bulk_H_collab_lot_7_LOAD CASCADE;
CREATE APPLICATION bulk_H_collab_lot_7_LOAD;


-- FILE_INPUT a_o.link_H_artist_collaboration_LOAD.tpl


CREATE OR REPLACE SOURCE SQL_DBSource_link_H_LOAD USING Global.DatabaseReader ( 
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
OUTPUT TO SQL_DBSource_link_H_LOAD_OutputStream;

CREATE OR REPLACE CQ CQ_ArtistCollaborationCreatedByLoad 
INSERT INTO LoginCacheArtistCollaborationCreatedBy 
SELECT putuserdata (s,'LoginName',U.login_name)
FROM SQL_DBSource_link_H_LOAD_OutputStream s
join UserList U
where to_int(s.data[4]) = U.id;

CREATE OR REPLACE CQ CQ_ArtistCollaborationChangedByLoad 
INSERT INTO LoginCacheArtistCollaborationChangedBy 
SELECT putuserdata (s,'LoginName',U.login_name)
FROM SQL_DBSource_link_H_LOAD_OutputStream s
join UserList U
where to_int(s.data[6]) = U.id;

CREATE OR REPLACE TARGET Target_link_H_ArtistCollaboration_LOAD USING Global.DatabaseWriter ( 
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
INPUT FROM  SQL_DBSource_link_H_LOAD_OutputStream;

CREATE OR REPLACE TARGET Target_link_H_ArtistCollaboration_LOAD_Created USING Global.DatabaseWriter (
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

CREATE OR REPLACE TARGET Target_link_H_ArtistCollaboration_LOAD_Changed USING Global.DatabaseWriter (
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


-- FILE_INPUT a_o.fact_H_lot_LOAD.tpl

CREATE OR REPLACE SOURCE SQL_DBSource_Fact_H USING Global.DatabaseReader ( 
  Password: '__SOURCE_PWD__',
  DatabaseProviderType: 'Default',
  DatabaseName: '__SOURCE_DB__', 
  FetchSize: __FETCH_SZ__,
  adapterName: 'DatabaseReader',
  QuiesceOnILCompletion: __QUIESCE_ON_IL_COMPLT__,
  Password_encrypted: '__PWD_ENCRYPT__',
  ConnectionURL: 'jdbc:sqlserver://__SOURCE_IP_PORT__;DatabaseName=__SOURCE_DB__',
  Username: '__SOURCE_UNAME__',
  Tables: '__SOURCE_DB__.dbo.Lot KeyColumns(Lot_id)'
)
OUTPUT TO SQL_DBSource_Fact_H_lot_OutputStream;


--
-- CQ = Continuous Query
--
-- Slightly tricky: Note we do N left outer joins here to get N translations of
-- LoginId to LoginName.
--

CREATE OR REPLACE CQ CQ_JOIN_USERS_lot_ChangedBy 
INSERT INTO LoginCache
SELECT putuserdata(s,'EnteredByUser',Q.login_name,'CreatedUser',R.login_name, 'ChangedUser', H.login_name)
FROM SQL_DBSource_Fact_H_lot_OutputStream s 
LEFT JOIN UserList Q on to_int(s.data[17]) = Q.id
LEFT JOIN UserList R on to_int(s.data[54]) = R.id
LEFT JOIN UserList H on to_int(s.data[56]) = H.id;


CREATE OR REPLACE TARGET SQL_Target_Fact_H_lot USING Global.DatabaseWriter ( 
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
  Tables: '__SOURCE_DB__.dbo.Lot,pdb.lot columnmap(
	 id=Lot_id
	,ahw_web_site=AH_WebSite
	,active_ind=Active_ind
	,catalog_lot_number=Catalog_lot_number
	,catalog_note=Catalog_Note
	,collection_id=Collection_id
	,counts=Counts
	,currency_id=Currency_id
	,est_hi=Est_hi
	,est_hi_usd=Est_hi_usd
	,est_lo=Est_lo
	,est_lo_usd=Est_lo_USD
	,featured_lot=FeaturedLot
	,gallery_id=Gallery_id
	,hyperlink_sale_of_field=hyperlink_sale_of_field
	,images_bit_mask=ImagesBitMask
	,internal_comment=internal_comment
	,last_image_upload=LastImageUpload
	,lot_number=Lot_number
	,non_partner=NonPartner
	,price_entered_by=@userdata(EnteredByUser)
	,price_entry_date=Price_entry_date
	,price_status_id=PriceStatus_id
	,price_phrase_id=PricePhrase_id
	,sale_price=Sale_price
	,sale_price_usd=Sale_price_usd
	,sale_title=Sale_title
	,sale_status_id=SaleStatus_id
	,show_in_member_site=Show_in_member_site
  )', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM LoginCache;
--INPUT FROM SQL_DBSource_Fact_H_lot_OutputStream;



--
-- GENERATE THE ARTWORK ROW
--


CREATE OR REPLACE TARGET SQL_Target_Fact_H_lot_artwork USING Global.DatabaseWriter ( 
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
  Tables: '__SOURCE_DB__.dbo.Lot, core.artwork columnmap(
	 lid=Lot_id
	,artist_id=Artist_id
	,artwork_name=Title
	,title_notes=Title_notes
	,work_year_from=Workyear_from
	,work_year_to=Workyear_to
	,height=Height
	,width=Width
	,depth=Depth
	,measurement_type=Unit
	,edition=Edition_info 
	,is_signed=signed 
	,is_stamped=stamped
	,medium_description=Medium           
	,artwork_count=Work_count
	,medium_notes=Medium_notes
	,artist_modifier_id=Artist_modifier_id
	,artist_maker=Artist_maker
	,work_year_from_modifier_id=From_year_modifier_id
	,provenance=provenance
	,exhibition=exhibition
	,literature=literature
	,catalog_note=Catalog_note
  )', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM SQL_DBSource_Fact_H_lot_OutputStream;
https://artnetwiki.atlassian.net/wiki/spaces/ART/pages/39026708/Striim+Task+List#Indexes-for-the-core.artwork_2_lot-and-core.artist_2_artwork-tables
-- Generate the EditionRow if any
--
CREATE OR REPLACE TARGET SQL_Target_Fact_H_lot_edition USING Global.DatabaseWriter ( 
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
  Tables: '__SOURCE_DB__.dbo.Lot,core.edition columnmap(
	 lid=Lot_id
	,width=Width
	,height=Height
	,depth=Depth
	,units=Unit
	,impression_year_from=Impression_year_from
	,impression_year_to=Impression_year_to
	,imp_year_modifier_id=Impression_year_from
	,plate_signed=PlateSigned
	,foundry=Foundry
  )', 
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__', 
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__', 
  adapterName: 'DatabaseWriter' ) 
INPUT FROM LoginCache;
--INPUT FROM SQL_DBSource_Fact_H_lot_OutputStream;



CREATE OR REPLACE TARGET CreatedRecordLot USING Global.DatabaseWriter (
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
  Tables: '__SOURCE_DB__.dbo.Lot,core.history_created columnmap(
        reference_id=Lot_id,
        table_name=\'lot\',
	created_by=@userdata(CreatedUser),
	created_date=Created_Date)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter' )
INPUT FROM LoginCache;


CREATE OR REPLACE TARGET ChangedRecordLot USING Global.DatabaseWriter (
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
  Tables: '__SOURCE_DB__.dbo.Lot,core.history_changed columnmap(
        reference_id=Lot_id,
        table_name=\'lot\',
	changed_by=@userdata(ChangedUser),
	changed_date=Changed_Date,
        change_comment=FormerValues)',
  PreserveSourceTransactionBoundary: '__PRSV_SRC_TRANS_BND__',
  BatchPolicy: 'EventCount:__BATCH_EVNT_CNT__,Interval:__BATCH_INTRVL__',
  adapterName: 'DatabaseWriter')
INPUT FROM LoginCache;


END APPLICATION bulk_H_collab_lot_7_LOAD;

