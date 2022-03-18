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
    sample_topography varchar,
    tumour_uid uuid,
    sample_collection_date date,
    sample_id_glh varchar,
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

create table laboratory_sample (
    primary_sample_id_received_glh varchar,
    primary_sample_id_glh_lims varchar,
    patient_id varchar,
    referral_id varchar,
    type varchar,
    state varchar,
    collection_date timestamptz,
    concentration_ng_ul_glh numeric,
    od_260_280_glh numeric,
    din_value_glh numeric,
    percentage_dna_glh numeric,
    qc_status_glh varchar,
    dna_extraction_protocol varchar,
    gel1001_id bigint,
    primary key (gel1001_id)
);
comment on table laboratory_sample is 'Provides metadata and quality control data on samples processed by the GLH laboratories';

create table plated_sample (
    gel1001_id bigint,
    platekey varchar,
    primary key (platekey),
    foreign key (gel1001_id) references laboratory_sample (gel1001_id)
);
comment on table plated_sample is 'Provides the platekey for plated laboratory samples';

create table plated_sample_qc (
    platekey varchar,
    illumina_qc_status varchar,
    illumina_sample_concentration numeric,
    dna_amount numeric,
    primary key (platekey),
    foreign key (platekey) references plated_sample (platekey)
);
comment on table plated_sample_qc is 'Provides presequencing quality control data on plated laboratory samples';

create table consent (
    consent_uid uuid,
    patient_uid uuid,
    research_answer_given varchar,
    consent_category varchar,
    consent_date timestamp,
    recency int,
    primary key (consent_uid, recency),
    foreign key (patient_uid) references patient (uid)
);
comment on table consent is 'Reference table for consent data used for generation of participant list';

-- generate random seed number for ID obfuscation
-- patient and referral IDs are 11 digits long, so make seed that long also
create table obfuscation_seed (
    seed bigint
);
insert into obfuscation_seed (seed)
select floor(random() * (99999999999 - 10000000000 + 1) + 10000000000);

-- create table to hold release date
create table release (
    version int,
    release_date date
);

-- create table to hold referral IDs of closed cases
create table closed_referral (
    referral_id varchar,
    primary key (referral_id)
);

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
create view vw_patient_list as
with in_valid_referral as (
    -- get patients who are in valid referrals
    select distinct patient_id
    from referral_participant rp
    join referral r on rp.referral_id = r.referral_id
    where r.status in ('active', 'completed')
),
in_closed_case as (
    -- get patients associated with a closed referral
    select distinct rp.patient_id
    from referral_participant rp
    join closed_referral cr on rp.referral_id = cr.referral_id
),
agreed_to_research as (
    -- get those who answered yes to R2 consent question when most recently asked
    select p.patient_id
    from patient p
    join (select patient_uid, research_answer_given from consent where recency = 1) c
        on c.patient_uid = p.uid
    where c.research_answer_given ilike 'yes'
),
withdrawn as (
    -- get those who have withdrawn
    select p.patient_id
    from patient p
    join (select patient_uid, research_answer_given from consent where recency = 1) c
        on c.patient_uid = p.uid
    where c.research_answer_given ilike 'full withdrawal'
),
on_child_consent as (
    -- get those who have most recently consented as child
    select p.patient_id
    from patient p
    join (select patient_uid, consent_category from consent where recency = 1) c
        on c.patient_uid = p.uid
    where c.consent_category ilike 'child'
),
under_sixteen_at_consent as (
    -- get patients who were under sixteen at consent
    select p.patient_id
    from patient p
    join (select patient_uid, consent_date from consent where recency = 1) c
        on c.patient_uid = p.uid
    where extract('year' from age(c.consent_date, p.patient_date_of_birth)) < 16
),
under_sixteen_at_release as (
    -- get patients who have not had a sixteen birthday by the time of release
    select p.patient_id
    from patient p
    join release r on true
    where extract('year' from age(r.release_date, p.patient_date_of_birth)) < 16
),
deceased as (
    -- get all patients who were not alive at consent
    select p.patient_id
    from patient p
    where p.life_status != 'alive'
)
select p.patient_id
    ,obfuscate_id(p.patient_id, 'p', 'pp') as obfuscated_patient_id
    ,ivr.patient_id is not null as in_valid_referral
    ,icc.patient_id is not null as in_closed_case
    ,a2r.patient_id is not null as agreed_to_research
    ,wdr.patient_id is not null as withdrawn
    ,occ.patient_id is not null as on_child_consent
    ,usac.patient_id is not null as under_sixteen_at_consent
    ,usar.patient_id is not null as under_sixteen_at_release
    ,dec.patient_id is not null as deceased
    -- patient is eligible if:
    ,ivr.patient_id is not null and               -- they are in a valid referral AND
    icc.patient_id is not null and                -- they are in a closed case AND
    a2r.patient_id is not null and                -- they agreed to research AND
    (occ.patient_id is null or                    -- (they are not on child consent OR
        (occ.patient_id is not null and           --    (they are on child consent AND
            (usac.patient_id is null or           --       (they were over 16 at consent OR
                (usac.patient_id is not null and  --          (they are under sixteen at consent AND
                usar.patient_id is not null) or   --           they are under sixteen at release) OR
            dec.patient_id is not null))          --        they are deceased))
    ) as eligible                                 -- )
from patient p
left join in_valid_referral ivr on ivr.patient_id = p.patient_id
left join in_closed_case icc on icc.patient_id = p.patient_id
left join agreed_to_research a2r on a2r.patient_id = p.patient_id
left join withdrawn wdr on wdr.patient_id = p.patient_id
left join on_child_consent occ on occ.patient_id = p.patient_id
left join under_sixteen_at_consent usac on usac.patient_id = p.patient_id
left join under_sixteen_at_release usar on usar.patient_id = p.patient_id
left join deceased dec on dec.patient_id = p.patient_id
;
create view vw_eligible_patient as
select pl.patient_id
    ,pl.obfuscated_patient_id
from vw_patient_list pl
where pl.eligible = true
;
create view vw_eligible_referral as
select distinct rp.referral_id
    ,obfuscate_id(rp.referral_id, 'r', 'rr') as obfuscated_referral_id
from referral_participant rp
join vw_eligible_patient ep
on rp.patient_id = ep.patient_id
join closed_referral cr
on rp.referral_id = cr.referral_id
;
create view vw_condition as
select ep.obfuscated_patient_id as patient_id
    ,c.uid
    ,c.certainty
    ,c.code
    ,c.code_description
from condition c
join vw_eligible_patient ep on c.patient_id = ep.patient_id
;
create view vw_observation as
select ep.obfuscated_patient_id as patient_id
    ,o.uid
    ,o.observation_effective_from
    ,o.code
    ,o.code_description
    ,o.value_code
from observation o
join vw_eligible_patient ep on o.patient_id = ep.patient_id
;
create view vw_observation_component as
select oc.uid
    ,oc.observation_uid
    ,oc.observation_component_code
    ,oc.observation_component_code_description
    ,oc.observation_component_value
from observation_component oc
join vw_observation o on o.uid = oc.observation_uid
;
create view vw_patient as
select ep.obfuscated_patient_id as patient_id
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
join vw_eligible_patient ep on p.patient_id = ep.patient_id
;
create view vw_referral_participant as
select ep.obfuscated_patient_id as patient_id
    ,er.obfuscated_referral_id as referral_id
    ,rp.uid
    ,rp.referral_participant_is_proband
    ,rp.disease_status
    ,rp.referral_participant_age_at_onset
    ,rp.relationship_to_proband
from referral_participant rp
join vw_eligible_patient ep on rp.patient_id = ep.patient_id
join vw_eligible_referral er on rp.referral_id = er.referral_id
;
create view vw_referral as
select er.obfuscated_referral_id as referral_id
    ,r.uid
    ,r.status
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
join vw_eligible_referral er on r.referral_id = er.referral_id
;
create view vw_referral_test as
select er.obfuscated_referral_id as referral_id
    ,rt.uid
    ,rt.referral_test_expected_number_of_patients
from referral_test rt
join vw_eligible_referral er on rt.referral_id = er.referral_id
;
create view vw_sample as
with dedup_sample as (
    select distinct s.sample_id_glh
        ,s.patient_id
        ,rs.referral_id
        ,s.percentage_of_malignant_cells
        ,s.sample_morphology
        ,s.sample_topography
        ,s.tumour_uid
    from sample s
    join referral_sample rs on rs.sample_uid = s.uid
)
select obfuscate_id(ls.gel1001_id::varchar, '', 'ss') as sample_id
    ,ep.obfuscated_patient_id as patient_id
    ,er.obfuscated_referral_id as referral_id
    ,ls.type
    ,ls.state
    ,ls.collection_date
    ,ls.concentration_ng_ul_glh
    ,ls.od_260_280_glh
    ,ls.din_value_glh
    ,ls.percentage_dna_glh
    ,ls.qc_status_glh
    ,ls.dna_extraction_protocol
    ,s.percentage_of_malignant_cells
    ,s.sample_morphology
    ,s.sample_topography
    ,s.tumour_uid
from laboratory_sample ls
left join dedup_sample s
    on (
        (ls.primary_sample_id_received_glh is not null and s.sample_id_glh is not null and ls.primary_sample_id_received_glh = s.sample_id_glh) or
        (ls.primary_sample_id_glh_lims is not null and s.sample_id_glh is not null and ls.primary_sample_id_glh_lims = s.sample_id_glh)
    )
join vw_eligible_patient ep on ls.patient_id = ep.patient_id
join vw_eligible_referral er on ls.referral_id = er.referral_id
;
create view vw_plated_sample as
select obfuscate_id(p.gel1001_id::varchar, '', 'ss') as sample_id
    ,p.platekey
    ,qc.illumina_qc_status
    ,qc.illumina_sample_concentration
    ,qc.dna_amount
from plated_sample p
left join plated_sample_qc qc
    on p.platekey = qc.platekey
join vw_sample s on obfuscate_id(p.gel1001_id::varchar, '', 'ss') = s.sample_id
;
create view vw_tumour as
select ep.obfuscated_patient_id as patient_id
    ,t.uid
    ,t.tumour_type
    ,t.presentation
    ,t.tumour_diagnosis_day
    ,t.tumour_diagnosis_month
    ,t.tumour_diagnosis_year
from tumour t
join vw_eligible_patient ep on t.patient_id = ep.patient_id
;
create view vw_tumour_morphology as
select tm.uid
    ,tm.tumour_uid
    ,tm.morphology
from tumour_morphology tm
join vw_tumour t on t.uid = tm.tumour_uid
;
create view vw_tumour_topography as
select tt.uid
    ,tt.tumour_uid
    ,tt.actual_body_site
    ,tt.actual_body_site_description
    ,tt.primary_body_site
    ,tt.primary_body_site_description
from tumour_topography tt
join vw_tumour t on t.uid = tt.tumour_uid
;
