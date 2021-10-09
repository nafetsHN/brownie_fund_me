from brownie import network, accounts, config, MockV3Aggregator
from web3 import Web3


FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork", "mainnet-fork-dev2"]
LOCAL_BLOCKCHAIN_ENVORNMENTS = ["development", "gnache-local"]
DECIMAS = 8
STARTING_PRICE = 200000000000


def get_account():
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVORNMENTS or network.show_active() in FORKED_LOCAL_ENVIRONMENTS:
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def deploy_mocks():
    print("Depoloying Mocks...")
    if len(MockV3Aggregator) <= 0:
        MockV3Aggregator.deploy(DECIMAS,
                                STARTING_PRICE,
                                {"from": get_account()})
    print("Mocks Deployed!")
