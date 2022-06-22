select
    public.condition.uid,
    public.patient.patient_human_readable_stored_id as participant_id,
    /*no data    ,clinical_status_concept.concept_code as clinical_status */
    /*no data    ,verification_status_concept.concept_code
    as verification_status */
    /*no data    ,category_code_concept.concept_code as category_code */
    certainty_concept.concept_code as certainty,
    code_concept.concept_code as code,
    code_concept.concept_display as code_description
/*no data    ,body_site_code_concept.concept_code as body_site_code */
from public.condition
left join public.patient on public.condition.patient_uid = public.patient.uid
left join
    public.concept as clinical_status_concept on
        clinical_status_concept.uid = public.condition.clinical_status_cid
left join
    public.concept as verification_status_concept on
        verification_status_concept.uid
        = public.condition.verification_status_cid
left join
    public.concept as category_code_concept on
        category_code_concept.uid = public.condition.category_code_cid
left join
    public.concept as certainty_concept on
        certainty_concept.uid = public.condition.certainty_cid
left join
    public.concept as code_concept on
        code_concept.uid = public.condition.code_cid
left join
    public.concept as body_site_code_concept on
        body_site_code_concept.uid = public.condition.body_site_code_cid;
