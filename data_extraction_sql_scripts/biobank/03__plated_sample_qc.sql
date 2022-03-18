select
    gel1008_id as platekey,
    /* irrelevant    ,created */
    /* irrelevant    ,warning_msgs */
    /* irrelevant    ,row */
    illumina_qc_status,
    illumina_sample_concentration,
    /* no data    ,illumina_sequence_gender */
    /* no data    ,illumina_delta_cq */
    dna_amount
/* not necessary    ,laboratory_sample_id as gel1001_id */
/* irrelevant    ,batch_import_id */
from biobank_illumina_gel1010;
