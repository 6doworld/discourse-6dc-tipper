import Component from "@ember/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import TipModalComponent from "../components/modal/tip-modal";

export default class TipPostMenuButton extends Component {
    @service dialog;
    @service modal;

    init() {
        super.init(...arguments);
        this.show(this.getTargetUser());
    }

    show(user) {
        if (this.currentUser) {
            if (
                user.id === -1 ||
                user.id === this.currentUser.id
            ) this.set("shouldDisplay", false);
        } else {
            this.set("shouldDisplay", false);
        }
    }

    getTargetUser() {
        let user;

        if (!!!this.currentUser) return {
            id: -1,
            username: "system"
        }

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
    }

    @action
    async toggleModal() {
        this.modal.show(TipModalComponent, {
            model: { user: this.getTargetUser() }
        });
    }
}