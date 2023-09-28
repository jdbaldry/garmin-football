import Toybox.ActivityRecording;
import Toybox.Lang;
import Toybox.WatchUi;

class MatchMenuDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    Menu2InputDelegate.initialize();
  }

  private function beginMatch() as Void {
    var pre_0;
    pre_0 = 0;
    SCORE_A = pre_0;
    SCORE_B = pre_0;

    MATCH_STATE = 1;
    SESSION = ActivityRecording.createSession({
      :name => "Football",
      :sport => 7 as Toybox.ActivityRecording.Sport1,
      :subSport => pre_0 as Toybox.ActivityRecording.SubSport,
    });
    SESSION.start();

    EVENTS.add(new TimeEvent());
    EVENTS.add(new BeginEvent());
  }

  private function stopMatch() as Void {
    var pre_SESSION;
    pre_SESSION = SESSION;
    MATCH_STATE = 3;
    pre_SESSION.stop();
    pre_SESSION.save();
    SESSION = null;

    EVENTS.add(new StopEvent());
  }

  function onSelect(item as MenuItem) as Void {
    var pre_0, pre_1, pre_2;
    pre_2 = 2;
    pre_1 = 1;
    pre_0 = 0;
    switch (item.getId().toString() as String) {
      case "Begin":
        switch (MATCH_STATE) {
          case pre_0:
            beginMatch();

            popView(pre_0 as Toybox.WatchUi.SlideType);

            break;

          case 3:
            beginMatch();

            popView(pre_0 as Toybox.WatchUi.SlideType);

            break;

          case pre_2:
            MATCH_STATE = pre_1;
            SESSION.start();
            EVENTS.add(new BeginEvent());

            popView(pre_0 as Toybox.WatchUi.SlideType);

            break;
        }

        break;

      case "Pause":
        switch (MATCH_STATE) {
          case pre_1:
            MATCH_STATE = pre_2;
            SESSION.stop();
            EVENTS.add(new PauseEvent());

            popView(pre_0 as Toybox.WatchUi.SlideType);

            break;
        }

        break;

      case "Stop":
        switch (MATCH_STATE) {
          case pre_1:
            stopMatch();

            popView(pre_0 as Toybox.WatchUi.SlideType);

            break;

          case pre_2:
            stopMatch();

            popView(pre_0 as Toybox.WatchUi.SlideType);

            break;
        }

        break;

      case "Quit":
        pushView(
          new Confirmation("Quit?"),
          new QuitConfirmationDelegate(),
          pre_0 as Toybox.WatchUi.SlideType
        );

        break;
    }
  }
}
