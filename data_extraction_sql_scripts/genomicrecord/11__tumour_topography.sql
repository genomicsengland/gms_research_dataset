select
    public.tumour_topography.uid,
    public.tumour_topography.tumour_uid,
    actual_body_site_concept.concept_code as actual_body_site,
    actual_body_site_concept.concept_display as actual_body_site_description,
    primary_body_site_concept.concept_code as primary_body_site,
    primary_body_site_concept.concept_display as primary_body_site_description
from public.tumour_topography
left join
    public.concept as actual_body_site_concept on
        public.tumour_topography.actual_body_site_cid
        = actual_body_site_concept.uid
left join
    public.concept as primary_body_site_concept on
        public.tumour_topography.primary_body_site_cid
        = primary_body_site_concept.uid;
