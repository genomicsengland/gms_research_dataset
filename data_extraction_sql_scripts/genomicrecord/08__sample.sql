select
    public.sample.uid,
    /* no data    ,body_site_concept.concept_code as body_site */
    /* unclear    ,s.other_referral_request_uid */
    /* no data    ,s.parent_uid */
    public.patient.patient_human_readable_stored_id as participant_id,
    public.sample.percentage_of_malignant_cells,
    sample_morphology_concept.concept_code as sample_morphology,
    /* no data    ,s.sample_number_of_slides */
    /* no data    ,s.sample_ready_for_dispatch */
    /* no data    ,s.sample_requested_for_other_test */
    /* no data    ,sample_shipping_status_concept.concept_code
    as sample_shipping_status */
    /* better data available in biobank    ,sample_state_concept.concept_code
    as sample_state */
    sample_topography_concept.concept_code as sample_topography,
    /* better data available in biobank    ,sample_type_concept.concept_code
    as sample_type */
    public.sample.tumour_uid,
    /* no data    ,s.additional_data */
    public.sample.sample_collection_date,
    /* poss PID    ,s.sample_notes */
    public.identifier.value as sample_id_glh
from public.sample
left join
    public.concept as body_site_concept on
        body_site_concept.uid = public.sample.body_site_cid
left join public.patient on public.patient.uid = public.sample.patient_uid
left join
    public.concept as sample_morphology_concept on
        sample_morphology_concept.uid = public.sample.sample_morphology_cid
left join
    public.concept as sample_shipping_status_concept on
        sample_shipping_status_concept.uid
        = public.sample.sample_shipping_status_cid
left join
    public.concept as sample_state_concept on
        sample_state_concept.uid = public.sample.sample_state_cid
left join
    public.concept as sample_topography_concept on
        sample_topography_concept.uid = public.sample.sample_topography_cid
left join
    public.concept as sample_type_concept on
        sample_type_concept.uid = public.sample.sample_type_cid
left join
    public.identifier on
        public.identifier.sample_uid = public.sample.uid;
