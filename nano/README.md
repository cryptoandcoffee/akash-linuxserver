# [linuxserver/nano](https://github.com/linuxserver/docker-nano)

This readme has been truncated from the full version found [HERE](https://github.com/linuxserver/docker-nano)

[Nano](https://nano.org/) is a digital payment protocol designed to be accessible and lightweight, with a focus on removing inefficiencies present in other cryptocurrencies. With ultrafast transactions and zero fees on a secure, green and decentralized network, this makes Nano ideal for everyday transactions.



## Application Setup

### Your Genesis account
By default this container will launch with a genesis block based on the private key `0000000000000000000000000000000000000000000000000000000000000000`, this should obviously only ever be used for testing purposes. Before you run your node you should use a script baked into this image to determine your private key and required environment variables: 

```
docker run --rm --entrypoint /genesis.sh linuxserver/nano
Generating Genesis block
!!!!!!! ACCOUNT INFO SAVE THIS INFORMATION IT WILL NOT BE SHOWN AGAIN !!!!!!!!
Private Key: CD4CD6B1E5523D4B5AEDD2B1E5A447C6C6797E729A531A95F9AD7937FC7CD9EA
Public Key:  2D057DF2EB09E918D3F95B5FCA69A5FD3EA406EF7D1810106324CD7A99FAA32D
Account:     nano_1da7hqsgp4hb55bzkptzsbntdzbyni5gyzar41a88b8fhcezoasfjkgmyk5y
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Container Environment Values:
 -e LIVE_GENESIS_PUB=2D057DF2EB09E918D3F95B5FCA69A5FD3EA406EF7D1810106324CD7A99FAA32D \
 -e LIVE_GENESIS_ACCOUNT=nano_1da7hqsgp4hb55bzkptzsbntdzbyni5gyzar41a88b8fhcezoasfjkgmyk5y \
 -e LIVE_GENESIS_WORK=7fd88e48684600b7 \
 -e LIVE_GENESIS_SIG=D1DF3A64BB43C131944401632215569A40AAE858ACF6CB59D5C77070E69DBF6435D93807877628A8B142DBF1AC4C562CD2F4CEBEB7D15486BDB7494A6146E007 \
```

These environment variables will be used for all of the peers in your payment network, but if you are running what you would consider a public or live network never share your private key even if you have drained the funds from that account it can be potentionally used to create valid forks.
**Even Better**, you should never even trust our Docker image for generating a private key and open block. Do it on an airgapped machine and keep it on a paper wallet.

### RPC Proxy settings
By default this container will enable RPC control and publish a custom service that acts as an RPC firewall giving you the ability to whitelist specific RPC calls and overide/add default values.

The default proxy config is stored in `/config/rpc-proxy.json`: 

```
{
  "port":3000,
  "httpsport":3001,
  "rpchost":"127.0.0.1",
  "rpcport":7076,
  "certfile":"/config/ssl/cert.crt",
  "keyfile":"/config/ssl/cert.key",
  "whitelist":[
    "account_info",
    "account_history",
    "block_count",
    "block_info",
    "pending",
    "process"
  ],
  "overrides":{
    "account-history":{
      "count":"64"
    },
    "pending":{
      "count":"8"
    }
  }
}
```

This should be a minimal amount of RPC access needed to run a local light wallet against this endpoint. If you plan on having your network users only run clientside light wallets (local blake2b block generation and block `process` call publishing) you should publically publish this port for access for both port 7076 and 7077. For functional light wallets on Https endpoints we will generate a self signed cert/key combo but you should add the ones associated with your domain. This will allow yours and other https hosted light wallets to hit your RPC endpoint clientside from the users web browser.

Outside of potential https tunneling and actual object parsing (will remove duplicate keys) this is not a conventional API, it simply acts as a firewall and will send and return data just like a local RPC server would. The goal is to be compatible with any existing Nano software if the developers decide to add the ability to connect to alternative network endpoints. 

**Our Proxy has not been audited by any security team and is provided as is, though we make the best effort to keep it simple and secure**

### Node configuration via environment
Before you get started please review the configuration docs [here](https://docs.nano.org/running-a-node/configuration/)

We will pass the `CLI_OPTIONS` to the node, here is a run command example:

```
-e CLI_OPTIONS='--config node.preconfigured_peers=["peering.yourhost.com","peering.yourhost2.com"] \
                --config node.enable_voting=true'
```

There are many options to know here to run an actual live node especially peering and voting, again please review the docs if you plan to run something outside of a local setup.

### Quickstart Guide

Here we are going to cover the bare minimum commands needed to spinup a local payment network and wallet. 

First spinup your containers:
```
docker run -d \
--name node \
-e CLI_OPTIONS='--config node.enable_voting=true' \
-p 7076:3000 \
--restart unless-stopped \
linuxserver/nano
```
```
docker run -d \
--name=wallet \
-p 80:80 \
--restart unless-stopped \
linuxserver/nano-wallet
```
Then unlock the Genesis funds on the local node to allow it to confirm transactions: 
```
docker exec -it node bash
root@f1df092971f0:/# curl -d '{ "action": "wallet_create" }' localhost:7076
{
    "wallet": "A3D63F1B28AC68BCD9E0FF74278C7984A36841C803EF1A81DF92BCD6E3BB18F9"
}
root@f1df092971f0:/# curl -d '{ "action": "wallet_add", "wallet": "A3D63F1B28AC68BCD9E0FF74278C7984A36841C803EF1A81DF92BCD6E3BB18F9", "key": "0000000000000000000000000000000000000000000000000000000000000000" }' localhost:7076
{
    "account": "nano_18gmu6engqhgtjnppqam181o5nfhj4sdtgyhy36dan3jr9spt84rzwmktafc"
}
```

Here we are using the default private key of `0000000000000000000000000000000000000000000000000000000000000000` for the image.
Navigate to http://localhost/#/localhost and enter this key. You should be greeted by the genesis account wallet with 340.28 Million Nano.

From here you can generate new wallets from the home screen and send/receive funds on your local network. Now you will be running an insecure centralized network with a single voting representative and a zero security private key using the commands above. To spinup a standard private or even public network you should read up on Nano's documentation [HERE](https://docs.nano.org/) and continue reading the network design section below.

### Network design
There are 4 main concepts to grasp from a network standpoint as far as types of endpoints. Before we get started here is a basic network diagram:

![image](https://raw.githubusercontent.com/linuxserver/image-docs/master/img/nano-network.png)

#### Principle nodes and voting representatives
Principle nodes are network representatives with the ability to vote due to having a certain threshold of funds unlocked on that node or pointed to that unlocked address. These nodes should be as airgapped as possible while still being an active 24/7 peer of the network. From a tecnical perspective this is a node with an account private key that either has the funds it needs itself or enough users have pointed their accounts to it as a representative. In a live and secure configuration to protect the funds of this account you would use an inactive private key account with the funds in it and locally sign a change of representative block to point to the always online representative.

These nodes should never process external RPC calls even on a local network, the same rules go for any node with a local unlocked wallet.

Keep in mind the key to the security of the network is that 51% of the funds are pointed to trusted representatives that will generally not argue about chain forks. 

In most deployments the best bet is to heavily centralize your voting nodes, this is unless you are intentionally trying to build a distributed ledger and security model like the main Nano live net. Achieving that will be a long and difficult task.

#### Network peers

To a normal user simply transacting on the network using off the shelf tools like a web wallet and web based block explorers is generally all that is required. They get a number in a ledger somewhere and are able to locally sign and publish blocks using their private key using your published RPC endpoints.

For advanced users and just to generally make the network more robust, network operators should promote people running their own nodes. Using this image a network peer simply needs to run a docker run command with your pre-configured variables. IE given the generation example from above in the `Your Genesis account` section:

```
docker create \
  --name=nano \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e PEER_HOST=peering.mydomain.com \
  -e LIVE_GENESIS_PUB=2D057DF2EB09E918D3F95B5FCA69A5FD3EA406EF7D1810106324CD7A99FAA32D \
  -e LIVE_GENESIS_ACCOUNT=nano_1da7hqsgp4hb55bzkptzsbntdzbyni5gyzar41a88b8fhcezoasfjkgmyk5y \
  -e LIVE_GENESIS_WORK=7fd88e48684600b7 \
  -e LIVE_GENESIS_SIG=D1DF3A64BB43C131944401632215569A40AAE858ACF6CB59D5C77070E69DBF6435D93807877628A8B142DBF1AC4C562CD2F4CEBEB7D15486BDB7494A6146E007 \
  -p 8075:8075 \
  -p 7076:3000 \
  -p 7077:3001 \
  -v /path/to/data:/config \
  --restart unless-stopped \
  linuxserver/nano
```

When the container spins up it will reach out to the node to bootstrap it's local ledger from peering.mydomain.com . This node once fully synced will be able to run local RPC commands to plug into a wallet and default Nano node wallet commands for automated pocketing of transactions etc. It will also get a list of other peers on the network from it's initial network peering and start participating in your distributed cryptocurrency network.

#### Public RPC endpoints
The key to users going to a webpage and managing the funds on your network is the ability to get blockchain information and publish new blocks to theirs. As mentioned earlier we bundle a basic firewall with a core set of RPC functions whitelisted that should be safe to expose publically. 

From a network design perspective these nodes should be purely what you would consider client peers and never have any wallets registered or private keys stored on them. Also for redundancy optmimally these peers should be run in a cluster behind a load balancer. For standard nodes you are building out a large P2P network, but in the case of the RPC endpoint and specifically the URL the end user is going to pass when accessing their wallet it is up to you to make that resilient.

#### Clientside javascript wallet
Currently we publish a pure javascript clientside wallet located here:  

https://github.com/linuxserver/nano-wallet

It is designed to be run 100% clientside in any web browser and use public RPC endpoints to hook into any network and conduct transactions by locally signing then publishing the result.
This can be hosted locally with any simple webserver and pointed to a locally run peer, but for full functionality we reccomend providing a public Https URL with these files along with plugging in legitamite SSL certificates into your RPC endpoints running on 7077.

# Running a node on the LinuxServer network

We maintain our own network which users can get funds to transact on from our [Discord](https://discord.gg/YWrKVTn) server. If you would like to run a node on our network here is our Docker run command:
```
docker create \
  --name=lsio-node \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e PEER_HOST=peering.linuxserver.io \
  -e LIVE_GENESIS_PUB=79F2E157B5667F1C8B6CCB6DF691DAC032B85DEC39E231D29976DCED05F5B1BE \
  -e LIVE_GENESIS_ACCOUNT=nano_1yhkw7ducsmz5k7pskufytaxoi3kq3gyrgh489bbkxpwxn4zdefyn4rmrrkk \
  -e LIVE_GENESIS_WORK=c51204c6b69384cb \
  -e LIVE_GENESIS_SIG=90DDE7B4DC038811180FF5DDE8594F1774542A7AADE3DB71A57AA38A5AED42672E1E8D7ACFAC315BDB0EB5DCB542C610B9C49B2560AE575073855259AF065509 \
  -p 8075:8075 \
  -p 7076:3000 \
  -p 7077:3001 \
  -v /path/to/data:/config \
  --restart unless-stopped \
  linuxserver/nano
```

## Usage

```bash
docker run -d \
  --name=nano \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e PEER_HOST=localhost `#optional` \
  -e LIVE_GENESIS_PUB=GENESIS_PUBLIC `#optional` \
  -e LIVE_GENESIS_ACCOUNT=nano_xxxxxx `#optional` \
  -e LIVE_GENESIS_WORK=WORK_FOR_BLOCK `#optional` \
  -e LIVE_GENESIS_SIG=BLOCK_SIGNATURE `#optional` \
  -e CLI_OPTIONS=--config node.enable_voting=true `#optional` \
  -e LMDB_BOOTSTRAP_URL=http://example.com/Nano_64_version_20.7z `#optional` \
  -p 8075:8075 \
  -p 7076:3000 \
  -p 7077:3001 \
  -v /path/to/data:/config \
  --restart unless-stopped \
  linuxserver/nano
```
