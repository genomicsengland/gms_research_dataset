select
    public.observation.uid,
    public.patient.patient_human_readable_stored_id as participant_id,
    public.observation.observation_effective_from,
    /* no data    ,o.observation_effective_to */
    code_concept.concept_code as code,
    code_concept.concept_display as code_description,
    value_code_concept.concept_code as value_code
from public.observation
left join public.patient on public.observation.patient_uid = public.patient.uid
left join
    public.concept as code_concept on
        code_concept.uid = public.observation.code_cid
left join
    public.concept as value_code_concept on
        value_code_concept.uid = public.observation.value_code_cid;
