import Toybox.System;
import Toybox.WatchUi;

class QuitConfirmationDelegate extends WatchUi.ConfirmationDelegate {
  function initialize() {
    ConfirmationDelegate.initialize();
  }

  function onResponse(response as Confirm) {
    if (response == 1) {
      response /*>pre_SESSION<*/ = SESSION;
      MATCH_STATE = 3;
      if (response /*>pre_SESSION<*/ != null) {
        response /*>pre_SESSION<*/.stop();
        response /*>pre_SESSION<*/.save();
      }

      System.exit();
    }
  }
}
