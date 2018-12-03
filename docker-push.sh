#!/bin/bash

inspect() {
    if [[ $1 -ne 0 ]]; then
        fails="${fails} $2"
    fi
}

if [[ -z $TRAVIS_PULL_REQUEST ]] || [[ $TRAVIS_PULL_REQUEST == "false" ]]; then

    if [[ $TRAVIS_BRANCH == "staging" ]]; then
        export DOCKER_ENV=staging
        export REACT_APP_USERS_SERVICE_URL="https://staging.fyles.io"
        export REACT_APP_EXERCISES_SERVICE_URL="https://staging.fyles.io"
    elif [[ $TRAVIS_BRANCH == "production" ]]; then
        export DOCKER_ENV=prod
        export REACT_APP_USERS_SERVICE_URL="https://fyles.io"
        export REACT_APP_EXERCISES_SERVICE_URL="https://fyles.io"
        export DATABASE_URL="$AWS_RDS_URI"
        export SECRET_KEY="$PRODUCTION_SECRET_KEY"
    fi

    if [[ $TRAVIS_BRANCH == "staging" ]] || [[ $TRAVIS_BRANCH == "production" ]]; then
        curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"

        unzip awscli-bundle.zip
        ./awscli-bundle/install -b ~/bin/aws
        export PATH=~/bin:$PATH
        # add AWS_ACCOUNT_ID, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY env vars
        eval $(aws ecr get-login --region us-east-1 --no-include-email)
        export TAG=$TRAVIS_BRANCH
        export REPO=$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
    fi

    if [[ $TRAVIS_BRANCH == "staging" ]] || [[ $TRAVIS_BRANCH == "production" ]]; then
        type=$1
        fails=""
        echo "\n"
        echo "Initializing Docker builds\n"

        # users
        docker pull $REPO/$USERS:$TAG
        docker build $USERS_REPO --cache-from $REPO/$USERS:$TAG -t $USERS:$COMMIT -f Dockerfile-$DOCKER_ENV
        inspect $? docker-build-users
        docker tag $USERS:$COMMIT $REPO/$USERS:$TAG
        inspect $? docker-tag-users
        docker push $REPO/$USERS:$TAG
        inspect $? docker-push-users

        # users db (non-production builds)
        if [[ $TRAVIS_BRANCH != "production" ]]; then
            docker pull $REPO/$USERS_DB:$TAG
            docker build $USERS_DB_REPO --cache-from $REPO/$USERS_DB:$TAG -t $USERS_DB:$COMMIT -f Dockerfile
            inspect $? docker-build-users_db
            docker tag $USERS_DB:$COMMIT $REPO/$USERS_DB:$TAG
            inspect $? docker-tag-users_db
            docker push $REPO/$USERS_DB:$TAG
            inspect $? docker-push-users_db
        fi

        # exercises
        docker pull $REPO/$EXERCISES:$TAG
        docker build $EXERCISES_REPO --cache-from $REPO/$EXERCISES:$TAG -t $EXERCISES:$COMMIT -f Dockerfile-$DOCKER_ENV
        inspect $? docker-build-exercises
        docker tag $EXERCISES:$COMMIT $REPO/$EXERCISES:$TAG
        inspect $? docker-tag-exercises
        docker push $REPO/$EXERCISES:$TAG
        inspect $? docker-push-exercises

        # exercises db (non-production builds)
        if [[ $TRAVIS_BRANCH != "production" ]]; then
            docker pull $REPO/$EXERCISES_DB:$TAG
            docker build $EXERCISES_DB_REPO --cache-from $REPO/$EXERCISES_DB:$TAG -t $EXERCISES_DB:$COMMIT -f Dockerfile
            inspect $? docker-build-exercises_db
            docker tag $EXERCISES_DB:$COMMIT $REPO/$EXERCISES_DB:$TAG
            inspect $? docker-tag-exercises_db
            docker push $REPO/$EXERCISES_DB:$TAG
            inspect $? docker-push-exercises_db
        fi

        # web
        docker pull $REPO/$WEB:$TAG
        docker build $WEB_REPO --cache-from $REPO/$WEB:$TAG -t $WEB:$COMMIT -f Dockerfile-$DOCKER_ENV --build-arg REACT_APP_USERS_SERVICE_URL=$REACT_APP_USERS_SERVICE_URL --build-arg REACT_APP_EXERCISES_SERVICE_URL=$REACT_APP_EXERCISES_SERVICE_URL --build-arg REACT_APP_API_GATEWAY_URL=$REACT_APP_API_GATEWAY_URL
        inspect $? docker-build-web
        docker tag $WEB:$COMMIT $REPO/$WEB:$TAG
        inspect $? docker-tag-web
        docker push $REPO/$WEB:$TAG
        inspect $? docker-push-web

        # swagger
        docker pull $REPO/$SWAGGER:$TAG
        docker build $SWAGGER_REPO --cache-from $REPO/$SWAGGER:$TAG -t $SWAGGER:$COMMIT -f Dockerfile-$DOCKER_ENV
        inspect $? docker-build-swagger
        docker tag $SWAGGER:$COMMIT $REPO/$SWAGGER:$TAG
        inspect $? docker-tag-swagger
        docker push $REPO/$SWAGGER:$TAG
        inspect $? docker-push-swagger

        # return proper code
        if [[ -n ${fails} ]]; then
            echo "\n"
            echo "Docker builds failed: ${fails}"
            exit 1
        else
            echo "\n"
            echo "Docker builds completed!"
            exit 0
        fi
    fi
fi
