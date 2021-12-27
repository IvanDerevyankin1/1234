with
 w_dict_region as
        (select *
           from table(PKG_KNB_SPRAV.GetSpravRgn(pLastDate => :vPeriodEnd, pShowClosed => 1))
         )

select
A.DT_BEG,
A.DT_END,
APN.DT,
A.CODE,
A.GU_ID,
apn.rgn,
apn.denm_id,
apn.processed_cnt,
apn.shred_cnt
from KNB_DWH.DICT_REGION_SPR a
join KNB_DWH.ag_processed_notes_cnt apn
  on apn.RGN=A.CODE and trunc(apn.DT) >=trunc(A.DT_BEG) and trunc(apn.DT)<=trunc(A.DT_END) 
left join KNB_DWH.dict_gu gu
  on a.gu_id = gu.id and gu.is_del = 0 
left join w_dict_region pbr 
  on pbr.code = apn.RGN   
--join KNB_DWH.w_dict_region dr  on dr.gu_id  = gu.id  
where A.IS_DEL=0   
  and A.CODE=7516
  and trunc(apn.DT) between trunc(:vPeriodBeg) and trunc(:vPeriodEnd)
  and 
  ( 
   trunc(A.DT_BEG) between trunc(:vPeriodBeg) and trunc(:vPeriodEnd)
    or
   trunc(A.DT_END) between trunc(:vPeriodBeg) and trunc(:vPeriodEnd)
  )
and a.gu_id = gu.id