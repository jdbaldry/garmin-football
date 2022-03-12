import Toybox.System;
import Toybox.WatchUi;

class FootballQuitMenuDelegate extends WatchUi.MenuInputDelegate {
    public function initialize() {
        MenuInputDelegate.initialize();
    }

    public function onMenuItem(action as Symbol) as Void {
        switch (action) {
        case :Yes:
            if ((activityState != ACTIVITY_STOPPED) && (activityState != ACTIVITY_NONE)) {
                var activityMenu = new WatchUi.Menu();
                activityMenu.setTitle("Activity");
                activityMenu.addItem("Stop", :Stop);
                WatchUi.pushView(activityMenu, new $.FootballActivityMenuDelegate(method(:quit)), WatchUi.SLIDE_UP);
            } else {
                System.exit();
            }
            break;
        case :No:
            break;
        default:
            throw new Lang.InvalidValueException();
        }
    }
}
