select
    tt.uid
    ,tt.tumour_uid
    ,actual_body_site_concept.concept_code as actual_body_site
    ,actual_body_site_concept.concept_display as actual_body_site_description
    ,primary_body_site_concept.concept_code as primary_body_site
    ,primary_body_site_concept.concept_display as primary_body_site_description
from public.tumour_topography tt
left join public.concept actual_body_site_concept on tt.actual_body_site_cid = actual_body_site_concept.uid
left join public.concept primary_body_site_concept on tt.primary_body_site_cid = primary_body_site_concept.uid
;
