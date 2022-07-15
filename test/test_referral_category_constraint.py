import subprocess
import unittest
from test import data_for_testing

from sqlalchemy.exc import IntegrityError

import data_transfer


class TestReferralCategoryConstraint(unittest.TestCase):
    def setUp(self):
        """
        build the intermediate database and load up the test data
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

    def test_referral_category(self):
        """
        test the referral category updates accordingly
        """

        # possible values for life status and corresponding expected value for
        # flag
        ci_code_to_category = {
            'M001': 'cancer',
            'R001': 'rare_diseases',
        }

        # loop through to change life status and check the flag updates
        # accordingly
        for code, category in ci_code_to_category.items():

            with data_transfer.get_dest_connection() as con:

                con.execute(
                    f"update clinical_indication set clinical_indication_code = '{code}';"
                )

                d = data_transfer.read_sql_to_df(
                    "select category from vw_referral where decrypt_id(referral_id, 'rr', 'r') = 'r001';",
                    con,
                )

                with self.subTest(f'Testing {code}'):

                    self.assertEqual(d.category[0], category)

    def test_ci_code_constraint(self):
        """
        test the clinical_indication_code constraint correctly rejects invalid code
        """

        with self.assertRaises(IntegrityError):

            with data_transfer.get_dest_connection() as con:

                con.execute(
                    "update clinical_indication set clinical_indication_code = 'X001';"
                )
