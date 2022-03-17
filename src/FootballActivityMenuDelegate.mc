import Toybox.Application;
import Toybox.System;
import Toybox.WatchUi;

class FootballActivityMenuDelegate extends WatchUi.MenuInputDelegate {
    private var _callback as Method?;

    public function initialize(callback as Method?) {
        MenuInputDelegate.initialize();
        _callback = callback;
    }

    public function onMenuItem(item as Symbol) as Void {
        switch (item) {
        case :Start:
            if (activityState == ACTIVITY_STOPPED) {
               aScore = 0;
               bScore = 0;
            }

            if (bKeeper == null) {
                WatchUi.pushView(bMenu, new $.FootballKeeperMenuDelegate(TEAM_B, method(:startActivityIfKeepersAreSet)), WatchUi.SLIDE_UP);
            }
            if (aKeeper == null) {
                WatchUi.pushView(aMenu, new $.FootballKeeperMenuDelegate(TEAM_A, method(:startActivityIfKeepersAreSet)), WatchUi.SLIDE_UP);
            }
            break;
        case :Pause:
            if (session != null) {
                if (session.isRecording()) {
                    session.stop();
                    activityState = ACTIVITY_PAUSED;
                    aKeeper = null;
                    bKeeper = null;
                    jsonLog(["event", "A", "value", "paused"]);
                }
            }
            break;
        case :Stop:
            if (session != null) {
                if (session.isRecording()) {
                    session.stop();
                    jsonLog(["event", "A", "value", "stopped"]);
                }
                session.save();
                jsonLog(["event", "A", "value", "saved"]);
                activityState = ACTIVITY_STOPPED;
                session = null;
            }
            break;
        default:
            throw new Lang.InvalidValueException();
        }
        if (_callback != null) {
            _callback.invoke();
        }
    }
}
