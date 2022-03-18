-- drop all the views
drop view vw_condition cascade;
drop view vw_eligible_patient cascade;
drop view vw_eligible_referral cascade;
drop view vw_observation cascade;
drop view vw_observation_component cascade;
drop view vw_patient cascade;
drop view vw_patient_list cascade;
drop view vw_plated_sample cascade;
drop view vw_referral cascade;
drop view vw_referral_participant cascade;
drop view vw_referral_sample cascade;
drop view vw_referral_test cascade;
drop view vw_sample cascade;
drop view vw_tumour cascade;
drop view vw_tumour_morphology cascade;
drop view vw_tumour_topography cascade;

-- drop functions
drop function encrypt_id;
drop function decrypt_id;

-- drop tables
drop table clinical_indication cascade;
drop table condition cascade;
drop table consent cascade;
drop table laboratory_sample cascade;
drop table encryption_seed cascade;
drop table observation cascade;
drop table observation_component cascade;
drop table ordering_entity cascade;
drop table patient cascade;
drop table referral cascade;
drop table referral_participant cascade;
drop table referral_sample cascade;
drop table referral_test cascade;
drop table sample cascade;
drop table tumour cascade;
drop table tumour_morphology cascade;
drop table tumour_topography cascade;
drop table plated_sample cascade;
drop table plated_sample_qc cascade;
drop table release cascade;
drop table closed_referral cascade;
