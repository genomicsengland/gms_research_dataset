-- drop all the views
drop view vw_condition;
drop view vw_observation;
drop view vw_observation_component;
drop view vw_patient;
drop view vw_referral;
drop view vw_referral_participant;
drop view vw_referral_sample;
drop view vw_referral_test;
drop view vw_sample;
drop view vw_tumour;
drop view vw_tumour_morphology;
drop view vw_tumour_topography;

-- drop functions
drop function obfuscate_id;
drop function reverse_obfuscate_id;

-- drop tables
drop table clinical_indication cascade;
drop table condition cascade;
drop table consent cascade;
drop table obfuscation_seed cascade;
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
drop table laboratory_sample cascade;
drop table plated_sample cascade;
drop table plated_sample_qc cascade;
