select
    public.referral.uid,
    public.referral.referral_human_readable_stored_id as referral_id,
    /* no data    ,r.referral_occurrence_start */
    /* no data    ,r.referral_is_prenatal_test */
    /* no data    ,r.referral_expected_number_of_samples */
    /* no data    ,r.parent_referral_uid */
    status_concept.concept_code as status,
    /* no data    ,intent_concept.concept_code as intent */
    priority_concept.concept_code as priority,
    public.referral.clinical_indication_uid,
    /* irrelevant    ,reason_declined_concept.concept_code as reason_declined */
    public.referral.ordering_entity_uid,
    public.referral.referral_date_submitted as date_submitted,
    public.referral.tumour_uid
/* no data    ,r.additional_data */
/* poss PID    ,r.referral_notes */
from public.referral
left join
    public.concept as status_concept on
        status_concept.uid = public.referral.status_cid
left join
    public.concept as intent_concept on
        intent_concept.uid = public.referral.intent_cid
left join
    public.concept as priority_concept on
        priority_concept.uid = public.referral.priority_cid
left join public.concept as reason_declined_concept on
    reason_declined_concept.uid = public.referral.reason_declined_cid;
