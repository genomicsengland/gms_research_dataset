select
    public.tumour_morphology.uid,
    public.tumour_morphology.tumour_uid,
    public.concept.concept_code as morphology,
    public.concept.concept_display as morphology_description
from public.tumour_morphology
left join
    public.concept
    on public.concept.uid = public.tumour_morphology.morphology_cid;
