import Toybox.System;
import Toybox.WatchUi;

class FootballQuitMenuDelegate extends WatchUi.MenuInputDelegate {
    public function initialize() {
        MenuInputDelegate.initialize();
    }

    public function onMenuItem(action as Symbol) as Void {
        switch (action) {
        case :Events:
            var menu = new WatchUi.Menu2({:title=>"Events"});
            var delegate;
            for (var i = 0; i < events.size(); i++) {
                menu.addItem(
                             new MenuItem(
                                          events[i].kind(),
                                          events[i].label(),
                                          "TODO",
                                          {}
                                          )
                             );
            }
            WatchUi.pushView(menu, new $.FootballEventsMenuDelegate(), WatchUi.SLIDE_UP);
            break;
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
