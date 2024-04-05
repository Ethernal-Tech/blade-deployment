#!/bin/bash

mkdir /tmp/blade_data
cd /tmp/blade_data
aws s3 cp s3://$BUCKET_NAME/testnet.data.tar.gz .
if [ -f "testnet.data.tar.gz" ]; then
    tar -xf testnet.data.tar.gz
    cp -r blockchain /var/lib/blade/
    chown blade /var/lib/blade/blockchain
    chgrp blade-group /var/lib/blade/blockchain
    chmod 0750 /var/lib/blade/blockchain
    cp -r bootstrap /var/lib/blade/
    chown blade /var/lib/blade/bootstrap
    chgrp blade-group /var/lib/blade/bootstrap
    chmod 0750 /var/lib/blade/bootstrap
    chmod 0644 /var/lib/blade/bootstrap/genesis.json
    cp -r consensus /var/lib/blade/
    chown blade /var/lib/blade/consensus
    chgrp blade-group /var/lib/blade/consensus
    chmod 0750 /var/lib/blade/consensus
    cp -r trie /var/lib/blade/
    chown blade /var/lib/blade/trie
    chgrp blade-group /var/lib/blade/trie
    chmod 0750 /var/lib/blade/trie
else
    echo "File does not exist."
fi
rm -rf /tmp/blade_data