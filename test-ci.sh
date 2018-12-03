#!/bin/bash

env=$1
fails=""

inspect() {
    if [[ $1 -ne 0 ]]; then
        fails="${fails} $2"
    fi
}

# run web and server tests
dev() {
    docker-compose -f docker-compose-dev.yml up -d --build
    docker-compose -f docker-compose-dev.yml run users python manage.py test
    inspect $? users
    docker-compose -f docker-compose-dev.yml run users flake8 project
    inspect $? users-lint
    docker-compose -f docker-compose-dev.yml run exercises python manage.py test
    inspect $? exercises
    docker-compose -f docker-compose-dev.yml run exercises flake8 project
    inspect $? exercises-lint
    docker-compose -f docker-compose-dev.yml run web yarn test --coverage
    inspect $? web
    docker-compose -f docker-compose-dev.yml down
}

# run e2e tests
e2e() {
    docker-compose -f docker-compose-staging.yml up -d --build
    docker-compose -f docker-compose-staging.yml run users python manage.py recreate-db
    ./node_modules/.bin/cypress run --config baseUrl=http://localhost --env REACT_APP_API_GATEWAY_URL=$REACT_APP_API_GATEWAY_URL
    inspect $? e2e
    docker-compose -f docker-compose-$1.yml down
}

# run appropriate tests
if [[ ${env} == "development" ]]; then
    echo "Running web and server tests"
    dev
elif [[ ${env} == "staging" ]]; then
    echo "Running e2e tests"
    e2e staging
elif [[ ${env} == "production" ]]; then
    echo "Running e2e tests"
    e2e prod
else
    echo "Running web and sever tests"
    dev
fi

# return proper code
if [[ -n ${fails} ]]; then
    echo "\n"
    echo "Tests failed: ${fails}"
    exit 1
else
    echo "\n"
    echo "Tests passed!"
    exit 0
fi
