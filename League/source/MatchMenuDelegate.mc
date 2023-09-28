import Toybox.ActivityRecording;
import Toybox.Lang;
import Toybox.WatchUi;

class MatchMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    private function beginMatch() as Void {
        SCORE_A = 0;
        SCORE_B = 0;

        MATCH_STATE = MATCH_RECORDING;
        SESSION = ActivityRecording.createSession({
            :name => "Football",
            :sport => ActivityRecording.SPORT_SOCCER,
            :subSport => ActivityRecording.SUB_SPORT_GENERIC,
        });
        SESSION.start();

        EVENTS.add(new TimeEvent());
        EVENTS.add(new BeginEvent());
    }

    private function stopMatch() as Void {
        MATCH_STATE = MATCH_STOPPED;
        SESSION.stop();
        SESSION.save();
        SESSION = null;

        EVENTS.add(new StopEvent());
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId().toString() as String;

        switch (id) {
            case "Begin":
                switch (MATCH_STATE) {
                    case MATCH_NONE:
                        beginMatch();

                        popView(SLIDE_IMMEDIATE);

                        break;

                    case MATCH_STOPPED:
                        beginMatch();

                        popView(SLIDE_IMMEDIATE);

                        break;

                    case MATCH_PAUSED:
                        MATCH_STATE = MATCH_RECORDING;
                        SESSION.start();
                        EVENTS.add(new BeginEvent());

                        popView(SLIDE_IMMEDIATE);

                        break;
                }

                break;

            case "Pause":
                switch (MATCH_STATE) {
                    case MATCH_RECORDING:
                        MATCH_STATE = MATCH_PAUSED;
                        SESSION.stop();
                        EVENTS.add(new PauseEvent());

                        popView(SLIDE_IMMEDIATE);

                        break;
                }

                break;

            case "Stop":
                switch (MATCH_STATE) {
                    case MATCH_RECORDING:
                        stopMatch();

                        popView(SLIDE_IMMEDIATE);

                        break;

                    case MATCH_PAUSED:
                        stopMatch();

                        popView(SLIDE_IMMEDIATE);

                        break;
                }

                break;

            case "Quit":
                pushView(
                    new Confirmation("Quit?"),
                    new QuitConfirmationDelegate(),
                    SLIDE_IMMEDIATE
                );

                break;
        }
    }
}
