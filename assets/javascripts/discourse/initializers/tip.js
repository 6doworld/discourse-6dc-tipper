import { withPluginApi } from 'discourse/lib/plugin-api';
// import { iconHTML } from "discourse-common/lib/icon-library";
import showModal from 'discourse/lib/show-modal';

export default {
    name: 'tip',
    initialize() { 
        Number.prototype.countDecimals = function () { if(Math.floor(this.valueOf()) === this.valueOf()) return 0; return this.toString().split(".")[1].length || 0; }
             
        withPluginApi('0.1', api => {             
            api.attachWidgetAction('post', 'showTipModal', function () {
                showModal('tipModal')
                .set('user', {
                    id: this.attrs.user.id,
                    username: this.attrs.user.username
                });
            });
                
            api.addPostMenuButton('tip', function (attrs) {
                if (api.getCurrentUser()) {
                    if (
                        attrs.user.id === api.getCurrentUser().id || 
                        attrs.user.id === -1
                    ) return {}
                } else {
                    return {}
                }

                return {
                    data: {
                        "post-id": attrs.id,
                        "user": attrs.username
                    },
                    action: 'showTipModal',
                    icon: 'hand-holding-usd',
                    className: 'tip-user',
                    title: 'tip_icon_alt',
                    position: 'first' // can be `first`, `last` or `second-last-hidden`
                };
            });
        });
    }
};