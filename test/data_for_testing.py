import pandas as pd

# first test patient
d = {
    'patient': {
        'uid': '92943acf-12f4-4c9b-8bb2-068b81a1d3b7',
        'patient_id': 'p001',
        'patient_date_of_birth': '1950-01-01',
        'life_status': 'alive',
    },
    'consent': {
        'consent_uid': 'be5e91a4-63de-49b4-b16d-d78368702369',
        'patient_uid': '92943acf-12f4-4c9b-8bb2-068b81a1d3b7',
        'research_answer_given': 'yes',
        'discussion_answer_given': 'yes',
        'consent_category': 'Adult',
        'consent_date': '2000-01-01',
        'recency': 1,
    },
    'referral': {
        'uid': '362635c4-6227-479e-9197-3b7196317759',
        'referral_id': 'r001',
        'status': 'active',
    },
    'referral_participant': {
        'uid': 'aa3097ec-ed5d-4785-b9f0-c6e689a5f609',
        'referral_id': 'r001',
        'patient_id': 'p001',
    },
    'closed_referral': {
        'referral_id': 'r001',
    },
    'whitelisted_patient': {
        'patient_uid': '92943acf-12f4-4c9b-8bb2-068b81a1d3b7',
    },
}

# second test patient, in same referral as first
e = {
    'patient': {
        'uid': 'bcc7f940-e22e-4a9d-bb29-e3c4a571aba5',
        'patient_id': 'p002',
        'patient_date_of_birth': '1950-01-01',
        'life_status': 'alive',
    },
    'consent': {
        'consent_uid': 'ddf5e1d9-fe44-4ef2-93e0-11898ff915ff',
        'patient_uid': 'bcc7f940-e22e-4a9d-bb29-e3c4a571aba5',
        'research_answer_given': 'yes',
        'discussion_answer_given': 'yes',
        'consent_category': 'Adult',
        'consent_date': '2000-01-01',
        'recency': 1,
    },
    'referral_participant': {
        'uid': 'b8775173-029b-4700-a6bb-6783b9aaa02b',
        'referral_id': 'r001',
        'patient_id': 'p002',
    },
    'whitelisted_patient': {
        'patient_uid': 'bcc7f940-e22e-4a9d-bb29-e3c4a571aba5',
    },
}


def dict_to_dfs(d):
    """
    convert a dictionary to a list of dataframes
    :param d: dictionary to be converted
    """

    return {k: pd.DataFrame(v, index=['a']) for k, v in d.items()}
