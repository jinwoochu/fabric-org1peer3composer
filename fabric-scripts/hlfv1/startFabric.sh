#!/bin/bash


CHANNEL_NAME=composerchannel
echo "CHANNEL NAME :" $CHANNEL_NAME


# Exit on first error, print all commands.
set -ev

#Detect architecture
ARCH=`uname -m`

# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


ARCH=$ARCH docker-compose -f "${DIR}"/composer/docker-compose.yml down
ARCH=$ARCH docker-compose -f "${DIR}"/composer/docker-compose.yml up -d

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

echo "-----------------------------------------"
#               "Create channel."
echo "-----------------------------------------"
docker exec cli peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f /etc/hyperledger/configtx/composer-channel.tx




echo "-----------------------------------------"
#             "Peers Join channel."
echo "-----------------------------------------"
# Join peer0.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" -e "CORE_PEER_ADDRESS=peer0.org1.example.com:7051" cli peer channel join -b $CHANNEL_NAME.block


# Join peer1.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" -e "CORE_PEER_ADDRESS=peer1.org1.example.com:7051" cli peer channel join -b $CHANNEL_NAME.block

# Join peer2.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" -e "CORE_PEER_ADDRESS=peer2.org1.example.com:7051" cli peer channel join -b $CHANNEL_NAME.block

