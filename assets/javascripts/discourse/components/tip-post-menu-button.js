import Component from "@ember/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import TipModalComponent from "../components/modal/tip-modal";

export default class TipPostMenuButton extends Component {
    @service dialog;
    @service modal;

    init() {
        super.init(...arguments);
        this.show(this.attrs.post.value.user);
        console.log(this.attrs);
        console.log(this.attrs.post.value.user);
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
                    id: this.attrs.post.value.user.id,
                    username: this.attrs.post.value.user.username
                }
            }
        });
    }
}