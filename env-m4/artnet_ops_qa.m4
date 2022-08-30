divert(-1)
# WILL THIS SHOW UP IN THE OUTPUT
divert(0)

define(__AUTO_DISABLE_TBL_CDC__,false)dnl
define(__BATCH_INTRVL_A__, Interval:30) dnl
define(__BATCH_EVNT_CNT_A__, EventCount:1000) dnl
define(__BATCH_POLICY__, `__BATCH_INTRVL_A__, __BATCH_EVNT_CNT_A__') dnl
define(__BATCH_POLICY__, -1)dnl
define(__BATCH_INTRVL__,2)dnl
define(__BATCH_EVNT_CNT__,2)dnl
define(__CHKPOINT__,CHKPOINT)dnl
define(__COMMIT_INTRVL_A__,Interval:30)dnl
define(__COMMIT_EVNT_CNT_A__,EventCount:1000)dnl
define(__COMMIT_POLICY__, `__COMMIT_EVNT_CNT_A__, __COMMIT_INTRVL_A__')dnl
define(__COMMIT_POLICY__, -1)dnl
define(__COMMIT_INTRVL__,2)dnl
define(__COMMIT_EVNT_CNT__,2)dnl
define(__COMPRN__,false)dnl
define(__CONNECT_POOL_SZ__,true)dnl
define(__CONN_RETRY_TO__,30)dnl
define(__CONN_RETRY_INT__,30)dnl
define(__CONN_RETRY_MAX_RT__,3)dnl
define(__FETCH_SZ__,4)dnl
define(__EXTERN_FETCH_SZ__,1)dnl
define(__FLTR_TRANS_BNDRS__,true)dnl
define(__FETCH_TX_META__,false)dnl
define(__INTEG_SEC__,false)dnl
define(__LSN__,EOF)dnl
define(__PRSV_SRC_TRANS_BND__,false)dnl
define(__PWD_ENCRYPT__,true)dnl
define(__QUIESCE_ON_IL_COMPLT__,false)dnl
define(__REFRESH_INTERVAL__,6 HOUR)dnl
define(__SEND_BEFORE_IMAGE__, true)dnl
define(__SKIP_INVALID__,false)dnl
define(__SOURCE_DB__,Artnet)dnl
define(__SOURCE_IP_PORT__,172.25.9.6:1433)dnl
define(__SOURCE_PWD__, mjCqrP8OsS0Jh+oxmr2JKw==)dnl
define(__SOURCE_UNAME__,striim)dnl
define(__STMT_CACHE_SIZE__,50)dnl
define(__TARGET_DB__,Ops_Artnet)dnl
define(__TARGET_IP_PORT__, 172.25.9.6:1433)dnl
define(__TARGET_PWD__, mjCqrP8OsS0Jh+oxmr2JKw==)dnl
define(__TARGET_UNAME__,striim)dnl
define(__TRNS_SUPPORT__,true)dnl
