select
    public.referral_participant.uid,
    public.referral.referral_human_readable_stored_id as referral_id,
    public.patient.patient_human_readable_stored_id as participant_id,
    public.referral_participant.referral_participant_is_proband,
    /* no data    ,rp.additional_data */
    /* no data    ,consanguinity_concept.concept_code as consanguinity */
    disease_status_concept.concept_code as disease_status,
    /* no data    ,father_affected_concept.concept_code as father_affected */
    /* no data    ,mother_affected_concept.concept_code as mother_affected */
    public.referral_participant.referral_participant_age_at_onset,
    /* no data    ,rp.referral_participant_full_brother_count */
    /* no data    ,rp.referral_participant_full_brothers_affected */
    /* no data    ,rp.referral_participant_full_sister_count */
    /* no data    ,rp.referral_participant_full_sisters_affected */
    /* no data    ,rp.referral_participant_other_relationship_details */
    relationship_to_proband_concept.concept_code as relationship_to_proband
from public.referral_participant
left join
    public.referral on
        public.referral_participant.referral_uid = public.referral.uid
left join
    public.patient on
        public.referral_participant.patient_uid = public.patient.uid
left join
    public.concept as consanguinity_concept on
        consanguinity_concept.uid
        = public.referral_participant.consanguinity_cid
left join
    public.concept as disease_status_concept on
        disease_status_concept.uid
        = public.referral_participant.disease_status_cid
left join
    public.concept as father_affected_concept on
        father_affected_concept.uid
        = public.referral_participant.father_affected_cid
left join
    public.concept as mother_affected_concept on
        mother_affected_concept.uid
        = public.referral_participant.mother_affected_cid
left join
    public.concept as relationship_to_proband_concept on
        relationship_to_proband_concept.uid
        = public.referral_participant.relationship_to_proband_cid;
