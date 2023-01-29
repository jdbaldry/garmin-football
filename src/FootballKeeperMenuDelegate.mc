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
        switch (_team) {
        case TEAM_A:
            events.add(new KeeperEvent(_team, keeper))
            break;
        case TEAM_B:
            events.add(new KeeperEvent(_team, keeper))
            break;
        default:
            throw new Lang.InvalidValueException(_team);
        }

        if (_callback != null) {
            _callback.invoke();
        }
    }
}
