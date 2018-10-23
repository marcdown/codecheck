#!/bin/bash

inspect() {
    if [ $1 -ne 0 ]; then
        fails="${fails} $2"
    fi
}

if [ -z "$TRAVIS_PULL_REQUEST" ] || [ "$TRAVIS_PULL_REQUEST" == "false" ]
then

    if [ "$TRAVIS_BRANCH" == "ecr" ] || [ "$TRAVIS_BRANCH" == "staging" ] || [ "$TRAVIS_BRANCH" == "production" ]
    then
        curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"

        unzip awscli-bundle.zip
        ./awscli-bundle/install -b ~/bin/aws
        export PATH=~/bin:$PATH
        # add AWS_ACCOUNT_ID, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY env vars
        eval $(aws ecr get-login --region us-east-1 --no-include-email)
        export TAG=$TRAVIS_BRANCH
        export REPO=$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
    fi

    if [ "$TRAVIS_BRANCH" == "ecr" ] || [ "$TRAVIS_BRANCH" == "staging" ] || [ "$TRAVIS_BRANCH" == "production" ]
    then
        type=$1
        fails=""
        echo "\n"
        echo "Initializing Docker builds\n"

        # users
        docker build $USERS_REPO -t $USERS:$COMMIT -f Dockerfile-prod
        inspect $? docker-build-users
        docker tag $USERS:$COMMIT $REPO/$USERS:$TAG
        inspect $? docker-tag-users
        docker push $REPO/$USERS:$TAG
        inspect $? docker-push-users
        # users db
        docker build $USERS_DB_REPO -t $USERS_DB:$COMMIT -f Dockerfile
        inspect $? docker-build-users_db
        docker tag $USERS_DB:$COMMIT $REPO/$USERS_DB:$TAG
        inspect $? docker-tag-users_db
        docker push $REPO/$USERS_DB:$TAG
        inspect $? docker-push-users_db
        # web
        docker build $WEB_REPO -t $WEB:$COMMIT -f Dockerfile-prod --build-arg REACT_APP_USERS_SERVICE_URL=TBD
        inspect $? docker-build-web
        docker tag $WEB:$COMMIT $REPO/$WEB:$TAG
        inspect $? docker-tag-web
        docker push $REPO/$WEB:$TAG
        inspect $? docker-push-web
        # swagger
        docker build $SWAGGER_REPO -t $SWAGGER:$COMMIT -f Dockerfile-prod
        inspect $? docker-build-swagger
        docker tag $SWAGGER:$COMMIT $REPO/$SWAGGER:$TAG
        inspect $? docker-tag-swagger
        docker push $REPO/$SWAGGER:$TAG
        inspect $? docker-push-swagger

        # return proper code
        if [ -n "${fails}" ]; then
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
