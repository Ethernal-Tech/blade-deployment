#! /bin/bash

apt-get update
apt-get install -y ca-certificates curl gnupg
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
NODE_URL=https://deb.nodesource.com/node_$NODE_MAJOR.x
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] $NODE_URL nodistro main" | tee /etc/apt/sources.list.d/nodesource.list > /dev/null
apt-get update
apt-get install nodejs -y
apt-get install -y erlang unzip nodejs automake libtool inotify-tools gcc libgmp-dev make g++ openssl libssl-dev pkg-config acl
pushd /opt
mkdir elixir
pushd elixir
wget https://repo.hex.pm/builds/elixir/v1.13.4-otp-24.zip
unzip v1.13.4-otp-24.zip
popd
popd

pushd /usr/local/bin
ln -s /opt/elixir/bin/elixir .
ln -s /opt/elixir/bin/elixirc .
ln -s /opt/elixir/bin/iex .
ln -s /opt/elixir/bin/mix .
popd

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
pushd /usr/local/bin
cp $HOME/.cargo/bin/* .
popd

cargo install --git https://github.com/blockscout/blockscout-rs smart-contract-verifier-http
pushd /usr/local/bin
cp $HOME/.cargo/bin/smart-contract-verifier-http .
popd