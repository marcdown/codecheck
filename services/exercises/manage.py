# manage.py


import unittest
import coverage

from flask.cli import FlaskGroup

from project import create_app, db
from project.api.models import Exercise


COV = coverage.coverage(
    branch=True,
    include='project/*',
    omit=[
        'project/tests/*',
        'project/config.py',
    ]
)
COV.start()

app = create_app()
cli = FlaskGroup(create_app=create_app)


@cli.command()
def test():
    """ Runs the tests without code coverage"""
    tests = unittest.TestLoader().discover('project/tests', pattern='test*.py')
    result = unittest.TextTestRunner(verbosity=2).run(tests)
    if result.wasSuccessful():
        return 0
    return 1


@cli.command()
def cov():
    """Runs the unit tests with coverage."""
    tests = unittest.TestLoader().discover('project/tests')
    result = unittest.TextTestRunner(verbosity=2).run(tests)
    if result.wasSuccessful():
        COV.stop()
        COV.save()
        print('Coverage Summary:')
        COV.report()
        COV.html_report()
        COV.erase()
        return 0
    return 1


@cli.command()
def recreate_db():
    db.drop_all()
    db.create_all()
    db.session.commit()


@cli.command()
def seed_db():
    """Seeds the database."""
    db.session.add(Exercise(
        body=('Define a function called sum that takes two integers as '
              'arguments and returns their sum.'),
        test_code='sum(2, 3)',
        test_code_solution='5'
    ))
    db.session.add(Exercise(
        body=('Define a function called sum_list that takes a list of numbers '
              'as an argument and returns their sum.'),
        test_code='sum_list([1, 2, 3, 4, 5])',
        test_code_solution='15'
    ))
    db.session.add(Exercise(
        body=('Define a function called doubleletters that takes a string as '
              'an argument and returns the string with two of each letter.'),
        test_code='doubleletters("Hello")',
        test_code_solution='HHeelllloo'
    ))
    db.session.add(Exercise(
        body=('Define a function called slicer that takes a string as '
              'an argument and returns the first three characters.'),
        test_code='slicer(\'abcdefgh\')',
        test_code_solution='abc'
    ))
    db.session.add(Exercise(
        body=('Define a function called dicer that takes a string as '
              'an argument and returns the third and fifth characters.'),
        test_code='dicer(\'abcdefgh\')',
        test_code_solution='ce'
    ))
    db.session.add(Exercise(
        body=('Define a function called factorial that takes a random number '
              'as an argument and returns the factorial of that given number.'),
        test_code='factorial(5)',
        test_code_solution='120'
    ))
    db.session.add(Exercise(
        body=('Define a function called isPrime that takes a random number '
              'as an argument and returns whether or not it is a prime number.'),
        test_code='isPrime(5)',
        test_code_solution='True'
    ))
    db.session.add(Exercise(
        body=('Define a function called dectohex that takes a random number '
              'as an argument and returns the hex value of that number.'),
        test_code='dectohex(32)',
        test_code_solution='0x20'
    ))
    db.session.add(Exercise(
        body=('Define a function called squared that takes a list of numbers '
              'as an argument and returns a list of each number squared.'),
        test_code='squared([1, 2, 3, 4, 5])',
        test_code_solution='[1, 4, 9, 16, 25]'
    ))
    db.session.add(Exercise(
        body=('Define a function called evens that takes a list of numbers '
              'as an argument and returns a list containing only the even numbers.'),
        test_code='evens([1, 2, 3, 4, 5, 6])',
        test_code_solution='[2, 4, 6]'
    ))
    db.session.commit()


if __name__ == '__main__':
    cli()
