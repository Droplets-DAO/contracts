from ape import project, accounts, Contract
from ape.cli import NetworkBoundCommand, network_option
# account_option could be used when in prod?
import click

@click.group()
def cli():
    """
    Script for test deployment of CogPair
    """

@cli.command(
    cls=NetworkBoundCommand,
)
@network_option()
def deploy_core_contracts(network):
    account = accounts.load('blast')
    account.set_autosign(True)

    droplet = account.deploy(project.droplet_nft, sender=account, type=0)
    account.claim_premints(sender=account, type=0)

    drip = account.deploy(project.drip, droplet.address, sender=account, type=0)
    droplet.init_drip(drip.address, sender=account, type=0)

    faucet = account.deploy(project.droplet_faucet, droplet.address, drip.address, "0x0e0A927fE11353d493DA8444490938DAe8FDAa7e",sender=account, type=0)

    print("Drip deployed at " + drip.address)
    print("Droplet NFTs deployed at " + droplet.address)
    print("Faucet deployed at " + faucet.address)