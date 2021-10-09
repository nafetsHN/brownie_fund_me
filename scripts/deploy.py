from brownie import FundMe, MockV3Aggregator, network, config
from scripts.fund_and_withdraw import fund
from scripts.helpful_scripts import get_account, deploy_mocks, LOCAL_BLOCKCHAIN_ENVORNMENTS


def deploy_fund_me():
    account = get_account()
    # pass the price feed address to our FundMe contract

    # if we are on presistant network like tinkeby, use the associated address
    # othervise use mocks
    print(f"The active network is {network.show_active()}")
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVORNMENTS:
        price_feed_address = config["networks"][network.show_active()].get(
            "eth_usd_price_feed")
        print("No Mocks Needed!")

    else:
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address

    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get(
            "verify"),
    )
    print(f"Contract deployed to {fund_me.address}")

    return fund_me


def main():
    deploy_fund_me()
