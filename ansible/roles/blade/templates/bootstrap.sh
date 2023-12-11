#!/bin/bash -x

main() {
    mkdir /var/lib/bootstrap
    pushd /var/lib/bootstrap

{% for item in hostvars %}
{% if (hostvars[item].tags.Role == "fullnode" or hostvars[item].tags.Role == "validator") %}
    blade secrets init --data-dir {{ hostvars[item].tags["Name"] }} --json --insecure > {{ hostvars[item].tags["Name"] }}.json
{% endif %}
{% endfor %}

    BURN_CONTRACT_ADDRESS=0x0000000000000000000000000000000000000000
    PROXY_CONTRACTS_ADMIN=0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed

    blade genesis \
                --consensus polybft \
                {% for item in hostvars %}{% if (hostvars[item].tags.Role == "fullnode" or hostvars[item].tags.Role == "validator") %} --bootnode /dns4/{{ hostvars[item].tags["Name"] }}/tcp/{{ blade_p2p_port }}/p2p/$(cat {{ hostvars[item].tags["Name"] }}.json | jq -r '.[0].node_id') {% endif %}{% endfor %} \
                {% for item in hostvars %}{% if (hostvars[item].tags.Role == "fullnode" or hostvars[item].tags.Role == "validator") %} --premine $(cat {{ hostvars[item].tags["Name"] }}.json | jq -r '.[0].address'):1000000000000000000000000 {% endif %}{% endfor %} \
                --premine {{ loadtest_account }}:1000000000000000000000000000 \
                --premine $BURN_CONTRACT_ADDRESS \
                --reward-wallet 0x0101010101010101010101010101010101010101:1000000000000000000000000000 \
                --premine 0xA39Fed214820cF843E2Bcd6cA1759257a530894B:1000000000000000000000000000 \
                --premine 0x181d9fEc79EC674DD3cB30dd9dd4188E737939FE:1000000000000000000000000000 \
                --premine 0x1AB8C3df809b85012a009c0264eb92dB04eD6EFa:1000000000000000000000000000 \
                --block-gas-limit {{ block_gas_limit }} \
                --block-time {{ block_time }}s \
                {% for item in hostvars %}{% if (hostvars[item].tags.Role == "validator") %} --validators /dns4/{{ hostvars[item].tags["Name"] }}/tcp/{{ blade_p2p_port }}/p2p/$(cat {{ hostvars[item].tags["Name"] }}.json | jq -r '.[0].node_id'):$(cat {{ hostvars[item].tags["Name"] }}.json | jq -r '.[0].address' | sed 's/^0x//'):$(cat {{ hostvars[item].tags["Name"] }}.json | jq -r '.[0].bls_pubkey') {% endif %}{% endfor %} \
                --epoch-size 10 \
                --native-token-config MyToken:MTK:18:true:{{ loadtest_account }} \
                --proxy-contracts-admin $PROXY_CONTRACTS_ADMIN

    blade polybft stake-manager-deploy \
        --jsonrpc {{ rootchain_json_rpc }} \
        --proxy-contracts-admin $PROXY_CONTRACTS_ADMIN \
        --test

    blade rootchain deploy \
                --stake-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeManagerAddr') \
                --stake-token $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeTokenAddr') \
                --json-rpc {{ rootchain_json_rpc }} \
                --proxy-contracts-admin $PROXY_CONTRACTS_ADMIN \
                --test

    blade rootchain fund \
                --stake-token $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeTokenAddr') \
                --mint \
                --addresses $(cat validator-*.json | jq -r ".[].address" | paste -sd "," - | tr -d '\n') \
                --amounts $(for f in validator-*.json; do echo -n "1000000000000000000000000,"; done | sed 's/,$//') \
                --json-rpc {{ rootchain_json_rpc }}

    blade polybft whitelist-validators \
        --private-key aa75e9a7d427efc732f8e4f1a5b7646adcc61fd5bae40f80d13c8419c9f43d6d \
        --addresses $(cat validator-*.json | jq -r ".[].address" | paste -sd "," - | tr -d '\n') \
        --supernet-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.customSupernetManagerAddr') \
        --jsonrpc {{ rootchain_json_rpc }}

    counter=1
{% for item in hostvars %}
{% if (hostvars[item].tags.Role == "validator") %}
    echo "Registering validator: ${counter}"

    blade polybft register-validator \
                --data-dir {{ hostvars[item].tags["Name"] }} \
                --supernet-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.customSupernetManagerAddr') \
                --jsonrpc {{ rootchain_json_rpc }}

    blade polybft stake \
                --data-dir {{ hostvars[item].tags["Name"] }} \
                --amount 1000000000000000000000000 \
                --supernet-id $(cat genesis.json | jq -r '.params.engine.polybft.supernetID') \
                --stake-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeManagerAddr') \
                --stake-token $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeTokenAddr') \
                --jsonrpc {{ rootchain_json_rpc }}

    ((counter++))
{% endif %}
{% endfor %}

{% for item in hostvars %}
{% if (hostvars[item].tags.Role == "validator") %}
{% endif %}
{% endfor %}

    blade polybft supernet \
                --private-key aa75e9a7d427efc732f8e4f1a5b7646adcc61fd5bae40f80d13c8419c9f43d6d \
                --supernet-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.customSupernetManagerAddr') \
                --finalize-genesis-set \
                --enable-staking \
                --jsonrpc {{ rootchain_json_rpc }}

    tar czf {{ base_dn }}.tar.gz *.json *.private
    popd
}

main