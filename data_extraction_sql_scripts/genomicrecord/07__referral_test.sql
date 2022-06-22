select
    public.referral_test.uid,
    public.referral_test.referral_test_expected_number_of_patients
    as referral_test_expected_number_of_participants,
    /* irrelevant/unclear    ,rt.ci_test_type_uid */
    public.referral.referral_human_readable_stored_id as referral_id
/* no data    ,penetrance_concept.concept_code as penetrance */
/* no data    ,referral_test_medical_review_qc_state_concept.concept_code
as referral_test_medical_review_qc_state */
/* no data    ,status_concept.concept_code as status */
/* no data    ,rt.additional_data */
/* no data    ,rt.interpretation_lab_uid */
/* no data    ,rt.sample_processing_lab_uid */
from public.referral_test
left join
    public.referral on public.referral.uid = public.referral_test.referral_uid
left join
    public.concept as penetrance_concept on
        penetrance_concept.uid = public.referral_test.penetrance_cid
left join
    public.concept as referral_test_medical_review_qc_state_concept on
        referral_test_medical_review_qc_state_concept.uid
        = public.referral_test.referral_test_medical_review_qc_state_cid
left join
    public.concept as status_concept on status_concept.uid
        = public.referral_test.status_cid;
