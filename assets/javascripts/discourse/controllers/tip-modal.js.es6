import ModalFunctionality from "discourse/mixins/modal-functionality";
import Controller from "@ember/controller";
import EmberObject, { action, computed } from "@ember/object";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { htmlSafe } from "@ember/template";

import Web3Modal from "../lib/web3modal";
import Web3Utils from "../lib/web3utils";

import I18n from "I18n";

export default Controller.extend(ModalFunctionality, {
    user: null,
    dialog: service(),
    isPaymentLoading: false,
    tipValue: '',
    showMoreOptions: false,
    targetWallet: '',
    sampleValues: [],
    
    init() {
        this._super(...arguments);
        this.utils = Web3Utils.create();
    },
    
    async onShow() {
        this.siteSettings.maximum_tip = 
            this.siteSettings.maximum_tip <= 0 ? 
                0.1 : this.siteSettings.maximum_tip

        this.siteSettings.minimum_tip = 
            this.siteSettings.minimum_tip <= 0 ? 
                0.001 : this.siteSettings.minimum_tip
                
        this.sampleValues = this.utils.intermediateValues(
            this.siteSettings.minimum_tip,
            this.siteSettings.maximum_tip,
            6
        ).filter(v => {
            if (v > 0) {
                try {
                    parseFloat(v);
                    return v;
                } catch(err) {
                    return null;
                }
            }
        });
    },

    onClose() {
        this.set("user", {});
        this.set("tipValue", this.sampleValues[0].toString());
        this.set("showMoreOptions", false);
        this.set("targetWallet", "");  
    },

    @action
    onInputChange({ target: { value } }) {
        try {
            parseFloat(value)
            this.set("tipValue", value.toLocaleString('fullwide', { useGrouping: false }));
        } catch(err) {
            console.log(err);
        }
    },

    @action
    toggleMoreOptions() {
        this.toggleProperty("showMoreOptions");
    },
    
    @action
    updatePaymentValue(amount="0.01") {
        this.set("showMoreOptions", false);
        this.set("tipValue", amount.toLocaleString('fullwide', { useGrouping: false }));
    },
    
    @computed('tipValue')
    get isNotValidNumber() {
        try {
            parseFloat(this.tipValue)
        } catch {
            return true;
        }

        return (this.tipValue === "" || isNaN(this.tipValue))
    },

    @action
    async tipUser() {
        this.set("isPaymentLoading", true);

        const throwAlert = (detail) => {
            this.set("isPaymentLoading", false);
            return this.dialog.alert(detail);
        }

        let { data: { target_has_wallet, user_has_wallet }  } = 
        await ajax('/discourse-6dc-tipper/wallets', {
            data: { target_id: this.user.id }
        }).catch(e => { return throwAlert(e.message) });
        
        if (!!!target_has_wallet) return throwAlert(I18n.t("error.target_no_wallet"));
        if (!!!user_has_wallet) return throwAlert(I18n.t("error.user_no_wallet"));

        let { data: transactions } = await ajax('/discourse-6dc-tipper/transactions', {
            data: { target_id: this.user.id }
        }).catch(e => { return throwAlert(e.message) });

        const now = moment(new Date());
        transactions = transactions.filter(t => t.user_id === this.currentUser.id);

        if (transactions.length) {
            for (const i in this.utils.limits) {
                let limit = this.utils.limits[i];

                if (limit.setting in this.siteSettings) {
                    const siteSetting = this.siteSettings[limit.setting];
                    if (siteSetting <= 0 || !!!siteSetting) {
                        console.log(`[Discourse6DCTipper] IGNORE \`${limit.setting}\`: <= 0 || false`);
                        continue;
                    }

                    if (transactions.length >= siteSetting) {
                        const tips = transactions.slice(0, siteSetting).filter(f => f);

                        for (const i in tips) {
                            let tip = tips[i];

                            if (tip.id) {
                                const creationDate = moment(tip.created_at);
                                const duration = moment.duration(now.diff(creationDate));
                                const difference = this.utils.durationConverter(limit.momentType, duration);
                                
                                if (difference <= 1) {
                                    limit.hasTips++; 
                                }
                            }
                        }

                        if (limit.hasTips >= siteSetting) return throwAlert(I18n.t("error.limit_reached", { max: siteSetting, type: limit.momentType }));
                    }
                }
            }
        }
            
        let provider = Web3Modal.create();
        await provider.providerInit({});
        
        // If user somehow bypasses the system and tries to tip themselves
        if (this.user.id === this.currentUser.id) return throwAlert(I18n.t("error.user_tip"));

        // If invalid number
        if (this.isNotValidNumber) {
            // Handle negative/incorrect tips in case of admin mistakes
            if (this.siteSettings.minimum_tip < 0) return throwAlert(I18n.t("error.min_tip", { min: 0.001 }));
            return throwAlert(I18n.t("error.min_tip", { min: this.siteSettings.minimum_tip }))
        }
        
        // Handle negative tips in case of admin mistakes
        if (parseFloat(this.get("tipValue")) <= 0 && this.siteSettings.minimum_tip < 0) return throwAlert(I18n.t("error.min_tip", { min: 0.001 }));
        // Make sure the value is valid and it is equivalent to or greater than the minimum tip
        if (this.siteSettings.minimum_tip > 0 && parseFloat(this.get("tipValue")) < this.siteSettings.minimum_tip) return throwAlert(I18n.t("error.min_tip", { min: this.siteSettings.minimum_tip }));
        // Make sure the tip is less than or equal to the maxmium tip
        if (parseFloat(this.get("tipValue")) > this.siteSettings.maximum_tip) return throwAlert(I18n.t("error.max_tip", { max: this.siteSettings.maximum_tip }));
        
        try {
            const payment = await provider.pay(
                this.siteSettings.erc_20_contract,
                user_has_wallet, 
                target_has_wallet, 
                this.get("tipValue")
            );

            const tx = await payment.data;
            
            if (tx) {
                const txHash = payment.type === "eth" ? tx : tx.hash;
                const { status, data: transaction } = await ajax('/discourse-6dc-tipper/transaction', {
                    type: "POST",
                    data: {
                        target_id: this.user.id,
                        transaction_hash: txHash,
                        amount: this.get("tipValue")
                    }
                }).catch(e => { return throwAlert(e.message) });

                this.set("isPaymentLoading", false);
                
                if (status && transaction) {
                    startConfetti();

                    this.dialog.alert({
                        message: htmlSafe(I18n.t("success.tip", {
                            amount: this.get("tipValue"),
                            currency: this.siteSettings.currency,
                            name: this.user.username,
                            wallet: target_has_wallet
                        })),
                        didConfirm: () => { this.send("closeModal"); stopConfetti(); },
                        didCancel: () => { this.send("closeModal"); stopConfetti(); },
                    });
                }
            }
        } catch(err) {
            console.error(err);
            return throwAlert(err.message);
        }
    }
});
