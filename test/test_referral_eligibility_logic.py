import subprocess
import unittest
from test import data_for_testing

import data_transfer

# establish all the difference scenarios we want to test, the sql we need to
# run against the test data, and who should be in the participant_cohort and
# referral_cohort
test_scenarios = {
    'no_change_to_test_participants': {
        'sql': [],
        'referral_cohort': ['r001'],
        'participant_cohort': ['p001', 'p002'],
    },
    'one_participant_ineligible': {
        'sql': [
            (
                "update consent set discussion_answer_given = 'no' "
                "where participant_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
            )
        ],
        'referral_cohort': [],
        'participant_cohort': [],
    },
    'both_participant_ineligible': {
        'sql': [
            (
                "update consent set discussion_answer_given = 'no' "
                "where participant_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
            ),
            (
                "update consent set discussion_answer_given = 'no' "
                "where participant_uid = 'bcc7f940-e22e-4a9d-bb29-e3c4a571aba5';"
            ),
        ],
        'referral_cohort': [],
        'participant_cohort': [],
    },
    'two_separate_referrals_one_ineligible': {
        'sql': [
            (
                'insert into referral (uid, referral_id, status) values ('
                "'c6d8d302-aa64-412b-b0c1-4519ae771729', 'r002', 'active'"
                ');'
                "update referral_participant set referral_id = 'r002' "
                "where participant_id = 'p002';"
            )
        ],
        'referral_cohort': ['r001'],
        'participant_cohort': ['p001'],
    },
    'two_separate_referrals_both_eligible': {
        'sql': [
            (
                'insert into referral (uid, referral_id, status) values ('
                "'c6d8d302-aa64-412b-b0c1-4519ae771729', 'r002', 'active'"
                ');'
                'insert into closed_referral (referral_id) values ('
                "'r002');"
                "update referral_participant set referral_id = 'r002' "
                "where participant_id = 'p002';"
            )
        ],
        'referral_cohort': ['r001', 'r002'],
        'participant_cohort': ['p001', 'p002'],
    },
    'multiple_referrals_ineligible_referral': {
        'sql': [
            (
                'insert into referral (uid, referral_id, status) values ('
                "'c6d8d302-aa64-412b-b0c1-4519ae771729', 'r002', 'active'"
                ');'
                'insert into referral_participant (uid, participant_id, referral_id) '
                "values ('51535024-f19a-4f94-983d-08a3f2146eea', 'p002', 'r002');"
            )
        ],
        'referral_cohort': ['r001'],
        'participant_cohort': ['p001', 'p002'],
    },
    'multiple_referrals_eligible_referral': {
        'sql': [
            (
                'insert into referral (uid, referral_id, status) values ('
                "'c6d8d302-aa64-412b-b0c1-4519ae771729', 'r002', 'active'"
                ');'
                'insert into closed_referral (referral_id) values ('
                "'r002');"
                'insert into referral_participant (uid, participant_id, referral_id) '
                "values ('51535024-f19a-4f94-983d-08a3f2146eea', 'p002', 'r002');"
            )
        ],
        'referral_cohort': ['r001', 'r002'],
        'participant_cohort': ['p001', 'p002'],
    },
}


class TestReferralEligibilityLogic(unittest.TestCase):
    def setUp(self):
        """
        build the intermediate database and load up the test participant data
        """

        subprocess.run(['make', 'build_dest_db'], capture_output=True)

        d = data_for_testing.dict_to_dfs(data_for_testing.d)
        e = data_for_testing.dict_to_dfs(data_for_testing.e)

        with data_transfer.get_dest_connection() as con:

            for k, v in d.items():

                data_transfer.load_df_to_db(k, con, v)

            for k, v in e.items():

                data_transfer.load_df_to_db(k, con, v)

    def tearDown(self):
        """
        drop the intermediate database
        """

        subprocess.run(['make', 'drop_dest_db'], capture_output=True)


def test_generator(sql_stmts, referral_cohort, participant_cohort):
    """
    generate a test function to attach to the unittest subclass
    """

    def test(self):

        with data_transfer.get_dest_connection() as con:

            for x in sql_stmts:

                con.execute(x)

            rc = (
                data_transfer.read_sql_to_df(
                    'select referral_id from vw_referral_cohort;', con
                )
                .referral_id.sort_values()
                .tolist()
            )

            pc = (
                data_transfer.read_sql_to_df(
                    'select participant_id from vw_participant_cohort;', con
                )
                .participant_id.sort_values()
                .tolist()
            )

        self.assertListEqual(referral_cohort, rc)
        self.assertListEqual(participant_cohort, pc)

    return test


# go through and create test functions within unittest subclass for each
# test scenario
for ts, td in test_scenarios.items():

    test = test_generator(td['sql'], td['referral_cohort'], td['participant_cohort'])
    test.__name__ = f'test_referral_eligibility_logic_{ts}'
    setattr(TestReferralEligibilityLogic, test.__name__, test)
