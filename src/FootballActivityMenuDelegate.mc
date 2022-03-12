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
                WatchUi.pushView(new $.Rez.Menus.B(), new $.FootballKeeperMenuDelegate(TEAM_B, method(:popViewIfKeepersAreSet)), WatchUi.SLIDE_UP);
            }
            if (aKeeper == null) {
                WatchUi.pushView(new $.Rez.Menus.A(), new $.FootballKeeperMenuDelegate(TEAM_A, method(:popViewIfKeepersAreSet)), WatchUi.SLIDE_UP);
            }

            if (session == null) {
                session = ActivityRecording.createSession({
                    :name=>"Football",
                    :sport=>ActivityRecording.SPORT_GENERIC,
                    :subSport=>ActivityRecording.SUB_SPORT_GENERIC
                });
            }
            if (session.isRecording() == false) {
                session.start();
                activityState = ACTIVITY_RECORDING;
                log(join(["A", "started"], ","));
            }
            break;
        case :Pause:
            if (session != null) {
                if (session.isRecording()) {
                    session.stop();
                    activityState = ACTIVITY_PAUSED;
                    aKeeper = null;
                    bKeeper = null;
                    log(join(["A", "paused"], ","));
                }
            }
            break;
        case :Stop:
            if (session != null) {
                if (session.isRecording()) {
                    session.stop();
                    log(join(["A", "stopped"], ","));
                }
                session.save();
                log(join(["A", "saved"], ","));
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
