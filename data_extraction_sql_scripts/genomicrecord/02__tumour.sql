select
    t.uid
    ,p.patient_human_readable_stored_id as patient_id
    ,tumour_type_concept.concept_code as tumour_type
/* no data    ,grade_concept.concept_code as grade */
/* no data    ,t.parent_tumour_uid */
    ,presentation_concept.concept_code as presentation
/* no data    ,prognostic_score_concept.concept_code as prognostic_score */
/* no data    ,stage_concept.concept_code as stage */
/* no data    ,t.additional_data */
/* irrelevant    ,t.clinician_uid */
/* irrelevant    ,t.organisation_uid */
    ,t.tumour_diagnosis_day
    ,t.tumour_diagnosis_month
    ,t.tumour_diagnosis_year
/* no data    ,t.diagnosis_age_in_years */
from public.tumour t
left join public.patient p on t.patient_uid = p.uid
left join public.concept tumour_type_concept on tumour_type_concept.uid = t._type_cid
left join public.concept grade_concept on grade_concept.uid = t.grade_cid
left join public.concept presentation_concept on presentation_concept.uid = t.presentation_cid
left join public.concept prognostic_score_concept on prognostic_score_concept.uid = t.prognostic_score_cid
left join public.concept stage_concept on stage_concept.uid = t.stage_cid
;
