import Toybox.System;
import Toybox.WatchUi;

class FootballCardMenuDelegate extends WatchUi.MenuInputDelegate {
    private var _card as Number;
    private var _callback as Method?;

    public function initialize(card as Number, callback as Method?) {
        MenuInputDelegate.initialize();
        _card = card;
        _callback = callback;
    }

    private function logCard(color as String, offender as Symbol) as Void {
        log(color + " card for " + offender.toString());
    }

    public function onMenuItem(offender as Symbol) as Void {
        switch (_card) {
        case CARD_YELLOW:
            logCard("Yellow", offender);
            break;
        case CARD_RED:
            logCard("Red", offender);
            break;
        default:
            throw new Lang.InvalidValueException();
        }

        if (_callback != null) {
            _callback.invoke();
        }
    }
}
