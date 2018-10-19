#!/bin/bash

fails=""

inspect() {
    if [ $1 -ne 0 ]; then
        fails="${fails} $2"
    fi
}

# run unit and integration tests
docker-compose -f docker-compose-ci.yml up -d --build
docker-compose -f docker-compose-ci.yml run users python manage.py test
inspect $? users
docker-compose -f docker-compose-ci.yml run users flake8 project
inspect $? users-lint
docker-compose -f docker-compose-ci.yml run web npm test -- --coverage
inspect $? web
docker-compose -f docker-compose-ci.yml down

# return proper code
if [ -n "${fails}" ]; then
    echo "Tests failed: ${fails}"
    exit 1
else
    echo "Tests passed!"
    exit 0
fi
