select
    rt.uid
    ,rt.referral_test_expected_number_of_patients
/* irrelevant/unclear    ,rt.ci_test_type_uid */
    ,r.referral_human_readable_stored_id as referral_id
/* no data    ,penetrance_concept.concept_code as penetrance */
/* no data    ,referral_test_medical_review_qc_state_concept.concept_code as referral_test_medical_review_qc_state */
/* no data    ,status_concept.concept_code as status */
/* no data    ,rt.additional_data */
/* no data    ,rt.interpretation_lab_uid */
/* no data    ,rt.sample_processing_lab_uid */
from public.referral_test rt
left join public.referral r on r.uid = rt.referral_uid
left join public.concept penetrance_concept on penetrance_concept.uid = rt.penetrance_cid
left join public.concept referral_test_medical_review_qc_state_concept on referral_test_medical_review_qc_state_concept.uid = rt.referral_test_medical_review_qc_state_cid
left join public.concept status_concept on status_concept.uid = rt.status_cid
;
