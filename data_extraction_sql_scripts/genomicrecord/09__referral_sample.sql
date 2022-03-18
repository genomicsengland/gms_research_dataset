select
    public.referral_sample.uid,
    public.referral_sample.sample_uid,
    public.referral.referral_human_readable_stored_id as referral_id
from public.referral_sample
left join
    public.referral
    on public.referral.uid = public.referral_sample.referral_uid;
