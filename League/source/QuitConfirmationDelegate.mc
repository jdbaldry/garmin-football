import Toybox.System;
import Toybox.WatchUi;

class QuitConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response as Confirm) {
        if (response == CONFIRM_YES) {
            MATCH_STATE = MATCH_STOPPED;
            if (SESSION != null) {
                SESSION.stop();
                SESSION.save();
            }

            System.exit();
        }
    }
}
