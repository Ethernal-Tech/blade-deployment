#!/bin/bash -x

main() {
    mkdir ${ bootstrap_dir } ${ bootstrap_dir }/secrets
    chmod -R 777 ${ bootstrap_dir  }
    pushd ${ bootstrap_dir }
    wget https://github.com/Ethernal-Tech/blade/releases/download/v${blade_version}/blade_${blade_version}_darwin_$(uname -m).tar.gz && tar -xvzf blade_${blade_version}_darwin_$(uname -m).tar.gz && chmod +x blade && cp blade /usr/local/bin/blade

    blade=/usr/local/bin/blade


    %{ for item in hostvars }

        sed 's/host/${item}/g' ../config.json > secrets/${item}_config.json
        $blade secrets init --config secrets/${item}_config.json --json > ${item}.json

    %{ endfor }

    ZERO_ADDRESS=0x0000000000000000000000000000000000000000
    PROXY_CONTRACTS_ADMIN=0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed

    AMT_24=1000000000000000000000000
    AMT_70=10000000000000000000000000000000000000000000000000000000000000000000000

    $blade genesis \
        --consensus polybft \
        --chain-id ${ chain_id } \
        %{ for item in validators } --validators /dns4/${item}/tcp/${ blade_p2p_port }/p2p/$(cat ${item}.json | jq -r '.[0].node_id'):$(cat ${item}.json | jq -r '.[0].address' | sed 's/^0x//'):$(cat ${item}.json | jq -r '.[0].bls_pubkey') %{ endfor } \
        %{ for item in fullnodes } --premine $(cat ${item}.json | jq -r '.[0].address'):$AMT_24 %{ endfor } \
        --block-gas-limit ${ block_gas_limit } \
        --premine ${ loadtest_account }:$AMT_24 \
        --premine ${ faucet_account }:$AMT_70 \
        --premine $ZERO_ADDRESS:$AMT_24 %{ if is_london_fork_active } --burn-contract 0:$ZERO_ADDRESS  %{ endif } \
        --epoch-size ${ epoch_size } \
        --reward-wallet ${reward_wallet} \
        --block-time ${ block_time }s \
        --native-token-config ${ native_token_config } \
        --blade-admin $(cat ${validators[0]}.json | jq -r '.[0].address') \
        --proxy-contracts-admin $PROXY_CONTRACTS_ADMIN \
        --base-fee-config ${ base_fee_config } \
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

    tar czf ${ base_dn }.tar.gz *.json secrets/
    aws s3 cp ${ base_dn }.tar.gz s3://${ clean_deploy_title }-state-bucket/${ base_dn }.tar.gz
    popd
}

main
