#!/bin/bash -x

main() {
    mkdir ${ bootstrap_dir } ${ bootstrap_dir }/secrets
    chmod -R 777 ${ bootstrap_dir  }
    pushd ${ bootstrap_dir }
    docker pull ${ docker_image }
    blade='docker run --rm --net host -e AWS_ACCESS_KEY_ID='$AWS_ACCESS_KEY_ID' -e AWS_SECRET_ACCESS_KEY='$AWS_SECRET_ACCESS_KEY' -u blade -w /data -v ${ bootstrap_dir }:/data ${ docker_image }'


    %{ for item in hostvars }

        sed 's/host/${item}/g' ../config.json > secrets/${item}_config.json
        $blade secrets init --config secrets/${item}_config.json --json > ${item}.json

    %{ endfor }

    ZERO_ADDRESS=0x0000000000000000000000000000000000000000
    PROXY_CONTRACTS_ADMIN=0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed

    AMT_24=1000000000000000000000000

    $blade genesis \
        --consensus polybft \
        --chain-id ${ chain_id } \
        %{ for item in validators } --validators /dns4/${item}/tcp/${ blade_p2p_port }/p2p/$(cat ${item}.json | jq -r '.[0].node_id'):$(cat ${item}.json | jq -r '.[0].address' | sed 's/^0x//'):$(cat ${item}.json | jq -r '.[0].bls_pubkey') %{ endfor } \
        %{ for item in fullnodes } --premine $(cat ${item}.json | jq -r '.[0].address'):$AMT_24 %{ endfor } \
        --block-gas-limit ${ block_gas_limit } \
        --premine ${ loadtest_account }:$AMT_24 \
        --premine $ZERO_ADDRESS %{ if is_london_fork_active } --burn-contract 0:$ZERO_ADDRESS  %{ endif } \
        --epoch-size 10 \
        --reward-wallet 0xDEADBEEF:0xD3C21BCECCEDA1000000 \
        --block-time ${ block_time }s \
        --native-token-config ${ native_token_config } \
        --blade-admin $(cat ${validators[0]}.json | jq -r '.[0].address') \
        --proxy-contracts-admin $PROXY_CONTRACTS_ADMIN \
        --base-fee-config 1000000000 \
        --epoch-reward ${ epoch_reward }

    %{ if is_bridge_active }
        $blade bridge server 2>&1 | tee bridge-server.log &

        $blade bridge fund \
            --addresses $(cat validator-*.json fullnode-*.json | jq -r ".[0].address" | paste -sd ',' - | tr -d '\n') \
            --amounts $(paste -sd ',' <(yes "1000000000000000000000000" | head -n `ls validator-*.json fullnode-*.json | wc -l`) | tr -d '\n')

        $blade bridge deploy \
            --proxy-contracts-admin $PROXY_CONTRACTS_ADMIN \
            --test
    %{ endif }


    chown -R $USER: genesis.json
    tar czf ${ base_dn }.tar.gz *.json secrets/
    aws s3 cp ${ base_dn }.tar.gz s3://${ clean_deploy_title }-state-bucket/${ base_dn }.tar.gz
    popd
}

main
