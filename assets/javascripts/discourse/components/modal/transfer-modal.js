import EmberObject, { action, computed } from "@ember/object";
import { inject as service } from "@ember/service";

import { ajax } from "discourse/lib/ajax";

import Web3Modal from "../../lib/web3modal";
import Component from '@ember/component';

export default class TransferModalComponent extends Component {
    @service dialog;
    @service modal;

    init() {
        super.init(...arguments);

        this.set("walletTokenName", "...");
        this.set("walletAddress", "0x0000000000000000");
        this.set("walletBalance", "...");
        this.set("recipientAddress", "0x0000000000000000");

        this.fetchWalletData();
    }

    async didInsertElement() {
        //
    }

    willDestroy() {
        //
    }

    @action
    onKeyPress(e) {
        const charCode = (e.which) ? e.which : e.keyCode;

        if (charCode > 31 && (charCode < 48 || charCode > 57) && charCode != 46) {
            e.preventDefault();
        } else {
            this.set("tipValue", e.target.value.toLocaleString('fullwide', { useGrouping: false }));
        }
    }

    @action
    onPaste(e) {
        e.preventDefault(); // Prevent the default paste operation

        // Get the text from the clipboard
        const clipboardData = e.clipboardData || window.clipboardData;
        const pastedText = clipboardData.getData('text');

        // Try to parse the pasted text into a float
        const parsedValue = parseFloat(pastedText);

        // If the parsed value is a number, set the input value to the parsed value
        if (!isNaN(parsedValue)) {
            const newValue = parsedValue.toLocaleString('fullwide', { useGrouping: false });
            this.set("tipValue", newValue);
            e.target.value = newValue;
        }
    }

    @action
    getMaxBalance(e) {
        const maxValue = this.walletBalance.toLocaleString('fullwide', { useGrouping: false });
        this.set("tipValue", maxValue);
        e.target.previousElementSibling.value = maxValue
    }

    @action
    onInputChange({ target: { value } }) {
        this.set("recipientAddress", value);
    }

    @action
    onInputChangeAmount({ target: { value } }) {
        this.set("tipValue", value.toLocaleString('fullwide', { useGrouping: false }));
    }

    @action
    async tipUser() {
        this.set("isPaymentLoading", true);

        const throwAlert = (detail) => {
            this.set("isPaymentLoading", false);
            return this.dialog.alert(detail);
        }

        // Handle negative tips in case of admin mistakes
        if (parseFloat(this.get("tipValue")) <= 0) return throwAlert(I18n.t("error.greater_value"));
        // Make sure the tip is less than or equal to the maxmium tip
        if (parseFloat(this.get("tipValue")) > parseFloat(this.walletBalance)) return throwAlert(I18n.t("error.balance_exceeded"));

        const { status, data } = await ajax('/discourse-6dc-tipper/st', {
            type: "POST",
            data: {
                recipientAddress: this.get("recipientAddress"),
                amount: this.get("tipValue")
            }
        }).catch(e => { return throwAlert(e.message) });

        if (status) {
            throwAlert(I18n.t("success.transfer", { amount: this.get('tipValue'), currency: this.get('walletTokenName') }));
            // this.set('tipValue', '0.00');
            await this.fetchWalletData();
            console.log(status, data);
            this.closeModal();
        } else {
            throwAlert("Something went wrong!");
            console.log(status, data);
        }
    }

    async fetchWalletData() {
        try {
            let { status, data } = await ajax('/discourse-6dc-tipper/fw');

            if (status) {
                
                let provider = Web3Modal.create();
                await provider.providerInit({});
                
                let walletAddress = '';
                data.forEach((wallet) => {
                    if (wallet.is_private) {
                        this.set("recipientAddress", wallet.address);
                    } else {
                        this.set("walletAddress", wallet.address);
                    }
                });

                if (!this.recipientAddress.length) {
                    this.closeModal();
                    throwAlert(I18n.t("error.connect_wallet"));
                }

                const walletInfo = await await provider.getBalanceForWallet(
                    this.siteSettings.network_rpc_url,
                    this.get("walletAddress"),
                    this.siteSettings.erc_20_contract.length ? {
                      name: this.siteSettings.currency,
                      address: this.siteSettings.erc_20_contract,
                    } : {
                      name: this.siteSettings.currency,
                      address: ''
                    }
                );

                this.set("walletTokenName", walletInfo.token);
                this.set("walletBalance", walletInfo.balance);
            }
        } catch (err) {
            console.error(err)
        }
    }
}
