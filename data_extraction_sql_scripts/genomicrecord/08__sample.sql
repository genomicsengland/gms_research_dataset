select
    s.uid
/* no data    ,body_site_concept.concept_code as body_site */
/* unclear    ,s.other_referral_request_uid */
/* no data    ,s.parent_uid */
    ,p.patient_human_readable_stored_id as patient_id
    ,s.percentage_of_malignant_cells
    ,sample_morphology_concept.concept_code as sample_morphology
/* no data    ,s.sample_number_of_slides */
/* no data    ,s.sample_ready_for_dispatch */
/* no data    ,s.sample_requested_for_other_test */
/* no data    ,sample_shipping_status_concept.concept_code as sample_shipping_status */
/* better data available in biobank    ,sample_state_concept.concept_code as sample_state */
    ,sample_topography_concept.concept_code as sample_topography
/* better data available in biobank    ,sample_type_concept.concept_code as sample_type */
    ,s.tumour_uid
/* no data    ,s.additional_data */
    ,s.sample_collection_date
/* poss PID    ,s.sample_notes */
    ,i.value as sample_id_glh
from public.sample s
left join public.concept body_site_concept on body_site_concept.uid = s.body_site_cid
left join public.patient p on p.uid = s.patient_uid
left join public.concept sample_morphology_concept on sample_morphology_concept.uid = s.sample_morphology_cid
left join public.concept sample_shipping_status_concept on sample_shipping_status_concept.uid = s.sample_shipping_status_cid
left join public.concept sample_state_concept on sample_state_concept.uid = s.sample_state_cid
left join public.concept sample_topography_concept on sample_topography_concept.uid = s.sample_topography_cid
left join public.concept sample_type_concept on sample_type_concept.uid = s.sample_type_cid
left join public.identifier i on i.sample_uid = s.uid
;
