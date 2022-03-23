#!/bin/bash
# script to work through each of the tables in the release and export to tsv
source .env
export PGPASSFILE='.pgpass_dest'

output_fldr=$EXPORT_LOCATION/GMS_RR_V$RELEASE_VERSION_$RELEASE_DATE
output_fldr_ref=$output_fldr/reference

echo -e "Exporting to: $output_fldr"

rm -r $output_fldr
mkdir -p $output_fldr
mkdir $output_fldr_ref

export_table () {
    declare tab=$1
    declare tgt=$2
    echo $tab
    psql -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER $DEST_DB_NAME \
        -c "copy (select * from vw_$tab) to stdout csv header delimiter e'\t';" > $tgt
}

research_tables=(\
 "condition"\
 "observation"\
 "observation_component"\
 "patient"\
 "plated_sample"\
 "referral"\
 "referral_participant"\
 "referral_test"\
 "sample"\
 "tumour"\
 "tumour_morphology"\
 "tumour_topography")

reference_tables=(\
 "eligible_patient"\
 "eligible_referral"\
 "patient_list")

for i in ${research_tables[@]}
do
    export_table $i $output_fldr/$i.tsv
done

for i in ${reference_tables[@]}
do
    export_table $i $output_fldr_ref/$i.tsv
done
