--EXEC sp_updatestats; 

ALTER INDEX [IX_GroupDetails_dta_K3] ON [dbo].[GroupDetails] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 
ALTER INDEX [IX_GroupDetails_Group] ON [dbo].[GroupDetails] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 
ALTER INDEX [IX_GroupDetails_Group_Item] ON [dbo].[GroupDetails] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 

ALTER INDEX [ind_Item_Assort_Num_Name] ON [dbo].[Item] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 



ALTER INDEX [IX_Item_dta_K2D_K3_K1_K10] ON [dbo].[Item] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 
ALTER INDEX [IX_Item_Name] ON [dbo].[Item] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 
ALTER INDEX [IX_Item_Number_Name] ON [dbo].[Item] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 
ALTER INDEX [IX_Item_SortVVNumberBECID_w_AssortmentIDID] ON [dbo].[Item] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 
ALTER INDEX [PK_Item] ON [dbo].[Item] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 
ALTER INDEX [PK_ItemQuantityProperty] ON [dbo].[ItemQuantityProperty] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 

ALTER INDEX [UI_vv_ItemsGroupType] ON [dbo].[vv_ItemsGroupType] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 
ALTER INDEX [UK_dbo.MetaColumn_TableID_Name] ON [dbo].[MetaColumn] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 
ALTER INDEX [UK_Group_GroupType_BEC_Code] ON [dbo].[Group] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 
ALTER INDEX [UK_ItemDefaultProperties] ON [dbo].[ItemDefaultProperties] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 

ALTER INDEX [IX_InternalPrice_BeCdVVfVt_incl_PT] ON [dbo].[InternalPrice] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 
ALTER INDEX [IX_InternalPrice_BeIdPtIdVfVt_incl_CDIdCurrVPId] ON [dbo].[InternalPrice] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 
ALTER INDEX [IX_InternalPrice_BEPTVfVt_w_CdCurVId] ON [dbo].[InternalPrice] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 
ALTER INDEX [IX_InternalPrice_BEVfVt_w_CdPtV] ON [dbo].[InternalPrice] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 
ALTER INDEX [IX_InternalPrice_ID] ON [dbo].[InternalPrice] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 
ALTER INDEX [IX_InternalPrice_PT_w_BECdCur] ON [dbo].[InternalPrice] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 
ALTER INDEX [PK_InternalPrice] ON [dbo].[InternalPrice] REBUILD WITH (ONLINE = ON, MAXDOP = 1); 