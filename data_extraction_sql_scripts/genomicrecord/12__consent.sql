-- get all the different consent forms (excluding Patient Level Questions)
-- used per patient, and their R2 answer
with r2_answer as (
    -- get R2 answers for each consent, needs distinct as small number have been
    -- asked multiple times, conflicts will cause duplicates in primary key
    -- in destination table
    select distinct cqr.consent_uid
        ,ca.value_string as answer_given
    from cqr_item ci
    join cqr_answer ca on ca.cqr_item_uid = ci.uid
    join consent_questionnaire_response cqr on ci.consent_questionnaire_response_uid = cqr.uid
    where ci.cqr_item_link_id = 'R2' 
)
select 
    -- some non-guid values in what should be patient_uid and referral_uid, make them null
    case
        when sid.value ~ '^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$' = true
            then sid.value::uuid
        else null
    end as patient_uid
    ,case
        when rid.value ~ '^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$' = true
            then rid.value::uuid
        else null
    end as referral_uid
    ,cqr.uid as consent_questionnaire_response_uid
    ,cqr.consent_uid
    ,cq.name as consent_form
    ,sts.concept_display as status
    ,r2.answer_given as research_answer_given
    ,row_number() over(partition by sid.value order by cqr.last_updated desc) as recency
    ,cqr.last_updated
from consent_questionnaire_response cqr
left join concept sts on sts.uid = cqr.status_cid
left join identifier rid on rid.uid = cqr.identifier_uid
left join identifier sid on sid.uid = cqr.source_identifier_uid
left join consent_questionnaire cq on cqr.consent_questionnaire_uid = cq.uid
left join r2_answer r2 on r2.consent_uid = cqr.consent_uid
-- some patients feature in consent data which aren't in patient table, remove them
left join patient p on sid.value = p.uid::varchar
where /*cq.name not in ('Patient Level Questions') and*/ p.uid is not null
;
