#!/usr/bin/env bash

# usage
# docker-image <build|save|push|build-save|build-push|load> 

# version
imageVersion=$BUILD_VERSION

declare service_name="u-assist-promise"

function build() {
    echo "Got request to build image of $service_name service(s)"
	echo "building image for $service_name"
    mkdir -p ~/builds/package
    rm -rf ~/builds/package/*
    yes | cp -rf ../../u-assist-promise ~/builds/package/
    yes | cp -rf . ~/builds/package/
    cd  ~/builds/package
    docker rmi --force adoptopenjdk/openjdk8:alpine-slim
    # delete images
    docker rmi --force registry.uniphore.com/uniphore/$service_name:latest
    docker rmi --force registry.uniphore.com/uniphore/$service_name:$imageVersion
    # build images
    docker-compose --file docker-compose-build.yml  build --force-rm --parallel $service_name-latest
    docker-compose --file docker-compose-build.yml  build --force-rm --parallel $service_name-version
    rm -rf ~/builds/package/*
    cd -
}

function save() {
    echo "Got request to save image of $service_name service(s)"
    mkdir -p ~/builds/containers
    docker save registry.uniphore.com/uniphore/$service_name:$imageVersion | gzip > ~/builds/containers/${sname}_${imageVersion}.tar.gz
}

function push() {
    echo "Got request to push image of $service_name service(s) to registry"
    mkdir -p ~/builds/containers
    echo "pushing image $service_name"
	docker push registry.uniphore.com/uniphore/$service_name:latest
	docker push registry.uniphore.com/uniphore/$service_name:$imageVersion
}

function pull() {
    echo "Got request to pull image of $service_name service to registry"
    mkdir -p ~/builds/containers
    echo "pulling image of $service_name"
    docker pull registry.uniphore.com/uniphore/$service_name:latest
    docker pull registry.uniphore.com/uniphore/$service_name:$imageVersion
}

function scan() {
    echo "Got request to scan image of $service_name service to registry"
    local path=~/builds/scan-results
    rm -rf $path
    mkdir -p $path
    echo "scanning image of $service_name"
    snyk container test registry.uniphore.com/uniphore/ri/$service_name:$imageVersion --json > $path/$service_name-result.json
    snyk-to-html -i $path/$service_name-result.json -o $path/$service_name-result.html
}

function scan() {
    echo "Got request to scan image of $service_name service to registry"
    local path=~/builds/scan-results
    rm -rf $path
    mkdir -p $path
	echo "scanning image of $service_name"
    snyk container test registry.uniphore.com/uniphore/ri/$service_name:$imageVersion --json > $path/$service_name-result.json
    snyk-to-html -i $path/$service_name-result.json -o $path/$service_name-result.html
}

function load() {
    echo "Got request to load image of $service_name service"
    docker load < ../lib/$service_name_${imageVersion}.tar.gz
}

function run() {
    echo "$FUNCNAME - received arguments : $1 "
    case $1 in
       "build")
            # validate
            if [ "$#" != 1 ] ; then
                echo "usage sh docker-image <build|save|push|build-save|build-push|load> "
                exit 1
            fi
            build
        ;;
        "save")
            # validate
            if [ "$#" != 1 ] ; then
                echo "usage sh docker-image <build|save|push|build-save|build-push|load> "
                exit 1
            fi
            save
        ;;
		"push")
            # validate
            if [ "$#" != 1 ] ; then
                echo "usage sh docker-image <build|save|push|build-save|build-push|load> "
                exit 1
            fi
            push
        ;;
        "build-save")
            # validate
            if [ "$#" != 1 ] ; then
                echo "usage sh docker-image <build|save|push|build-save|build-push|load> "
                exit 1
            fi
            build
            save
        ;;
		"build-push")
            # validate
            if [ "$#" != 1 ] ; then
                echo "usage sh docker-image <build|save|push|build-save|build-push|load> "
                exit 1
            fi
            build
            push
        ;;
        "load")
            # validate
            if [ "$#" != 1 ] ; then
                echo "usage sh docker-image <build|save|push|build-save|build-push|load> "
                exit 1
            fi
            load
        ;;
		"pull")
            # validate
            if [ "$#" != 1 ] ; then
                echo "usage sh docker-image <build|save|push|build-save|build-push|load|pull> "
                exit 1
            fi
            pull
        ;;
    "scan")
            # validate
            if [ "$#" != 1 ] ; then
                echo "usage sh docker-image <build|save|push|build-save|build-push|load|pull|scan> "
                exit 1
            fi
            scan
        ;;
    esac
}

echo "$0 received arguments : $@"

# run "$@"

run $1
