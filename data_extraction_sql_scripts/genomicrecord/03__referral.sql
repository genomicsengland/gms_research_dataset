select
    r.uid
    ,r.referral_human_readable_stored_id as referral_id
/* no data    ,r.referral_occurrence_start */
/* no data    ,r.referral_is_prenatal_test */
/* no data    ,r.referral_expected_number_of_samples */
/* no data    ,r.parent_referral_uid */
    ,status_concept.concept_code as status
/* no data    ,intent_concept.concept_code as intent */
    ,priority_concept.concept_code as priority
    ,r.clinical_indication_uid
/* irrelevant    ,reason_declined_concept.concept_code as reason_declined */
    ,r.ordering_entity_uid
    ,r.tumour_uid
/* no data    ,r.additional_data */
/* poss PID    ,r.referral_notes */
from public.referral r
left join public.concept status_concept on status_concept.uid = r.status_cid
left join public.concept intent_concept on intent_concept.uid = r.intent_cid
left join public.concept priority_concept on priority_concept.uid = r.priority_cid
left join public.concept reason_declined_concept on reason_declined_concept.uid = r.reason_declined_cid
;
