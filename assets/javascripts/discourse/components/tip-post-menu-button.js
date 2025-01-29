import Component from "@ember/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import TipModalComponent from "../components/modal/tip-modal";

export default class TipPostMenuButton extends Component {
    @service dialog;
    @service modal;

    init() {
        super.init(...arguments);
        this.show(this.post.user);
        console.log(this);
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

    @action
    async toggleModal() {
        this.modal.show(TipModalComponent, {
            model: { 
                user: {
                    id: this.post.user.id,
                    username: this.post.user.name
                }
            }
        });
    }
}