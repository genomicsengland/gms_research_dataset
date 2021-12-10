select
    tm.uid
    ,tm.tumour_uid
    ,tumour_morphology_concept.concept_code as morphology
from public.tumour_morphology tm
left join public.concept tumour_morphology_concept on tumour_morphology_concept.uid = tm.morphology_cid
;
