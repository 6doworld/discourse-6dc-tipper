import Component from "@ember/component";
import { inject as service } from "@ember/service";

import { action } from "@ember/object";
import showModal from "discourse/lib/show-modal";

export default Component.extend({
    tagName: "",
    dialog: service(),
    shouldDisplay: true,
    location: '',
    buttonClass: 'btn-primary user-card-chat-btn btn-icon-text',
    
    init() {
        this._super(...arguments);
        this.show(this.getTargetUser());
    },

    show(user) {
        if (
            user.id === -1 || 
            user.id === this.currentUser.id
        ) this.set("shouldDisplay", false);
    },

    getTargetUser() {
        let user;

        switch (this.location) {
            case "profile-view":
                user = {
                    id: this.model.id,
                    username: this.model.username
                };

                this.set("buttonClass", "btn-default");
                break;
            case "profile-popup":
                user = {
                    id: this.parentView.user.id,
                    username: this.parentView.user.username
                };

                break;     
            default:
                user = {
                    id: this.currentUser.id,
                    username: this.currentUser.username
                };

                break; 
        }

        return user;
    },

    @action
    toggleModal() {
        showModal("tipModal").set("user", this.getTargetUser());
    }, 
});
