mkdir /tmp/blade_data
cd /tmp/blade_data
cp -r /var/lib/blade/blockchain .
cp -r /var/lib/blade/bootstrap .
cp -r /var/lib/blade/consensus .
cp -r /var/lib/blade/trie .
tar czf testnet.data.tar.gz *
aws s3 cp testnet.data.tar.gz s3://$BUCKET_NAME/testnet.data.tar.gz
rm -rf /tmp/blade_data