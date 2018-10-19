import unittest

from sqlalchemy.exc import IntegrityError

from project import db
from project.api.models import User
from project.tests.base import BaseTestCase
from project.tests.utils import add_user


class TestUserModel(BaseTestCase):
    def test_add_user(self):
        user = add_user('test1', 'test1@email.com', '12345')
        self.assertTrue(user.id)
        self.assertEqual(user.username, 'test1')
        self.assertEqual(user.email, 'test1@email.com')
        self.assertTrue(user.active)
        self.assertTrue(user.password)
        self.assertFalse(user.admin)

    def test_add_user_duplicate_username(self):
        add_user('test1', 'test1@email.com', '12345')
        duplicate_user = User(
            username='test1',
            email='test2@email.com',
            password='12345'
        )
        db.session.add(duplicate_user)
        self.assertRaises(IntegrityError, db.session.commit)

    def test_add_user_duplicate_email(self):
        add_user('test1', 'test1@email.com', '12345')
        duplicate_user = User(
            username='test2',
            email='test1@email.com',
            password='12345'
        )
        db.session.add(duplicate_user)
        with self.assertRaises(IntegrityError):
            db.session.commit()

    def test_to_json(self):
        user = add_user('test1', 'test1@email.com', '12345')
        self.assertTrue(isinstance(user.to_json(), dict))

    def test_passwords_are_random(self):
        user_one = add_user('test1', 'test1@email.com', '12345')
        user_two = add_user('test2', 'test2@email.com', '12345')
        self.assertNotEqual(user_one.password, user_two.password)

    def test_encode_auth_token(self):
        user = add_user('test1', 'test1@email.com', '12345')
        auth_token = user.encode_auth_token(user.id)
        self.assertTrue(isinstance(auth_token, bytes))

    def test_decode_auth_token(self):
        user = add_user('test1', 'test1@email.com', '12345')
        auth_token = user.encode_auth_token(user.id)
        self.assertTrue(isinstance(auth_token, bytes))
        self.assertEqual(User.decode_auth_token(auth_token), user.id)


if __name__ == '__main__':
    unittest.main()
