import Controller from "@ember/controller";
import { isTesting } from "discourse-common/config/environment";
import discourseComputed from "discourse-common/utils/decorators";
import { action, computed } from "@ember/object";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { inject as service } from "@ember/service";

import showModal from 'discourse/lib/show-modal';
import TransferModalComponent from "../components/modal/transfer-modal";

import { ajax } from "discourse/lib/ajax";

import Web3Modal from "../lib/web3modal";
// import Web3Utils from "../lib/web3utils";

export default class PreferencesWalletController extends Controller {
  @service modal;
  
  constructor() {
    super(...arguments);

    this.set("walletTokenName", "...");  
    this.set("walletAddress", "0x0000000000000000"); 
    
    this.set("totalBalance", 0);
    
    this.set("walletBalance", "...");
    
    this.set("privateWalletAddress", "0x0000000000000000")
    this.set("privateWalletBalance", "...");

    this.set("walletTransactions", []);

    this.fetchWalletData();
    this.fetchWalletTransactions();
  }

  async fetchWalletData() {
    try {
      let { status, data } = await ajax('/discourse-6dc-tipper/fw');
      
      if (status) {
        let provider = Web3Modal.create();
        await provider.providerInit({});
        
        data.forEach(async (wallet) => {
          const walletInfo = await provider.getBalanceForWallet(
            this.siteSettings.network_rpc_url,
            wallet.address,
            this.siteSettings.erc_20_contract.length ? {
              name: this.siteSettings.currency,
              address: this.siteSettings.erc_20_contract,
            } : {
              name: this.siteSettings.currency,
              address: ''
            }
          );

          if (wallet.is_private) {
            this.set("privateWalletAddress", wallet.address);
            this.set("privateWalletBalance", walletInfo.balance);
          } else {
            this.set("walletAddress", wallet.address);
            this.set("walletBalance", walletInfo.balance);
          }
          
          this.set("totalBalance", parseFloat(this.get("totalBalance"))+parseFloat(walletInfo.balance));
          this.set("walletTokenName", walletInfo.token);
          console.log(wallet.address, "walletInfo:", walletInfo);
        });
      }
    } catch(err) {
      console.error(err)
    }
  }

  splitAndAddEllipsis(str, len) {
    const start = str.slice(0, len);
    const end = str.slice(-len);
    return start + '...' + end;
  }

  async fetchWalletTransactions() {
    try {
      let { status, data } = await ajax('/discourse-6dc-tipper/transactions');
      
      if (status) {
        const updatedData = data.map(item => {
          return {
            ...item,
            tx_hash: this.splitAndAddEllipsis(item.tx_hash, 23),
            created_at: moment(item.created_at).fromNow(), // change the format as needed
          };
        });
        
        this.set("walletTransactions", updatedData);
      }
    } catch(err) {
      console.error(err);
    }
  }

  @computed('walletAddress')
  get userWallet() {
    return this.walletAddress !== "0x0000000000000000" ? this.walletAddress : false
  }

  @computed('privateWalletAddress')
  get privateUserWallet() {
    return this.privateWalletAddress !== "0x0000000000000000" ? this.privateWalletAddress : false
  }

  @action
  async onSendFunds() {
    let data = await ajax('/discourse-6dc-tipper/st').catch(e => { return console.error(e) });
    console.log(data);
  }

  @action
  onTransferToggle() {
    this.modal.show(TransferModalComponent);
  }

  @action
  async generateWallet() {
    let data = await ajax('/discourse-6dc-tipper/gw').catch(e => { return console.error(e) });
    console.log(data);
  }
}
