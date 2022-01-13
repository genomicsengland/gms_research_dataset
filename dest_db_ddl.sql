-- need to enable extension to be able to use guids
create extension if not exists "uuid-ossp";

-- reference tables
create table clinical_indication (
    uid uuid,
    clinical_indication_code varchar,
    clinical_indication_full_name varchar,
    primary key (uid)
);
comment on table clinical_indication is 'Reference table providing clinical indication codes and names.';

create table ordering_entity (
    uid uuid,
    ordering_entity_name varchar,
    ordering_entity_code varchar,
    primary key (uid)
);
comment on table ordering_entity is 'Reference table providing organisation/ordering entity names and codes.';

-- main tables
create table patient (
    uid uuid,
    patient_id varchar unique not null,
    patient_date_of_birth date,
    patient_year_of_death int,
    patient_is_foetal_patient bool,
    administrative_gender varchar,
    ethnicity varchar,
    ethnicity_description varchar,
    life_status varchar,
    karyotypic_sex varchar,
    phenotypic_sex varchar,
    primary key (uid)
);
comment on table patient is 'Provides patient personal and demographic data.';

create table tumour (
    uid uuid,
    patient_id varchar,
    tumour_type varchar,
    presentation varchar,
    tumour_diagnosis_day int,
    tumour_diagnosis_month int,
    tumour_diagnosis_year int,
    primary key (uid),
    foreign key (patient_id) references patient (patient_id)
);
comment on table tumour is 'Provides data on a patient''s tumour.';

create table referral (
    uid uuid,
    referral_id varchar unique not null,
    status varchar,
    intent varchar,
    priority varchar,
    clinical_indication_uid uuid,
    ordering_entity_uid uuid,
    tumour_uid uuid,
    primary key (uid),
    foreign key (tumour_uid) references tumour (uid),
    foreign key (clinical_indication_uid) references clinical_indication (uid),
    foreign key (ordering_entity_uid) references ordering_entity (uid)
);
comment on table referral is 'Provides data on the overall referral request for tests.';

create table condition (
    uid uuid,
    patient_id varchar not null,
    certainty varchar,
    code varchar,
    code_description varchar,
    primary key (uid),
    foreign key (patient_id) references patient (patient_id)
);
comment on table condition is 'Provides data on patient''s condition (clinical problem or diagnosis).';

create table observation (
    uid uuid,
    patient_id varchar not null,
    observation_effective_from date,
    code varchar,
    code_description varchar,
    value_code varchar,
    primary key (uid),
    foreign key (patient_id) references patient (patient_id)
);
comment on table observation is 'Provides simple measurements and findings on a patient.';

create table observation_component (
    uid uuid,
    observation_uid uuid,
    observation_component_code varchar,
    observation_component_code_description varchar,
    observation_component_value varchar,
    primary key (uid),
    foreign key (observation_uid) references observation (uid)
);
comment on table observation_component is 'Adds further information/modifiers to a given observation.';

create table referral_participant (
    uid uuid,
    referral_id varchar,
    patient_id varchar,
    referral_participant_is_proband bool,
    disease_status varchar,
    referral_participant_age_at_onset int,
    relationship_to_proband varchar,
    primary key (uid),
    foreign key (patient_id) references patient (patient_id),
    foreign key (referral_id) references referral (referral_id)
);
comment on table referral_participant is 'Assigns patients to a given referral, and provides data relevant to their role in that referral.';

create table referral_test (
    uid uuid,
    referral_test_expected_number_of_patients int,
    referral_id varchar,
    primary key (uid),
    foreign key (referral_id) references referral (referral_id)
);
comment on table referral_test is 'Provides details on the individual tests within a referral.';

create table sample (
    uid uuid,
    patient_id varchar,
    percentage_of_malignant_cells int,
    sample_morphology varchar,
    sample_state varchar,
    sample_topography varchar,
    sample_type varchar,
    tumour_uid uuid,
    sample_collection_date date,
    primary key (uid),
    foreign key (patient_id) references patient (patient_id),
    foreign key (tumour_uid) references tumour (uid)
);
comment on table sample is 'Provides data on the different samples collected from patients.';

create table referral_sample (
    uid uuid,
    sample_uid uuid,
    referral_id varchar,
    primary key (uid),
    foreign key (referral_id) references referral (referral_id),
    foreign key (sample_uid ) references sample (uid)
);
comment on table referral_sample is 'Assigns samples to a given referral.';

create table tumour_morphology (
    uid uuid,
    tumour_uid uuid,
    morphology varchar,
    primary key (uid),
    foreign key (tumour_uid) references tumour (uid)
);
comment on table tumour_morphology is 'Provides SNOMED morphology codes for a tumour.';

create table tumour_topography (
    uid uuid,
    tumour_uid uuid,
    actual_body_site varchar,
    actual_body_site_description varchar,
    primary_body_site varchar,
    primary_body_site_description varchar,
    primary key (uid),
    foreign key (tumour_uid) references tumour (uid)
);
comment on table tumour_topography is 'Provide SNOMED topography codes for the actual or primary body site of a tumour.';

create table consent (
    patient_uid uuid,
    referral_uid uuid,
    consent_questionnaire_response_uid uuid,
    consent_uid uuid,
    consent_form varchar,
    status varchar,
    research_answer_given varchar,
    recency int,
    last_updated timestamp,
    primary key (consent_questionnaire_response_uid),
    foreign key (patient_uid) references patient (uid),
    foreign key (referral_uid) references referral (uid)
);
comment on table consent is 'Reference table for consent data used for generation of participant list';

-- generate random seed number for ID obfuscation
-- patient and referral IDs are 11 digits long, so make seed that long also
create table obfuscation_seed (
    seed bigint
);
insert into obfuscation_seed (seed)
select floor(random() * (99999999999 - 10000000000 + 1) + 10000000000);

-- function for ID obfuscation
create function obfuscate_id (
    orig_id varchar, -- the ID to be obfuscated
    orig_prefix varchar, -- the prefix that is used for that type of ID
    return_prefix varchar -- the prefix for the returned, obfuscated ID
)
    returns varchar as
$$
declare
    s obfuscation_seed.seed%type; -- copy type from the seed
begin
    -- get seed into function variable
    select seed
    from obfuscation_seed
    into s;
    -- obfuscate the ID:
    -- remove the prefix, then reverse the number and do xor with the seed
    -- convert back to bigint and add new prefix
    return return_prefix || (
        reverse(
            regexp_replace(orig_id, '^' || orig_prefix, '')
        )::bigint::bit(64)
        # s::bit(64)
    )::bigint::varchar;
end;
$$
language plpgsql;
create function reverse_obfuscate_id (
    orig_id varchar, -- the ID to be reverse_obfuscated
    orig_prefix varchar, -- the prefix that is used for that type of ID
    return_prefix varchar -- the prefix for the returned, obfuscated ID
)
    returns varchar as
$$
declare
    s obfuscation_seed.seed%type; -- copy type from the seed
begin
    -- get seed into function variable
    select seed
    from obfuscation_seed
    into s;
    -- reverse obfuscate the ID:
    -- remove the prefix, do xor with the seed 
    -- convert back to bigint then varchar, reverse it and add new prefix
    return return_prefix || 
        reverse(
            (regexp_replace(orig_id, '^' || orig_prefix, '')
        ::bigint::bit(64)
        # s::bit(64))
    ::bigint::varchar);
end;
$$
language plpgsql;

-- final views of data to be exported
create view vw_condition as
select obfuscate_id(c.patient_id, 'p', 'pp') as patient_id
    ,c.uid
    ,c.certainty
    ,c.code
    ,c.code_description
from condition c
;
create view vw_observation as
select obfuscate_id(o.patient_id, 'p', 'pp') as patient_id
    ,o.uid
    ,o.observation_effective_from
    ,o.code
    ,o.code_description
    ,o.value_code
from observation o
;
create view vw_observation_component as
select oc.uid
    ,oc.observation_uid
    ,oc.observation_component_code
    ,oc.observation_component_code_description
    ,oc.observation_component_value
from observation_component oc
;
create view vw_patient as
select obfuscate_id(p.patient_id, 'p', 'pp') as patient_id
    ,p.uid
    ,extract('year' from p.patient_date_of_birth) as patient_year_of_birth
    ,p.patient_year_of_death
    ,p.patient_is_foetal_patient
    ,p.administrative_gender
    ,p.ethnicity
    ,p.ethnicity_description
    ,p.life_status
    ,p.karyotypic_sex
    ,p.phenotypic_sex
from patient p
;
create view vw_referral as
select obfuscate_id(r.referral_id, 'r', 'rr')
    ,r.uid
    ,r.status
    ,r.intent
    ,r.priority
    ,ci.clinical_indication_code
    ,ci.clinical_indication_full_name
    ,oe.ordering_entity_name
    ,oe.ordering_entity_code
    ,r.tumour_uid
from referral r
left join clinical_indication ci
    on r.clinical_indication_uid = ci.uid
left join ordering_entity oe
    on r.ordering_entity_uid = oe.uid
;
create view vw_referral_participant as
select obfuscate_id(rp.patient_id, 'p', 'pp') as patient_id
    ,obfuscate_id(rp.referral_id, 'r', 'rr') as referral_id
    ,rp.uid
    ,rp.referral_participant_is_proband
    ,rp.disease_status
    ,rp.referral_participant_age_at_onset
    ,rp.relationship_to_proband
from referral_participant rp
;
create view vw_referral_sample as
select obfuscate_id(rs.referral_id, 'r', 'rr') as referral_id
    ,rs.uid
    ,rs.sample_uid
from referral_sample rs
;
create view vw_referral_test as
select obfuscate_id(rt.referral_id, 'r', 'rr')
    ,rt.uid
    ,rt.referral_test_expected_number_of_patients
from referral_test rt
;
create view vw_sample as
select obfuscate_id(s.patient_id, 'p', 'pp') as patient_id
    ,s.uid
    ,s.percentage_of_malignant_cells
    ,s.sample_morphology
    ,s.sample_state
    ,s.sample_topography
    ,s.sample_type
    ,s.tumour_uid
    ,s.sample_collection_date
from sample s
;
create view vw_tumour as
select obfuscate_id(t.patient_id, 'p', 'pp') as patient_id
    ,t.uid
    ,t.tumour_type
    ,t.presentation
    ,t.tumour_diagnosis_day
    ,t.tumour_diagnosis_month
    ,t.tumour_diagnosis_year
from tumour t
;
create view vw_tumour_morphology as
select tm.uid
    ,tm.tumour_uid
    ,tm.morphology
from tumour_morphology tm
;
create view vw_tumour_topography as
select tt.uid
    ,tt.tumour_uid
    ,tt.actual_body_site
    ,tt.actual_body_site_description
    ,tt.primary_body_site
    ,tt.primary_body_site_description
from tumour_topography tt
;
