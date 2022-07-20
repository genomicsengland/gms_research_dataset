-- need to enable extension to be able to use guids
create extension if not exists "uuid-ossp"; -- noqa: L057

-- reference tables
create table clinical_indication (
    uid uuid,
    clinical_indication_code varchar constraint valid_ci_code_category
    check (left(clinical_indication_code, 1) in ('M', 'R')),
    clinical_indication_full_name varchar,
    primary key (uid)
);
comment on table clinical_indication is
'Reference table providing clinical indication codes and names.';

create table ordering_entity (
    uid uuid,
    ordering_entity_name varchar,
    ordering_entity_code varchar,
    primary key (uid)
);
comment on table ordering_entity is
'Reference table providing organisation/ordering entity names and codes.';

-- main tables
create table participant (
    uid uuid,
    participant_id varchar unique not null,
    participant_date_of_birth date,
    participant_year_of_death int,
    participant_is_foetal_participant bool,
    administrative_gender varchar,
    ethnicity varchar,
    ethnicity_description varchar,
    life_status varchar,
    karyotypic_sex varchar,
    phenotypic_sex varchar,
    primary key (uid)
);
comment on table participant is
'Provides participant personal and demographic data.';

create table tumour (
    uid uuid,
    participant_id varchar,
    tumour_type varchar,
    presentation varchar,
    tumour_diagnosis_day int,
    tumour_diagnosis_month int,
    tumour_diagnosis_year int,
    primary key (uid),
    foreign key (participant_id) references participant (participant_id)
);
comment on table tumour is 'Provides data on a participant''s tumour.';

create table referral (
    uid uuid,
    referral_id varchar unique not null,
    status varchar,
    intent varchar,
    priority varchar,
    clinical_indication_uid uuid,
    ordering_entity_uid uuid,
    date_submitted date,
    tumour_uid uuid,
    primary key (uid),
    foreign key (tumour_uid) references tumour (uid),
    foreign key (clinical_indication_uid) references clinical_indication (uid),
    foreign key (ordering_entity_uid) references ordering_entity (uid)
);
comment on table referral is
'Provides data on the overall referral request for tests.';

create table condition (
    uid uuid,
    participant_id varchar not null,
    certainty varchar,
    code varchar,
    code_description varchar,
    primary key (uid),
    foreign key (participant_id) references participant (participant_id)
);
comment on table condition is
'Provides data on participant''s condition (clinical problem or diagnosis).';

create table observation (
    uid uuid,
    participant_id varchar not null,
    observation_effective_from date,
    code varchar,
    code_description varchar,
    value_code varchar,
    primary key (uid),
    foreign key (participant_id) references participant (participant_id)
);
comment on table observation is
'Provides simple measurements and findings on a participant.';

create table observation_component (
    uid uuid,
    observation_uid uuid,
    observation_component_code varchar,
    observation_component_code_description varchar,
    observation_component_value varchar,
    primary key (uid),
    foreign key (observation_uid) references observation (uid)
);
comment on table observation_component is
'Adds further information/modifiers to a given observation.';

create table referral_participant (
    uid uuid,
    referral_id varchar,
    participant_id varchar,
    referral_participant_is_proband bool,
    disease_status varchar,
    referral_participant_age_at_onset int,
    relationship_to_proband varchar,
    primary key (uid),
    foreign key (participant_id) references participant (participant_id),
    foreign key (referral_id) references referral (referral_id)
);
comment on table referral_participant is
'Assigns participant to a given referral, and provides data relevant to their\
role in that referral.';

create table referral_test (
    uid uuid,
    referral_test_expected_number_of_participants int,
    referral_id varchar,
    primary key (uid),
    foreign key (referral_id) references referral (referral_id)
);
comment on table referral_test is
'Provides details on the individual tests within a referral.';

create table sample (
    uid uuid,
    participant_id varchar,
    percentage_of_malignant_cells int,
    sample_morphology varchar,
    sample_topography varchar,
    tumour_uid uuid,
    sample_collection_date date,
    sample_id_glh varchar,
    primary key (uid),
    foreign key (participant_id) references participant (participant_id),
    foreign key (tumour_uid) references tumour (uid)
);
comment on table sample is
'Provides data on the different samples collected from participant.';

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
    morphology_description varchar,
    primary key (uid),
    foreign key (tumour_uid) references tumour (uid)
);
comment on table tumour_morphology is
'Provides SNOMED morphology codes for a tumour.';

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
comment on table tumour_topography is
'Provide SNOMED topography codes for the actual or primary body site of a\
tumour.';

create table laboratory_sample (
    primary_sample_id_received_glh varchar,
    primary_sample_id_glh_lims varchar,
    participant_id varchar,
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
comment on table laboratory_sample is
'Provides metadata and quality control data on samples processed by the GLH\
laboratories';

create table plated_sample (
    gel1001_id bigint,
    platekey varchar,
    date_of_dispatch timestamp,
    primary key (platekey),
    foreign key (gel1001_id) references laboratory_sample (gel1001_id)
);
comment on table plated_sample is
'Provides the platekey for plated laboratory samples';

create table plated_sample_qc (
    platekey varchar,
    illumina_qc_status varchar,
    illumina_sample_concentration numeric,
    dna_amount numeric,
    primary key (platekey),
    foreign key (platekey) references plated_sample (platekey)
);
comment on table plated_sample_qc is
'Provides presequencing quality control data on plated laboratory samples';

create table consent (
    consent_uid uuid,
    participant_uid uuid,
    discussion_answer_given varchar,
    research_answer_given varchar,
    consent_category varchar,
    consent_date timestamp,
    recency int,
    primary key (consent_uid, recency),
    foreign key (participant_uid) references participant (uid)
);
comment on table consent is
'Reference table for consent data used for generation of participant list';

-- table to accommodate the random seed for encryption (stored as
-- environmental variable)
create table encryption_seed (
    seed bigint
);

-- create table to hold release date
create table release (
    version int,
    release_date date
);

-- create table to hold referral IDs of closed cases
create table closed_referral (
    referral_id varchar,
    primary key (referral_id),
    foreign key (referral_id) references referral (referral_id)
);

-- create table for whitelisted participants (shortlist for eligible
-- participants)
create table whitelisted_participant (
    participant_uid uuid,
    primary key (participant_uid),
    foreign key (participant_uid) references participant (uid)
);

-- function for ID encryption
create function encrypt_id (
    orig_id varchar, -- the ID to be encrypted
    orig_prefix varchar, -- the prefix that is used for that type of ID
    return_prefix varchar -- the prefix for the returned, encrypted ID
)
returns varchar as
$$
declare
    s encryption_seed.seed%type; -- copy type from the seed
begin
    -- get seed into function variable
    select seed
    from encryption_seed
    into s;
    -- encrypt the ID:
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
create function decrypt_id (
    orig_id varchar, -- the ID to be decrypted
    -- the prefix that is used for that type of encrypted ID
    orig_prefix varchar,
    return_prefix varchar -- the prefix for the returned, decrypted ID
)
returns varchar as
$$
declare
    s encryption_seed.seed%type; -- copy type from the seed
begin
    -- get seed into function variable
    select seed
    from encryption_seed
    into s;
    -- decrypt the ID:
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
create view vw_participant_list as
with in_valid_referral as ( -- noqa: L042
    -- get participants who are in valid referrals
    select distinct referral_participant.participant_id
    from referral_participant
    inner join
        referral on referral_participant.referral_id = referral.referral_id
    where referral.status in ('active', 'completed')
),

in_closed_case as (
    -- get participants associated with a closed referral
    select distinct referral_participant.participant_id
    from referral_participant
    inner join
        closed_referral on
            referral_participant.referral_id = closed_referral.referral_id
),

whitelisted_participant as (
    -- get all the whitelisted participants
    select distinct participant.participant_id
    from whitelisted_participant
    inner join participant on
        participant.uid = whitelisted_participant.participant_uid
),

discussed_research as (
    -- get those who answered yes to R1 consent question when most recently
    -- asked
    select participant.participant_id
    from participant
    inner join
        (select
            participant_uid,
            discussion_answer_given
            from consent where recency = 1) as c
        on c.participant_uid = participant.uid
    where c.discussion_answer_given ilike 'yes'
),

agreed_to_research as (
    -- get those who answered yes to R2 consent question when most recently
    -- asked
    select participant.participant_id
    from participant
    inner join
        (select
            participant_uid,
            research_answer_given
            from consent where recency = 1) as c
        on c.participant_uid = participant.uid
    where c.research_answer_given ilike 'yes'
),

withdrawn as (
    -- get those who have withdrawn
    select participant.participant_id
    from participant
    inner join
        (select
            participant_uid,
            research_answer_given
            from consent where recency = 1) as c
        on c.participant_uid = participant.uid
    where c.research_answer_given ilike 'full withdrawal'
),

on_child_consent as (
    -- get those who have most recently consented as child
    select participant.participant_id
    from participant
    inner join
        (select
            participant_uid,
            consent_category
            from consent where recency = 1) as c
        on c.participant_uid = participant.uid
    where c.consent_category ilike 'child'
),

under_sixteen_at_consent as (
    -- get participants who were under sixteen at consent
    select participant.participant_id
    from participant
    inner join (select
        participant_uid,
        consent_date
        from consent where recency = 1) as c
        on c.participant_uid = participant.uid
    where
        extract(
            'year' from age(c.consent_date,
                participant.participant_date_of_birth)
        ) < 16
),

under_sixteen_at_release as (
    -- get participants who have not had a sixteen birthday by the time
    -- of release
    select participant.participant_id
    from participant
    inner join release on true
    where
        extract(
            'year' from age(release.release_date,
                participant.participant_date_of_birth)
        ) < 16
),

deceased as (
    -- get all participants who were not alive at consent
    select participant.participant_id
    from participant
    where participant.life_status != 'alive'
)

select
    participant.participant_id,
    encrypt_id(participant.participant_id, 'p', 'pp')
    as encrypted_participant_id,
    in_valid_referral.participant_id is not null as in_valid_referral,
    in_closed_case.participant_id is not null as in_closed_case,
    whitelisted_participant.participant_id is not null as whitelisted,
    discussed_research.participant_id is not null as discussed_research,
    agreed_to_research.participant_id is not null as agreed_to_research,
    withdrawn.participant_id is not null as withdrawn,
    on_child_consent.participant_id is not null as on_child_consent,
    under_sixteen_at_consent.participant_id is not null
    as under_sixteen_at_consent,
    under_sixteen_at_release.participant_id is not null
    as under_sixteen_at_release,
    deceased.participant_id is not null as deceased,
    -- participant is eligible if:
    -- they are in a valid referral AND
    in_valid_referral.participant_id is not null
    -- they are in a closed case AND
    and in_closed_case.participant_id is not null
    -- they are a whitelisted participant AND
    and whitelisted_participant.participant_id is not null
    -- they discussed research AND
    and discussed_research.participant_id is not null
    -- they agreed to research AND
    and agreed_to_research.participant_id is not null
    -- (they are not on child consent OR
    and (on_child_consent.participant_id is null
        -- (they are on child consent AND
        or (on_child_consent.participant_id is not null
            -- they were under 16 at consent AND
            and under_sixteen_at_consent.participant_id is not null
                -- (they are under sixteen at release OR
            and (under_sixteen_at_release.participant_id is not null
                -- they are deceased))
                 or deceased.participant_id is not null))
    ) as eligible -- )
from participant
left join in_valid_referral on
    in_valid_referral.participant_id = participant.participant_id
left join in_closed_case on
    in_closed_case.participant_id = participant.participant_id
left join
    whitelisted_participant on
        whitelisted_participant.participant_id = participant.participant_id
left join
    discussed_research on
        discussed_research.participant_id = participant.participant_id
left join
    agreed_to_research on
        agreed_to_research.participant_id = participant.participant_id
left join withdrawn on
    withdrawn.participant_id = participant.participant_id
left join on_child_consent on
    on_child_consent.participant_id = participant.participant_id
left join
    under_sixteen_at_consent on
        under_sixteen_at_consent.participant_id = participant.participant_id
left join
    under_sixteen_at_release on
        under_sixteen_at_release.participant_id = participant.participant_id
left join deceased on deceased.participant_id = participant.participant_id;

create view vw_referral_list as
-- eligibility flags for each referral
with all_rp_eligible as (
    select
        referral_participant.referral_id,
        bool_and(vw_participant_list.eligible) as all_eligible
    from referral_participant
    inner join vw_participant_list on
        referral_participant.participant_id
        = vw_participant_list.participant_id
    group by referral_participant.referral_id
)

select -- noqa: L034
    referral.referral_id,
    encrypt_id(
        referral.referral_id, 'r', 'rr'
    ) as encrypted_referral_id,
    all_rp_eligible.all_eligible as all_referral_participants_eligible,
    closed_referral.referral_id is not null as closed_referral,
    -- referral is eligible if
    -- is a closed referral AND
    closed_referral.referral_id is not null
    -- all it's participants are eligible
    and all_rp_eligible.all_eligible as eligible
from referral
left join closed_referral on closed_referral.referral_id = referral.referral_id
left join all_rp_eligible on
    all_rp_eligible.referral_id = referral.referral_id;

create view vw_referral_cohort as
select
    vw_referral_list.referral_id,
    vw_referral_list.encrypted_referral_id
from vw_referral_list
where vw_referral_list.eligible = true;

create view vw_participant_cohort as
-- only include those participants in referrals where every participant
-- is eligible
select distinct
    referral_participant.participant_id,
    encrypt_id(referral_participant.participant_id, 'p', 'pp')
    as encrypted_participant_id
from referral_participant
inner join vw_referral_cohort
    on referral_participant.referral_id = vw_referral_cohort.referral_id;

create view vw_encryption_seed as
select seed from encryption_seed;

create view vw_condition as
select
    vw_participant_cohort.encrypted_participant_id as participant_id,
    condition.certainty,
    condition.code,
    condition.code_description
from condition
inner join vw_participant_cohort
    on condition.participant_id = vw_participant_cohort.participant_id;

create view vw_observation as
select
    vw_participant_cohort.encrypted_participant_id as participant_id,
    observation.uid,
    observation.observation_effective_from,
    observation.code,
    observation.code_description,
    observation.value_code
from observation
inner join vw_participant_cohort
    on observation.participant_id = vw_participant_cohort.participant_id;

create view vw_observation_component as
select
    vw_observation.participant_id,
    observation_component.observation_uid,
    observation_component.observation_component_code,
    observation_component.observation_component_code_description,
    observation_component.observation_component_value
from observation_component
inner join vw_observation
    on vw_observation.uid = observation_component.observation_uid;

create view vw_participant as
select
    vw_participant_cohort.encrypted_participant_id as participant_id,
    participant.participant_year_of_death,
    participant.participant_is_foetal_participant,
    participant.administrative_gender,
    participant.ethnicity,
    participant.ethnicity_description,
    participant.life_status,
    participant.karyotypic_sex,
    participant.phenotypic_sex,
    extract('year' from participant.participant_date_of_birth)
    as participant_year_of_birth
from participant
inner join
    vw_participant_cohort on
        participant.participant_id = vw_participant_cohort.participant_id;

create view vw_referral_participant as
select
    vw_participant_cohort.encrypted_participant_id as participant_id,
    vw_referral_cohort.encrypted_referral_id as referral_id,
    referral_participant.referral_participant_is_proband,
    referral_participant.disease_status,
    referral_participant.referral_participant_age_at_onset,
    referral_participant.relationship_to_proband
from referral_participant
inner join
    vw_participant_cohort on
        referral_participant.participant_id
        = vw_participant_cohort.participant_id
inner join vw_referral_cohort
    on referral_participant.referral_id = vw_referral_cohort.referral_id;

create view vw_referral as
select -- noqa: L034
    vw_referral_cohort.encrypted_referral_id as referral_id,
    referral.status,
    referral.priority,
    clinical_indication.clinical_indication_code,
    clinical_indication.clinical_indication_full_name,
    case
        when left(clinical_indication.clinical_indication_code, 1) = 'M'
            then 'cancer'
        when left(clinical_indication.clinical_indication_code, 1) = 'R'
            then 'rare_diseases'
    end as category,
    ordering_entity.ordering_entity_name,
    ordering_entity.ordering_entity_code,
    referral.date_submitted,
    referral.tumour_uid
from referral
left join clinical_indication
    on referral.clinical_indication_uid = clinical_indication.uid
left join ordering_entity
    on referral.ordering_entity_uid = ordering_entity.uid
inner join vw_referral_cohort
    on referral.referral_id = vw_referral_cohort.referral_id;

create view vw_referral_test as
select
    vw_referral_cohort.encrypted_referral_id as referral_id,
    referral_test.referral_test_expected_number_of_participants
from referral_test
inner join vw_referral_cohort
    on referral_test.referral_id = vw_referral_cohort.referral_id;

create view vw_sample as
with dedup_sample as (
    select distinct
        sample.sample_id_glh,
        sample.participant_id,
        referral_sample.referral_id,
        sample.percentage_of_malignant_cells,
        sample.sample_morphology,
        sample.sample_topography,
        sample.tumour_uid
    from sample
    inner join referral_sample on referral_sample.sample_uid = sample.uid
)

select
    vw_participant_cohort.encrypted_participant_id as participant_id,
    vw_referral_cohort.encrypted_referral_id as referral_id,
    laboratory_sample.type,
    laboratory_sample.state,
    laboratory_sample.collection_date,
    laboratory_sample.concentration_ng_ul_glh,
    laboratory_sample.od_260_280_glh,
    laboratory_sample.din_value_glh,
    laboratory_sample.percentage_dna_glh,
    laboratory_sample.qc_status_glh,
    laboratory_sample.dna_extraction_protocol,
    dedup_sample.percentage_of_malignant_cells,
    dedup_sample.sample_morphology,
    dedup_sample.sample_topography,
    dedup_sample.tumour_uid,
    encrypt_id(laboratory_sample.gel1001_id::varchar, '', 'ss') as sample_id
from laboratory_sample
left join dedup_sample
    on (
        (
            laboratory_sample.primary_sample_id_received_glh is not null
            and dedup_sample.sample_id_glh is not null
            and laboratory_sample.primary_sample_id_received_glh
            = dedup_sample.sample_id_glh
            and laboratory_sample.referral_id = dedup_sample.referral_id
        )
        or (
            laboratory_sample.primary_sample_id_glh_lims is not null
            and dedup_sample.sample_id_glh is not null
            and laboratory_sample.primary_sample_id_glh_lims
            = dedup_sample.sample_id_glh
            and laboratory_sample.referral_id = dedup_sample.referral_id
        )
    )
inner join vw_participant_cohort
    on laboratory_sample.participant_id = vw_participant_cohort.participant_id
inner join vw_referral_cohort
    on laboratory_sample.referral_id = vw_referral_cohort.referral_id;

create view vw_plated_sample as
select
    vw_sample.participant_id,
    plated_sample.platekey,
    plated_sample.date_of_dispatch,
    plated_sample_qc.illumina_qc_status,
    plated_sample_qc.illumina_sample_concentration,
    plated_sample_qc.dna_amount,
    encrypt_id(plated_sample.gel1001_id::varchar, '', 'ss') as sample_id
from plated_sample
left join plated_sample_qc
    on plated_sample.platekey = plated_sample_qc.platekey
inner join vw_sample
    on encrypt_id(
        plated_sample.gel1001_id::varchar, '', 'ss'
    ) = vw_sample.sample_id;

create view vw_tumour as
select
    vw_participant_cohort.encrypted_participant_id as participant_id,
    tumour.uid,
    tumour.tumour_type,
    tumour.presentation,
    tumour.tumour_diagnosis_day,
    tumour.tumour_diagnosis_month,
    tumour.tumour_diagnosis_year
from tumour
inner join
    vw_participant_cohort on
        tumour.participant_id = vw_participant_cohort.participant_id;

create view vw_tumour_morphology as
select
    vw_tumour.participant_id,
    tumour_morphology.tumour_uid,
    tumour_morphology.morphology,
    tumour_morphology.morphology_description
from tumour_morphology
inner join vw_tumour on vw_tumour.uid = tumour_morphology.tumour_uid;

create view vw_tumour_topography as
select
    vw_tumour.participant_id,
    tumour_topography.tumour_uid,
    tumour_topography.actual_body_site,
    tumour_topography.actual_body_site_description,
    tumour_topography.primary_body_site,
    tumour_topography.primary_body_site_description
from tumour_topography
inner join vw_tumour on vw_tumour.uid = tumour_topography.tumour_uid;
