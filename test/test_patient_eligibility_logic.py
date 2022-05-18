import subprocess
import unittest
from test import data_for_testing

import data_transfer

# establish all the difference scenarios we want to test, the sql we need to
# run against the test data, and what the expected eligible would be
test_scenarios = {
    'no_change_to_test_participant': {
        'sql': [],
        'eligible': True,
    },
    'not_in_valid_referral': {
        'sql': ["update referral set status = 'draft' where referral_id = 'r001';"],
        'eligible': False,
    },
    'not_in_closed_case': {
        'sql': ["delete from closed_referral where referral_id = 'r001';"],
        'eligible': False,
    },
    'did_not_discuss_research': {
        'sql': [
            (
                "update consent set discussion_answer_given = 'no' "
                "where patient_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
            )
        ],
        'eligible': False,
    },
    'did_not_agree_to_research': {
        'sql': [
            (
                "update consent set research_answer_given = 'no' "
                "where patient_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
            )
        ],
        'eligible': False,
    },
    'deceased': {
        'sql': [
            "update patient set life_status = 'deceased' where patient_id = 'p001';"
        ],
        'eligible': True,
    },
    'on_child_consent_over_16_at_consent': {
        'sql': [
            (
                "update consent set consent_category = 'Child' "
                "where patient_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
            ),
            (
                "update patient set patient_date_of_birth = '2000-01-01' "
                "where patient_id = 'p001';"
            ),
            (
                "update consent set consent_date = '2016-01-02' "
                "where patient_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
            ),
        ],
        'eligible': True,
    },
    'on_child_consent_under_16_at_consent_deceased': {
        'sql': [
            (
                "update consent set consent_category = 'Child' "
                "where patient_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
            ),
            (
                "update patient set patient_date_of_birth = '2000-01-01' "
                "where patient_id = 'p001';"
            ),
            (
                "update consent set consent_date = '2015-12-31' "
                "where patient_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
            ),
            "update patient set life_status = 'deceased' where patient_id = 'p001';",
        ],
        'eligible': True,
    },
    'on_child_consent_over_16_at_consent_deceased': {
        'sql': [
            (
                "update consent set consent_category = 'Child' "
                "where patient_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
            ),
            (
                "update patient set patient_date_of_birth = '2000-01-01' "
                "where patient_id = 'p001';"
            ),
            (
                "update consent set consent_date = '2016-01-02' "
                "where patient_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
            ),
            (
                "update patient set life_status = 'deceased' "
                "where patient_id = 'p001';"
            ),
        ],
        'eligible': True,
    },
    'on_child_consent_under_16_at_consent_under_16_at_release': {
        'sql': [
            (
                "update consent set consent_category = 'Child' "
                "where patient_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
            ),
            (
                "update patient set patient_date_of_birth = '2000-01-01' "
                "where patient_id = 'p001';"
            ),
            "update release set release_date = '2015-12-31';",
        ],
        'eligible': True,
    },
    'on_child_consent_under_16_at_consent_over_16_at_release': {
        'sql': [
            (
                "update consent set consent_category = 'Child' "
                "where patient_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
            ),
            (
                "update patient set patient_date_of_birth = '2000-01-01' "
                "where patient_id = 'p001';"
            ),
            "update release set release_date = '2016-01-02';",
        ],
        'eligible': False,
    },
    'on_child_consent_over_16_at_consent_over_16_at_release': {
        'sql': [
            (
                "update consent set consent_category = 'Child' "
                "where patient_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
            ),
            (
                "update patient set patient_date_of_birth = '2000-01-01' "
                "where patient_id = 'p001';"
            ),
            (
                "update consent set consent_date = '2016-01-02' "
                "where patient_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
            ),
            "update release set release_date = '2016-01-02';",
        ],
        'eligible': True,
    },
}


class TestPatientEligibilityLogic(unittest.TestCase):
    def setUp(self):
        """
        build the intermediate database and load up the test patient data
        """

        subprocess.run(['make', 'build_dest_db'], capture_output=True)

        d = data_for_testing.dict_to_dfs(data_for_testing.d)

        with data_transfer.get_dest_connection() as con:

            for k, v in d.items():

                data_transfer.load_df_to_db(k, con, v)

    def tearDown(self):
        """
        drop the intermediate database
        """

        subprocess.run(['make', 'drop_dest_db'], capture_output=True)


def test_generator(sql_stmts, eligible):
    """
    generate a test function to attach to the unittest subclass
    """

    def test(self):

        with data_transfer.get_dest_connection() as con:

            for x in sql_stmts:

                con.execute(x)

            d = data_transfer.read_sql_to_df(
                "select eligible from vw_patient_list where patient_id = 'p001';", con
            )

        self.assertEqual(eligible, d.eligible[0])

    return test


# go through and create test functions within unittest subclass for each
# test scenario
for ts, td in test_scenarios.items():

    test = test_generator(td['sql'], td['eligible'])
    test.__name__ = f'test_patient_eligibility_logic_{ts}'
    setattr(TestPatientEligibilityLogic, test.__name__, test)
