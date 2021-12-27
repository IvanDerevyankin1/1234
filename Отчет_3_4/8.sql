select
a.gu_id
from
(
select trim(w_gu.gu_id) as gu_id
            from (
                select replace(regexp_substr(:pGUs, '[^,]*(,|$)',1,level),',') gu_id
                   from dual
                   connect by regexp_substr(:pGUs, '[^,]*(,|$)',1,level) is not null 
                     )w_gu
)a
union
select
'102' gu_id
from dual   
;




with
    w_dict_region as
      (
        select 
            a.id,                                        
            a.code,                                           
            a.code_str,      
            a.nm,           
            a.gu_id,             
            a.shred,            
            a.ssm_cnt,           
            a.arm_chk_cnt,        
            a.bic ,
            A.DT_BEG,
            A.DT_END        
        from dict_region_spr a
        where a.is_del = 0
           and
           (A.DT_END > nvl(:vPeriodBeg, to_date('01.09.2012', 'dd.mm.yyyy')) and A.DT_END <= nvl(:vPeriodEnd, trunc(sysdate) - 1)
             or
            A.DT_BEG between nvl(:vPeriodBeg, to_date('01.09.2012', 'dd.mm.yyyy')) and nvl(:vPeriodEnd, trunc(sysdate) - 1)
           )
        ), 

     w_idx as 
          (
          (select trim(w_idx.index_id) as index_id
                from (
                       select replace(regexp_substr(:pIndices, '[^,]*(,|$)',1,level),',') index_id
                         from dual
                       connect by regexp_substr(:pIndices, '[^,]*(,|$)',1,level) is not null 
                     ) w_idx
            )
      union
        (
         select
          to_char(a.gu_id)
         from w_dict_region a        
        )      
                          