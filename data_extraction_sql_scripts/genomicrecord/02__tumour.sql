select
    public.tumour.uid,
    public.patient.patient_human_readable_stored_id as participant_id,
    tumour_type_concept.concept_code as tumour_type,
    /* no data    ,grade_concept.concept_code as grade */
    /* no data    ,t.parent_tumour_uid */
    presentation_concept.concept_code as presentation,
    /* no data    ,prognostic_score_concept.concept_code as prognostic_score */
    /* no data    ,stage_concept.concept_code as stage */
    /* no data    ,t.additional_data */
    /* irrelevant    ,t.clinician_uid */
    /* irrelevant    ,t.organisation_uid */
    public.tumour.tumour_diagnosis_day,
    public.tumour.tumour_diagnosis_month,
    public.tumour.tumour_diagnosis_year
/* no data    ,t.diagnosis_age_in_years */
from public.tumour
left join public.patient on public.tumour.patient_uid = public.patient.uid
left join
    public.concept as tumour_type_concept on
        tumour_type_concept.uid = public.tumour._type_cid
left join
    public.concept as grade_concept on
        grade_concept.uid = public.tumour.grade_cid
left join
    public.concept as presentation_concept on
        presentation_concept.uid = public.tumour.presentation_cid
left join
    public.concept as prognostic_score_concept on
        prognostic_score_concept.uid = public.tumour.prognostic_score_cid
left join public.concept as stage_concept
    on stage_concept.uid = public.tumour.stage_cid;
