#!/bin/bash

# Exit on first error, print all commands.
set -ev

#Detect architecture
ARCH=`uname -m`

# Grab the current directory.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Shut down the Docker containers for the system tests.
cd "${DIR}"/composer
ARCH=$ARCH docker-compose -f docker-compose.yml kill && docker-compose -f docker-compose.yml down

rm -rf docker-compose.yml


# remove the local state
#rm -rf ~/.composer-connection-profiles/hlfv1
#rm -f ~/.composer-credentials/*

# remove chaincode docker images
image=$(docker images dev-* -q)
if [ "$images" != "" ]; then
 docker rmi -f $images
fi

# Your system is now clean
