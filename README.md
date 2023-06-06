# Tip & Sign-In with a Web3 Wallet on Discourse (6do.world)

## Overview
Discourse is an open-source discussion platform used for most crypto governances 
and projects to discuss proposals, updates, and research. The following is a 
quick guide on how to add Sign-In with Web3 to your existing Discourse, as well as
the ability to allow users to tip each other.

### Requirements
- A Discourse forum that is self-hosted or that is hosted with a provider that allows 
third party plugins, like [Communiteq](https://www.communiteq.com/).

### Note
The Sign-In with Web3 plugin still requires users to enter an email to 
associate with their accounts after authenticating for the first time. If the 
user owns an ENS address, it will be the default selected username. Once an 
email address is associated, users can then sign in using the SIWE option at any 
time.

## Enabling the Plugin
To install and enable the plugin on your self-hosted Discourse use the following 
method: Access your container’s app.yml file (present in /var/discourse/containers/)

```bash
cd /var/discourse
nano containers/app.yml
```

Add the plugin’s repository URL to your container’s app.yml file:
```yml
hooks:
  before_code:                             # <-- added
    - exec:                                # <-- added
        cmd:                               # <-- added
          - gem install rubyzip            # <-- added
          - gem instal rbsecp256k1         # <-- added
  after_code:
    - exec:
      cd: $home/plugins
      cmd:
        - git clone https://github.com/discourse/docker_manager.git
        - git clone https://github.com/6doworld/discourse-6dc-tipper.git   # <-- added
```

Follow the existing format of the docker_manager.git line; if it does not 
contain `sudo -E -u discourse` then insert - `git clone https://github.com/6doworld/discourse-6dc-tipper.git`.

Rebuild the container:
```bash
cd /var/discourse
./launcher rebuild app
```
To disable it either remove the plugin or uncheck discourse siwe enabled at 
(Admin Settings -> Plugins -> discourse-6dc-tippet -> discourse 6dc tipper enabled ).

![Discourse Plugins](https://github.com/waqaarali/discourse-6dc-tipper/assets/109590536/54d06c3c-de87-4e38-b09f-dc767bcaed93 "Discourse Plugins")
![Enable plugin at settings](https://github.com/waqaarali/discourse-6dc-tipper/assets/109590536/fa0e2d33-f3d1-4017-920a-40f17836a5dd, "Enable plugin at settings")

## Enable WalletConnect
WalletConnect support can be provided via Infura. Create a new Infura project in 
order to receive a new Infura project ID. Then go to the settings (same as before) 
and paste the ID in that location and click on the checkmark. 
![Add infura id to plugin settings](https://github.com/waqaarali/discourse-6dc-tipper/assets/109590536/5aa28741-15c2-4f95-94e7-b62fbbf71a85, "Add infura id to plugin settings")

### JSON RPC

As an alternative, you can configure the WalletConnect instance with JSON RPC endpoints, as shown below:

_Doing so will supersede the Infura ID configuration option for WalletConnect specifically, other uses of an Infura ID won't be affected._

The top field is for your mainnet JSON RPC Endpoint & the bottom field is your Rinkeby JSON RPC Endpoint

![Add infura id to plugin settings](https://github.com/waqaarali/discourse-6dc-tipper/assets/109590536/f001a139-4662-4f0b-bf5f-71c32e419bfb, "Add infura id to plugin settings")

## Edit the message statement
By default a statement is added to the messages: Sign-in to Discourse via Ethereum. To edit this statement access the settings (same as before) and update it.
![Add infura id to plugin settings](https://github.com/waqaarali/discourse-6dc-tipper/assets/109590536/263d1de3-98a9-43bc-a4fc-7130999b046a, "Add infura id to plugin settings")

# Configuring Tipping ability

## Adding a Network Chain ID
For the tipping functionality to work, this is a crucial point in configuration. Choose a Blockchain Network you would like your users to be locked to such as Avalanche, Ethereum, BSC etc.
![Adding a Network Chain ID](https://github.com/waqaarali/discourse-6dc-tipper/assets/109590536/5bad2a54-d5ee-4cc2-8d5d-a7a9701a5a49, "Adding a Network Chain ID")

## Adding ERC-20 Contract
In order to allow your users to tip each other, you **must** add an ERC-20 Contract. You can paste in your deployed ERC-20 Contract or use one of the existing one's such as USDC. Make sure the ERC-20 is available on the **network chain id**.
![Adding ERC-20 Contract](https://github.com/waqaarali/discourse-6dc-tipper/assets/109590536/3ae34ff5-1c28-4679-b1ac-cc814f31b8b1, "Adding ERC-20 Contract")

## Updating the Currency Label
Make sure you don't forget this step! Update the *Currency* label as it appears in many pop-ups & system messages. You would want your users' to know what currency they have used to tip!
![Updating the Currency Label](https://github.com/waqaarali/discourse-6dc-tipper/assets/109590536/73276ccd-ba9a-4ff4-8937-e4fc5da9e7b0, "Updating the Currency Label")

## Setting Minimum & Maximum Tip
We have implemented limitations so contract owners have a peace of mind. Lock your users so they can only tip between certain amounts to avoid eating through all your Contract balance at once!
![Setting Minimum & Maximum Tip](https://github.com/waqaarali/discourse-6dc-tipper/assets/109590536/5f6e1eec-04af-4909-bf7f-4a3a5f4a1635, "Setting Minimum & Maximum Tip")

## Daily, Hourly and Minute-based Limitations
You can set limitations for how often users can tip every day, hour and minute. If you would prefer to remove the cap you can enter `0` or `false`. Each limitation is applied in the order that appears on the admin panel.
![Daily, Hourly and Minute-based Limitations](https://github.com/waqaarali/discourse-6dc-tipper/assets/109590536/134a3269-a252-4ed8-997b-4d5cadab026d. "Daily, Hourly and Minute-based Limitations")
