select
    oc.uid
    ,oc.observation_uid
    ,observation_component_code_concept.concept_code as observation_component_code
    ,observation_component_code_concept.concept_display as observation_component_code_description
    ,observation_component_value_concept.concept_code as observation_component_value
from public.observation_component oc
left join public.concept observation_component_code_concept on observation_component_code_concept.uid = oc.observation_component_code_cid
left join public.concept observation_component_value_concept on observation_component_value_concept.uid::varchar = oc.observation_component_value_string
;
