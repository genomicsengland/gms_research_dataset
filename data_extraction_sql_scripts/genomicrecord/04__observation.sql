select
    o.uid
    ,p.patient_human_readable_stored_id as patient_id
    ,o.observation_effective_from
/* no data    ,o.observation_effective_to */
    ,code_concept.concept_code as code
    ,code_concept.concept_display as code_description
    ,value_code_concept.concept_code as value_code
from public.observation o
left join public.patient p on o.patient_uid = p.uid
left join public.concept code_concept on code_concept.uid = o.code_cid
left join public.concept value_code_concept on value_code_concept.uid = o.value_code_cid
;
