select
    public.observation_component.uid,
    public.observation_component.observation_uid,
    observation_component_code_concept.concept_code
    as observation_component_code,
    observation_component_code_concept.concept_display
    as observation_component_code_description,
    observation_component_value_concept.concept_code
    as observation_component_value
from public.observation_component
left join
    public.concept as observation_component_code_concept on
        observation_component_code_concept.uid
        = public.observation_component.observation_component_code_cid
left join
    public.concept as observation_component_value_concept on
        observation_component_value_concept.uid::varchar
        = public.observation_component.observation_component_value_string;
