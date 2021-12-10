select
    rp.uid
    ,r.referral_human_readable_stored_id as referral_id
    ,p.patient_human_readable_stored_id as patient_id
    ,rp.referral_participant_is_proband
/* no data    ,rp.additional_data */
/* no data    ,consanguinity_concept.concept_code as consanguinity */
    ,disease_status_concept.concept_code as disease_status
/* no data    ,father_affected_concept.concept_code as father_affected */
/* no data    ,mother_affected_concept.concept_code as mother_affected */
    ,rp.referral_participant_age_at_onset
/* no data    ,rp.referral_participant_full_brother_count */
/* no data    ,rp.referral_participant_full_brothers_affected */
/* no data    ,rp.referral_participant_full_sister_count */
/* no data    ,rp.referral_participant_full_sisters_affected */
/* no data    ,rp.referral_participant_other_relationship_details */
    ,relationship_to_proband_concept.concept_code as relationship_to_proband
from public.referral_participant rp
left join public.referral r on rp.referral_uid = r.uid
left join public.patient p on rp.patient_uid = p.uid
left join public.concept consanguinity_concept on consanguinity_concept.uid = rp.consanguinity_cid
left join public.concept disease_status_concept on disease_status_concept.uid = rp.disease_status_cid
left join public.concept father_affected_concept on father_affected_concept.uid = rp.father_affected_cid
left join public.concept mother_affected_concept on mother_affected_concept.uid = rp.mother_affected_cid
left join public.concept relationship_to_proband_concept on relationship_to_proband_concept.uid = rp.relationship_to_proband_cid
;
