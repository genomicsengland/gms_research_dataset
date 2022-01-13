select
    p.uid
    ,p.patient_human_readable_stored_id as patient_id
    ,p.patient_date_of_birth
    ,extract('year' from p.patient_date_of_death) as patient_year_of_death
    ,p.patient_is_foetal_patient
/* no data    ,p.patient_fetus_current_gestation */
/* no data    ,p.patient_fetus_current_gestation_unit */
/* no data    ,p.patient_fetus_estimated_due_date */
    ,administrative_gender_concept.concept_code as administrative_gender
    ,ethnicity_concept.concept_code as ethnicity
    ,ethnicity_concept.concept_display as ethnicity_description
    ,life_status_concept.concept_code as life_status
/* no data    ,p.patient_last_menstrual_period */
/* no data    ,p.additional_data */
    ,karyotypic_sex_concept.concept_code as karyotypic_sex
    ,phenotypic_sex_concept.concept_code as phenotypic_sex
from public.patient p
left join public.concept administrative_gender_concept on administrative_gender_concept.uid = p.administrative_gender_cid
left join public.concept ethnicity_concept on ethnicity_concept.uid = p.ethnicity_cid
left join public.concept life_status_concept on life_status_concept.uid = p.life_status_cid
left join public.concept karyotypic_sex_concept on karyotypic_sex_concept.uid = p.karyotypic_sex_cid
left join public.concept phenotypic_sex_concept on phenotypic_sex_concept.uid = p.phenotypic_sex_cid
;
