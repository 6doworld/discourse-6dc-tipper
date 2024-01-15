import EmberObject from "@ember/object";
import {
    ajax
} from "discourse/lib/ajax";
import {
    popupAjaxError
} from "discourse/lib/ajax-error";
import loadScript from "discourse/lib/load-script";

import I18n from "I18n";

const Web3Modal = EmberObject.extend({
    web3Modal: null,

    async providerInit(env) {
        await this.loadScripts();
        const Web3Modal = window.Web3Modal.default;
        const providerOptions = (() => {
            const opt = {};
            try {
                if (env.JSON_RPC) {
                    opt.walletconnect = {
                        package: Web3Bundle.WalletConnectProvider,
                        options: {
                            rpc: env.JSON_RPC,
                        }
                    };
                } else if (env.INFURA_ID) {
                    opt.walletconnect = {
                        package: Web3Bundle.WalletConnectProvider,
                        options: {
                            infuraId: env.INFURA_ID,
                        }
                    };
                }
            } catch (err) {
                console.error(err);
            }
            return opt;
        })();
        
        this.web3Modal = new Web3Modal({
            network: env.network,
            cacheProvider: true,
            providerOptions,
        });
    
    },

    async loadScripts() {
        return Promise.all([
            loadScript("/plugins/discourse-6dc-tipper/javascripts/ethers-5.5.4.umd.min.js"),
            loadScript("/plugins/discourse-6dc-tipper/javascripts/web3bundle.min.js"),
            loadScript("/plugins/discourse-6dc-tipper/javascripts/web3modal.min.js"),
            loadScript("/plugins/discourse-6dc-tipper/javascripts/erc-abi.js"),
            loadScript("/plugins/discourse-6dc-tipper/javascripts/confetti.js")
        ]);
    },

    async pay(
        erc20Address,
        ownerAddress, 
        receiverAddress, 
        amount,
    ) {
        const walletProvider = await this.web3Modal.connect();
        const provider = new ethers.providers.Web3Provider(walletProvider);
        
        const [address] = await provider.listAccounts();
        if (!address) {
            throw new Error(I18n.t("error.address_not_found"));
        }
        
        if (address !== ownerAddress) {
            throw new Error(I18n.t("error.wrong_account", { wallet: ownerAddress }));
        }
        
        if (erc20Address.length || erc20Address) {
            const contract = new ethers.Contract(erc20Address, erc_20_abi, provider);
            const signer = await contract.provider.getSigner(ownerAddress);
            const contractSigner = contract.connect(signer);
    
            return {
                type: 'erc-20',
                data: contractSigner.transfer(receiverAddress, ethers.utils.parseUnits(amount, 18))
            }
        } else {
            const params = [{
                from: ownerAddress,
                to: receiverAddress,
                value: ethers.utils.parseUnits(amount, 'ether').toHexString()
            }];
    
            return {
                type: 'eth',
                data: provider.send('eth_sendTransaction', params)
            }
        }
    },

    async close() {
        await this.web3Modal.disconnect();
    },

    async getBalanceForWallet(rpcProvider, walletAddress, customToken = {}) {
        const provider = new ethers.providers.getDefaultProvider(rpcProvider);
        
        if (customToken.address.length) {
            const contract = new ethers.Contract(customToken.address, erc_20_abi, provider);
            let adjustedBalance = 0.00;
            
            try {
                const decimals = await contract.decimals();
                const balance = await contract.balanceOf(walletAddress);
                adjustedBalance = balance / (10 ** decimals);
            } catch (err) {
                //
            }
            
            return {
                token: customToken.name,
                balance: adjustedBalance.toLocaleString('fullwide', { useGrouping: false })
            };
        } else {
            let balanceEth = 0.00;

            try {
                const balanceWei = await provider.getBalance(walletAddress);
                balanceEth = ethers.utils.formatEther(balanceWei);
            } catch(err) {
                //
            }

            return {
                token: customToken.name,
                balance: balanceEth.toLocaleString('fullwide', { useGrouping: false })
            }
        }
    },

    async signMessage(settingChainId) {
        const walletProvider = await this.web3Modal.connect();
        const provider = new ethers.providers.Web3Provider(walletProvider);

        const [address] = await provider.listAccounts();
        if (!address) {
            throw new Error('ADDRESS_NOT_FOUND');
        }

        let ens, avatar;
        try {
            ens = await provider.lookupAddress(address);
            if (ens) {
                avatar = await provider.getAvatar(ens);
            }
        } catch (error) {
            console.error(error);
        }

        let {
            chainId
        } = await provider.getNetwork();

        if (parseInt(settingChainId) !== chainId) {
            throw new Error('INVALID_CHAIN_ID');
        }

        const {
            message
        } = await ajax('/discourse-6dc-tipper/message', {
            data: {
                eth_account: address,
                chain_id: chainId,
            }
        })
            .catch(popupAjaxError);

        try {
            const signature = await provider.send(
                'personal_sign',
                [ethers.utils.hexlify(ethers.utils.toUtf8Bytes(message)), address]
            );
            return [ens || address, message, signature, avatar];

        } catch (e) {
            await this.web3Modal.clearCachedProvider();
            throw e;
        }
    },

    async runSigningProcess(settingChainId) {
        return await this.signMessage(settingChainId);
    },
});

export default Web3Modal;
