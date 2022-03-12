import Toybox.System;
import Toybox.WatchUi;

class FootballCardMenuDelegate extends WatchUi.MenuInputDelegate {
    private var _team as Number;
    private var _card as Number;
    private var _callback as Method?;

    public function initialize(team as Number, card as Number, callback as Method?) {
        MenuInputDelegate.initialize();
        _team = team;
        _card = card;
        _callback = callback;
    }

    private function logCard(color as String, offender as Symbol) as Void {
        jsonLog(["event", "YC", "team", _team, "player", offender]);
    }

    public function onMenuItem(offender as Symbol) as Void {
        switch (_card) {
        case CARD_YELLOW:
            logCard("YC", offender);
            break;
        case CARD_RED:
            logCard("RC", offender);
            break;
        default:
            throw new Lang.InvalidValueException();
        }

        if (_callback != null) {
            _callback.invoke();
        }
    }
}
