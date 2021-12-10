select
    rs.uid
    ,rs.sample_uid
    ,r.referral_human_readable_stored_id as referral_id
from public.referral_sample rs
left join public.referral r on r.uid = rs.referral_uid
;
