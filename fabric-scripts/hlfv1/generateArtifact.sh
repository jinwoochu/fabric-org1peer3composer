# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#set path
export FABRIC_CFG_PATH=$DIR/composer

echo "---------------------------------------"
echo $DIR/composer


# remove previous crypto material and config transactions
rm -rf $DIR/composer/crypto-config
rm -rf $DIR/composer/composer-genesis.block
rm -rf $DIR/composer/composer-channel.tx
rm -rf $DIR/composer/Org1MSPanchors.tx 



# generate crypto material
~/bin/cryptogen generate --config=$DIR/composer/crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi
mv crypto-config $DIR/composer


## change PRIVATE KEY
# Copy the template to the file that will be modified to add the private key
cp $DIR/composer/docker-compose-template.yml $DIR/composer/docker-compose.yml

CURRENT_DIR=$DIR/composer
cd $CURRENT_DIR/crypto-config/peerOrganizations/org1.example.com/ca/
PRIV_KEY=$(ls *_sk)
cd "$CURRENT_DIR"
sed -i "s/PRIVATE_KEY/${PRIV_KEY}/g" docker-compose.yml



# generate genesis block for orderer
~/bin/configtxgen -profile ComposerOrdererGenesis -outputBlock $DIR/composer/composer-genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

# generate channel configuration transaction
~/bin/configtxgen -profile ComposerChannel -outputCreateChannelTx $DIR/composer/composer-channel.tx -channelID composerchannel
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction
~/bin/configtxgen -profile ComposerChannel -outputAnchorPeersUpdate $DIR/composer/Org1MSPanchors.tx -channelID composerchannel -asOrg Org1
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi


