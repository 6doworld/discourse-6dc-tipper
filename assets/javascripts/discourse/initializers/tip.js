import { withPluginApi } from 'discourse/lib/plugin-api';
// import { iconHTML } from "discourse-common/lib/icon-library";
import showModal from 'discourse/lib/show-modal';
import TipModalComponent from '../components/modal/tip-modal';
import { inject as service } from "@ember/service";

import TipPostMenuButton from "../components/tip-post-menu-button";

export default {
    name: 'tip',
    initialize(owner) { 
        Number.prototype.countDecimals = function () { if(Math.floor(this.valueOf()) === this.valueOf()) return 0; return this.toString().split(".")[1].length || 0; }
    
        // Old method - deprecated

        // withPluginApi('0.1', api => {             
        //     api.attachWidgetAction('post', 'showTipModal', function () {
        //         owner.lookup("service:modal").show(TipModalComponent, {
        //             model: {
        //                 user: {
        //                     id: this.attrs.user.id,
        //                     username: this.attrs.user.username
        //                 }
        //             }
        //         });
        //     });
                
        //     api.addPostMenuButton('tip', function (attrs) {
        //         if (api.getCurrentUser()) {
        //             if (
        //                 attrs.user.id === api.getCurrentUser().id || 
        //                 attrs.user.id === -1
        //             ) return {}
        //         } else {
        //             return {}
        //         }

        //         return {
        //             data: {
        //                 "post-id": attrs.id,
        //                 "user": attrs.username
        //             },
        //             action: 'showTipModal',
        //             icon: 'hand-holding-usd',
        //             className: 'tip-user',
        //             title: 'tip_icon_alt',
        //             position: 'first' // can be `first`, `last` or `second-last-hidden`
        //         };
        //     });
        // });

        // New method to register buttons to menu
        // Ref: https://github.com/discourse/discourse/blob/c64b5d6d7a2f2568c56a6aeef0b682d15bdb31ba/app/assets/javascripts/discourse/tests/integration/components/widgets/post-stream-test.gjs#L53
        withPluginApi('1.34.0', (api) => {
            api.registerValueTransformer(
                "post-menu-buttons",
                ({ value: dag, context: { post, firstButtonKey } }) => {
                    dag.add("tip-post-menu", TipPostMenuButton, {
                        before: firstButtonKey
                    })
                }
            )
        });
    }
};