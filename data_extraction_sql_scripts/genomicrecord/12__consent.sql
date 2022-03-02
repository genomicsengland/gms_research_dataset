-- get all consent data per patient
-- R2 answer to each consent event and consent category (adult/child)
with consent_questions as (
    /* all answers to all questions */
    select cqr.consent_uid
        ,ci.cqr_item_link_id as question_id
        ,ca.value_string as answer_given
    from cqr_item ci
    join cqr_answer ca on ca.cqr_item_uid = ci.uid
    join consent_questionnaire_response cqr on ci.consent_questionnaire_response_uid = cqr.uid
)
select c.uid as consent_uid
    ,c.patient_uid
    ,cq_res.answer_given as research_answer_given
    ,cq_cat.answer_given as consent_category
    ,cqr.consent_questionnaire_response_authored as consent_date
    ,row_number() over (partition by c.patient_uid order by cqr.last_updated) as recency
from consent c
join consent_questionnaire_response cqr on cqr.consent_uid = c.uid
left join (select * from consent_questions where question_id = 'R2') cq_res on cq_res.consent_uid = c.uid
left join (select * from consent_questions where question_id = 'GMSRD1_Q6.4') cq_cat on cq_cat.consent_uid = c.uid
;
