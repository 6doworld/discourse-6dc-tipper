import Controller from "@ember/controller";
import { withPluginApi } from "discourse/lib/plugin-api";
import Web3Modal from "../lib/web3modal";
import { inject as service } from "@ember/service";

import I18n from "I18n";

export default Controller.extend({
  isAuthLoading: 1,
  dialog: service(),
  router: service(),

  init() {
    this._super(...arguments);
    this.initAuth();
  },

  verifySignature(account, message, signature, avatar) {
    document.getElementById("eth_account").value = account;
    document.getElementById("eth_message").value = message;
    document.getElementById("eth_signature").value = signature;
    document.getElementById("eth_avatar").value = avatar;
    document.getElementById("siwe-sign").submit();
  },

  async initAuth() {
    let deferredPrompt;

    window.addEventListener('beforeinstallprompt', function(e) {
      // Prevent Chrome 67 and earlier from automatically showing the prompt
      e.preventDefault();
      // Stash the event so it can be triggered later.
      deferredPrompt = e;
    });

    const env = withPluginApi("0.11.7", (api) => {
      const siteSettings = api.container.lookup("site-settings:main");

      const JSON_RPC = siteSettings.siwe_json_rpc.length > 0 ? siteSettings.siwe_json_rpc.split('\n').map((line) => {
        const [key, value] = line.split('|');
        return {[key]: value};
      }).reduce((acc, e) => Object.assign({}, acc, e)) : null;

      return {
        INFURA_ID: siteSettings.siwe_infura_id,
        JSON_RPC,
      }
    });

    if (deferredPrompt)

    deferredPrompt.prompt();
    
    let provider = Web3Modal.create();
    await provider.providerInit(env);

    try {
      
      const [account, message, signature, avatar] = await provider.runSigningProcess(this.siteSettings.network_chain_id);
      this.set("isAuthLoading", 2);
      this.verifySignature(account, message, signature, avatar);

    } catch (e) {

      this.set("isAuthLoading", 0);

      if (e.message === "INVALID_CHAIN_ID") {

        this.dialog.alert(I18n.t("error.invalid_chain_id", {
          chain: this.siteSettings.network_chain_id
        }));

      } else if (e.message === "ADDRESS_NOT_FOUND") {

        this.dialog.alert(I18n.t("error.invalid_wallet"));

      } else {

        this.dialog.alert({
          message: I18n.t("error.deny_access"),
          didConfirm: () => this.router.transitionTo("preferences.account", this.currentUser),
          didCancel: () => this.router.transitionTo("preferences.account", this.currentUser),
        });

        console.error(e);
      }
    }
  },

  actions: {
    async initAuth() {
      this.initAuth();
    }
  }
});
