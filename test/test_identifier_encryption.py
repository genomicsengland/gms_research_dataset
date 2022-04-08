import subprocess
import unittest

import data_transfer


def mirror_encrypt_id(orig_id, orig_prefix, return_prefix, seed):
    """
    function to mirror the functionality of the encrypt_id plpgsql function
    """

    rev_num = int(orig_id.replace(orig_prefix, '')[::-1])

    return f'{return_prefix}{rev_num^seed}'


def mirror_decrypt_id(encrypted_id, orig_prefix, return_prefix, seed):
    """
    function to mirror the functionality of the decrypt_id plpgsql function
    """

    num = int(encrypted_id.replace(orig_prefix, ''))

    return f'{return_prefix}{str(num^seed)[::-1]}'


class TestIdentifierEncryption(unittest.TestCase):
    def setUp(self):
        """
        build the intermediate database
        """

        subprocess.run(['make', 'build_dest_db'], capture_output=True)

    def tearDown(self):
        """
        drop the intermediate database
        """

        subprocess.run(['make', 'drop_dest_db'], capture_output=True)

    def test_identifier_encryption(self):

        orig_id = 'p001'
        sql = f"select encrypt_id('{orig_id}', 'p', 'pp') as encrypted_id;"

        with data_transfer.get_dest_connection() as con:

            seed = data_transfer.read_sql_to_df(
                'select seed from encryption_seed;', con
            ).seed[0]
            returned_encrypted_id = data_transfer.read_sql_to_df(sql, con).encrypted_id[
                0
            ]

            expected_encrypted_id = mirror_encrypt_id(orig_id, 'p', 'pp', seed)
            self.assertEqual(returned_encrypted_id, expected_encrypted_id)

    def test_identifier_decryption(self):

        encrypted_id = 'pp001'
        sql = f"select decrypt_id('{encrypted_id}', 'pp', 'p') as decrypted_id;"

        with data_transfer.get_dest_connection() as con:

            seed = data_transfer.read_sql_to_df(
                'select seed from encryption_seed;', con
            ).seed[0]
            returned_decrypted_id = data_transfer.read_sql_to_df(sql, con).decrypted_id[
                0
            ]

            expected_decrypted_id = mirror_decrypt_id(encrypted_id, 'pp', 'p', seed)
            self.assertEqual(returned_decrypted_id, expected_decrypted_id)
