import Component from "@ember/component";
import { inject as service } from "@ember/service";

import { action } from "@ember/object";
import showModal from "discourse/lib/show-modal";

export default Component.extend({
    tagName: "",
    dialog: service(),
    shouldDisplay: true,
    location: '',
    buttonClass: 'btn-primary user-card-chat-btn btn btn-icon-text',
    
    init() {
        this._super(...arguments);        
        this.set("buttonClass", this.setStyle());

        if (
            this.getTargetUser().id === -1 || 
            this.getTargetUser().id === this.currentUser.id
        ) {
            this.set("shouldDisplay", false);
        }
    },

    setStyle () {
        return (
            this.location === "profile-view" ?
            "btn btn-default" : "btn-primary user-card-chat-btn btn btn-icon-text"
        )
    },

    getTargetUser() {
        if (this.location === "profile-view") {            
            return {
                id: this.model.id,
                username: this.model.username
            }
        } else if (this.location === "profile-popup") {
            return {
                id: this.parentView.user.id,
                username: this.parentView.user.username
            }
        } else {
            return {
                id: this.currentUser.id,
                username: this.currentUser.username
            }
        }
    },

    @action
    toggleModal() {
        showModal("tipModal").set("user", this.getTargetUser());
    }, 
});
