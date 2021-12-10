select
    c.uid
    ,p.patient_human_readable_stored_id as patient_id
/*no data    ,clinical_status_concept.concept_code as clinical_status */
/*no data    ,verification_status_concept.concept_code as verification_status */
/*no data    ,category_code_concept.concept_code as category_code */
    ,certainty_concept.concept_code as certainty
    ,code_concept.concept_code as code
    ,code_concept.concept_display as code_description
/*no data    ,body_site_code_concept.concept_code as body_site_code */
from public.condition c
left join public.patient p on c.patient_uid = p.uid
left join public.concept clinical_status_concept on clinical_status_concept.uid = c.clinical_status_cid
left join public.concept verification_status_concept on verification_status_concept.uid = c.verification_status_cid
left join public.concept category_code_concept on category_code_concept.uid = c.category_code_cid
left join public.concept certainty_concept on certainty_concept.uid = c.certainty_cid
left join public.concept code_concept on code_concept.uid = c.code_cid
left join public.concept body_site_code_concept on body_site_code_concept.uid = c.body_site_code_cid
;
