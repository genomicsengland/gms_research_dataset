import subprocess
import unittest
from test import data_for_testing

import data_transfer


class TestParticipantListFlags(unittest.TestCase):
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

    def test_deceased_flag(self):
        """
        test the deceased flag in vw_patient list
        """

        # possible values for life status and corresponding expected value for
        # flag
        life_status_to_deceased = {
            'alive': False,
            'deceased': True,
            'aborted': True,
            'unborn': True,
            'stillborn': True,
            'miscarriage': True,
            None: True,
        }

        # loop through to change life status and check the flag updates
        # accordingly
        for ls, dec in life_status_to_deceased.items():

            with data_transfer.get_dest_connection() as con:

                con.execute(
                    f"update patient set life_status = '{ls}' "
                    "where patient_id = 'p001';"
                )

                d = data_transfer.read_sql_to_df(
                    "select deceased from vw_patient_list where patient_id = 'p001';",
                    con,
                )

                with self.subTest(f'Testing {ls}'):

                    self.assertEqual(d.deceased[0], dec)

    def test_withdrawn_flag(self):
        """
        test the withdrawn flag in vw_patient_list
        """

        rag_to_withdrawn = {
            'Yes': False,
            'No': False,
            'Full withdrawal': True,
            None: False,
        }

        for rag, wdr in rag_to_withdrawn.items():

            with data_transfer.get_dest_connection() as con:

                con.execute(
                    f"update consent set research_answer_given = '{rag}' "
                    "where patient_uid =  '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
                )

                d = data_transfer.read_sql_to_df(
                    "select withdrawn from vw_patient_list where patient_id = 'p001';",
                    con,
                )

                with self.subTest(f'Testing {rag}'):

                    self.assertEqual(d.withdrawn[0], wdr)

    def test_valid_referral_flag(self):

        referral_status_to_valid = {
            'draft': False,
            'active': True,
            'revoked': False,
            'entered_in_error': False,
            'on_hold': False,
            'completed': True,
            'unknown': False,
            None: False,
        }

        for rs, val in referral_status_to_valid.items():

            with data_transfer.get_dest_connection() as con:

                con.execute(
                    f"update referral set status = '{rs}' "
                    "where referral_id = 'r001';"
                )

                d = data_transfer.read_sql_to_df(
                    "select in_valid_referral from vw_patient_list where patient_id = 'p001';",
                    con,
                )

                with self.subTest(f'Testing {rs}'):

                    self.assertEqual(d.in_valid_referral[0], val)

    def test_in_closed_case_flag(self):

        with data_transfer.get_dest_connection() as con:

            d = data_transfer.read_sql_to_df(
                "select in_closed_case from vw_patient_list where patient_id = 'p001';",
                con,
            )

            self.assertFalse(d.in_closed_case[0])

            con.execute("insert into closed_referral (referral_id) values ('r001');")

            d = data_transfer.read_sql_to_df(
                "select in_closed_case from vw_patient_list where patient_id = 'p001';",
                con,
            )

            self.assertTrue(d.in_closed_case[0])

    def test_agreed_to_research_flag(self):

        research_answer_to_agreed = {
            'yes': True,
            'no': False,
            None: False,
        }

        for ans, val in research_answer_to_agreed.items():

            with data_transfer.get_dest_connection() as con:

                con.execute(
                    f"update consent set research_answer_given = '{ans}' "
                    "where patient_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
                )

                d = data_transfer.read_sql_to_df(
                    "select agreed_to_research from vw_patient_list where patient_id = 'p001';",
                    con,
                )

                with self.subTest(f'Testing {ans}'):

                    self.assertEqual(d.agreed_to_research[0], val)

    def test_on_child_consent_flag(self):

        consent_category_to_child_consent = {
            'Child': True,
            'Adult': False,
            'Consultee': False,
            None: False,
        }

        for cat, chcon in consent_category_to_child_consent.items():

            with data_transfer.get_dest_connection() as con:

                con.execute(
                    f"update consent set consent_category = '{cat}' "
                    "where patient_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
                )

                d = data_transfer.read_sql_to_df(
                    "select on_child_consent from vw_patient_list where patient_id = 'p001';",
                    con,
                )

                with self.subTest(f'Testing {cat}'):

                    self.assertEqual(d.on_child_consent[0], chcon)

    def test_under_sixteen_at_consent_flag(self):

        test_scenarios = {
            'under_sixteen': {
                'dob': '2000-01-01',
                'doc': '2015-12-31',
                'flag': True,
            },
            'over_sixteen': {
                'dob': '2000-01-01',
                'doc': '2016-01-01',
                'flag': False,
            },
        }

        for ts, td in test_scenarios.items():

            with data_transfer.get_dest_connection() as con:

                con.execute(
                    f"update consent set consent_date = '{td['doc']}' "
                    "where patient_uid = '92943acf-12f4-4c9b-8bb2-068b81a1d3b7';"
                )

                con.execute(
                    f"update patient set patient_date_of_birth = '{td['dob']}' "
                    "where patient_id = 'p001';"
                )

                d = data_transfer.read_sql_to_df(
                    "select under_sixteen_at_consent from vw_patient_list where patient_id = 'p001';",
                    con,
                )

                with self.subTest(f'Testing {ts}'):

                    self.assertEqual(d.under_sixteen_at_consent[0], td['flag'])

    def test_under_sixteen_at_release_flag(self):

        test_scenarios = {
            'under_sixteen': {
                'dob': '2000-01-01',
                'dor': '2015-12-31',
                'flag': True,
            },
            'over_sixteen': {
                'dob': '2000-01-01',
                'dor': '2016-01-01',
                'flag': False,
            },
        }

        for ts, td in test_scenarios.items():

            with data_transfer.get_dest_connection() as con:

                con.execute(f"update release set release_date = '{td['dor']}';")

                con.execute(
                    f"update patient set patient_date_of_birth = '{td['dob']}' "
                    "where patient_id = 'p001';"
                )

                d = data_transfer.read_sql_to_df(
                    "select under_sixteen_at_release from vw_patient_list where patient_id = 'p001';",
                    con,
                )

                with self.subTest(f'Testing {ts}'):

                    self.assertEqual(d.under_sixteen_at_release[0], td['flag'])
