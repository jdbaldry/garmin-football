import Toybox.System;
import Toybox.WatchUi;

class FootballKeeperMenuDelegate extends WatchUi.MenuInputDelegate {
    private var _team as Number;
    private var _callback as Method;

    public function initialize(team as number, callback as Method?) {
        MenuInputDelegate.initialize();
        _team = team;
        _callback = callback;
    }

    public function onMenuItem(keeper as Symbol) as Void {
        // Event must be created before the keeper is set because it
        // suppresses premature logging of initial keepers which is instead
        // handled by a callback.
        new KeeperEvent(_team, keeper);

        switch (_team) {
        case TEAM_A:
            aKeeper = keeper;
            break;
        case TEAM_B:
            bKeeper = keeper;
            break;
        default:
            throw new Lang.InvalidValueException(_team);
        }

        if (_callback != null) {
            _callback.invoke();
        }
    }
}
