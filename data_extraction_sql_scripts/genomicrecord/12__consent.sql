-- get all consent data per participant
-- R2 answer to each consent event and consent category (adult/child)
with all_data as ( -- noqa: L042
    with consent_questions as ( -- noqa: L042
        /* all answers to all questions */
        select
            consent_questionnaire_response.consent_uid,
            cqr_item.cqr_item_link_id as question_id,
            cqr_answer.value_string as answer_given
        from cqr_item
        inner join cqr_answer on cqr_answer.cqr_item_uid = cqr_item.uid
        inner join
            consent_questionnaire_response on
                cqr_item.consent_questionnaire_response_uid
                = consent_questionnaire_response.uid
    )

    select
        consent.uid as consent_uid,
        consent.patient_uid,
        cq_disc.answer_given as discussion_answer_given,
        cq_res.answer_given as research_answer_given,
        cq_cat.answer_given as consent_category,
        consent_questionnaire_response.consent_questionnaire_response_authored
        as consent_date
    from consent
    inner join
        consent_questionnaire_response on
            consent_questionnaire_response.consent_uid = consent.uid
    left join
        (
            select * from consent_questions where question_id = 'R1'
        ) as cq_disc on cq_disc.consent_uid = consent.uid
    left join
        (
            select * from consent_questions where question_id = 'R2'
        ) as cq_res on cq_res.consent_uid = consent.uid
    left join
        (select * from consent_questions where question_id = 'GMSRD1_Q6.4')
        as cq_cat
        on cq_cat.consent_uid = consent.uid
)

select
    consent_uid,
    patient_uid as participant_uid,
    discussion_answer_given,
    research_answer_given,
    consent_category,
    consent_date,
    row_number() over (
        partition by
            patient_uid
        order by consent_date desc
    ) as recency
from all_data;
