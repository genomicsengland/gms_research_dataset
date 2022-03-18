select
    public.patient.uid,
    public.patient.patient_human_readable_stored_id as patient_id,
    public.patient.patient_date_of_birth,
    public.patient.patient_is_foetal_patient,
    administrative_gender_concept.concept_code as administrative_gender,
    /* no data    ,p.patient_fetus_current_gestation */
    /* no data    ,p.patient_fetus_current_gestation_unit */
    /* no data    ,p.patient_fetus_estimated_due_date */
    ethnicity_concept.concept_code as ethnicity,
    ethnicity_concept.concept_display as ethnicity_description,
    life_status_concept.concept_code as life_status,
    karyotypic_sex_concept.concept_code as karyotypic_sex,
    /* no data    ,p.patient_last_menstrual_period */
    /* no data    ,p.additional_data */
    phenotypic_sex_concept.concept_code as phenotypic_sex,
    extract(
        'year' from public.patient.patient_date_of_death
    ) as patient_year_of_death
from public.patient
left join
    public.concept as administrative_gender_concept on
        administrative_gender_concept.uid
        = public.patient.administrative_gender_cid
left join
    public.concept as ethnicity_concept on
        ethnicity_concept.uid = public.patient.ethnicity_cid
left join
    public.concept as life_status_concept on
        life_status_concept.uid = public.patient.life_status_cid
left join
    public.concept as karyotypic_sex_concept on
        karyotypic_sex_concept.uid = public.patient.karyotypic_sex_cid
left join
    public.concept as phenotypic_sex_concept on
        phenotypic_sex_concept.uid = public.patient.phenotypic_sex_cid;
