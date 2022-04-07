import pandas as pd

d = {
    'patient': {
        'uid': '92943acf-12f4-4c9b-8bb2-068b81a1d3b7',
        'patient_id': 'p001',
    },
    'consent': {
        'consent_uid': 'be5e91a4-63de-49b4-b16d-d78368702369',
        'patient_uid': '92943acf-12f4-4c9b-8bb2-068b81a1d3b7',
        'recency': 1,
    },
    'referral': {'uid': '362635c4-6227-479e-9197-3b7196317759', 'referral_id': 'r001'},
    'referral_participant': {
        'uid': 'aa3097ec-ed5d-4785-b9f0-c6e689a5f609',
        'referral_id': 'r001',
        'patient_id': 'p001',
    },
}


def dict_to_dfs(d):
    """
    convert a dictionary to a list of dataframes
    :param d: dictionary to be converted
    """

    return {k: pd.DataFrame(v, index=['a']) for k, v in d.items()}
