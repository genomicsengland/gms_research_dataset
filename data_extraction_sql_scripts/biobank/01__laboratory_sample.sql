select primary_sample_id_received_glh
    ,primary_sample_id_glh_lims
    ,primary_sample_type as type
    ,primary_sample_state as state
/* no data    ,received_sample_topography */
/* no data    ,received_sample_morphology */
/* no data    ,received_sample_tumour_content */
/* no data    ,received_sample_comments */
    ,received_sample_collection_date as collection_date
    ,glh_concentration_ng_ul as concentration_ng_ul_glh
    ,glh_od_260_280 as od_260_280_glh
    ,glh_din_value as din_value_glh
    ,glh_percentage_dna as percentage_dna_glh
    ,glh_qc_status as qc_status_glh
    ,dna_extraction_protocol
/* irrelevant    ,created */
/* irrelevant    ,warning_msgs */
/* irrelevant    ,row */
/* irrelevant    ,referral_id */
/* irrelevant    ,clinical_indication_test_type_id */
/* irrelevant    ,clinical_indication_test_type_uid */
/* irrelevant    ,patient_nhs_number */
/* irrelevant    ,patient_ngis_id */
/* irrelevant    ,ordering_entity_id */
/* irrelevant    ,glh_laboratory_id */
/* irrelevant    ,primary_sample_received_date */
/* irrelevant    ,patient_dob */
/* irrelevant    ,primary_sample_id_glh_lims */
/* irrelevant    ,dispatched_sample_id_glh_lims */
    ,dispatched_sample_lsid as gel1001_id
/* irrelevant    ,dispatched_sample_type */
/* irrelevant    ,dispatched_sample_state */
/* irrelevant    ,dispatched_sample_volume_ul */
/* irrelevant    ,laboratory_remaining_volume_banked_ul */
/* irrelevant    ,glh_sample_dispatch_date */
/* irrelevant    ,glh_sample_consignment_number */
/* irrelevant    ,plating_organisation */
/* irrelevant    ,gmc_rack_id */
/* irrelevant    ,gmc_rack_well */
/* irrelevant    ,prolonged_sample_storage */
/* irrelevant    ,retrospective_sample */
/* irrelevant    ,approved_by */
/* irrelevant    ,referral_uid */
/* irrelevant    ,patient_uid */
/* irrelevant    ,referral */
/* irrelevant    ,patient */
/* irrelevant    ,clinical_indication */
/* irrelevant    ,tumour */
/* irrelevant    ,ordering_entity */
/* irrelevant    ,patient_mask */
/* irrelevant    ,samples */
/* irrelevant    ,is_proband */
/* irrelevant    ,priority */
/* irrelevant    ,disease_area */
/* irrelevant    ,clinic_sample_type */
/* irrelevant    ,received_sample_topography_uid */
/* irrelevant    ,received_sample_morphology_uid */
/* irrelevant    ,batch_import_id */
/* irrelevant    ,clinical_indication_code */
from biobank_illumina_gel1001
;
