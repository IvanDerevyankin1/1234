with
 w_dict_region as
        (select *
         from table(PKG_KNB_SPRAV.GetSpravRgn(pLastDate => :vPeriodEnd, pShowClosed => 1))
        ),
                
 w_idx as (select trim(w_idx.index_id) as index_id
                from (
                       select replace(regexp_substr(:pIndices, '[^,]*(,|$)',1,level),',') index_id
                         from dual
                       connect by regexp_substr(:pIndices, '[^,]*(,|$)',1,level) is not null 
                     ) w_idx
            ),
            
 w_idx_show as 
            (            
                select count(1) as cnt
                  from dual
                 where exists (
                   select *
                     from dict_index di
                     left join w_idx
                       on w_idx.index_id = di.index_id
                    where di.is_del = 0
                      and w_idx.index_id is null
                 ))     
select
                               gu.nm gu,
                               gu.id gu_ord,
                               (case 
                                    when :pTUs = '-100'
                                       then to_char(null) 
                                       else dr.nm
                               end) as tu,
                               dd.nominal,
                               apn.index_id,
                               sum(apn.processed_cnt) processed_cnt,
                               sum(apn.shred_cnt) shred_cnt
from
(
select
APN.DT,
A.CODE,
A.GU_ID,
apn.rgn,
apn.denm_id,
apn.processed_cnt,
apn.shred_cnt,
                                     case widx.cnt
                                             when 0 then to_char(null) 
                                             when 1 then apn.index_id
                                     end as index_id
from KNB_DWH.DICT_REGION_SPR a
join KNB_DWH.ag_processed_notes_cnt apn
  on apn.RGN=A.CODE and trunc(apn.DT) >=trunc(A.DT_BEG) and trunc(apn.DT)<=trunc(A.DT_END) 
left join KNB_DWH.dict_gu gu
  on a.gu_id = gu.id and gu.is_del = 0 
left join w_dict_region pbr 
  on pbr.code = apn.RGN   
cross join w_idx_show widx  
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

union all

select
APN.DT,
A.CODE,
A.GU_ID,
apn.rgn,
apn.denm_id,
apn.processed_cnt,
apn.shred_cnt,
                                     case widx.cnt
                                             when 0 then to_char(null) 
                                             when 1 then apn.index_id
                                     end as index_id
from KNB_DWH.DICT_REGION_SPR a
join KNB_DWH.ag_processed_notes_cnt_cumul apn
  on apn.RGN=A.CODE and trunc(apn.DT) >=trunc(A.DT_BEG) and trunc(apn.DT)<=trunc(A.DT_END) 
left join KNB_DWH.dict_gu gu
  on a.gu_id = gu.id and gu.is_del = 0 
left join w_dict_region pbr 
  on pbr.code = apn.RGN  
cross join w_idx_show widx   
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
)apn,
dict_denominal dd,
w_dict_region dr,
dict_gu gu
where apn.denm_id = dd.id
-- and dd.is_correct = 1
  and dd.is_del = 0
  and apn.rgn = dr.code
  and dr.gu_id = gu.id
  and apn.gu_id = gu.id
  and gu.is_del = 0
group by gu.nm,
         gu.id,
                                  case 
                                    when :pTUs = '-100'
                                    then to_char(null) 
                                    else dr.nm
                                  end,
                                  dd.nominal,
                                  apn.index_id 
