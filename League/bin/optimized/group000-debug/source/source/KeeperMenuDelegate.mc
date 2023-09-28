import Toybox.Lang;
import Toybox.WatchUi;

class KeeperMenuDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item as MenuItem) as Void {
    var pre_0;
    pre_0 = 0;
    switch (item.getId().toString() as String) {
      case "Save":
        EVENTS.add(new KeeperEvent("S"));

        popView(pre_0 as Toybox.WatchUi.SlideType);

        break;

      case "Concede":
        SCORE_B += 1;
        EVENTS.add(new KeeperEvent("C"));

        popView(pre_0 as Toybox.WatchUi.SlideType);

        break;

      case "Pass":
        EVENTS.add(new KeeperEvent("P"));

        popView(pre_0 as Toybox.WatchUi.SlideType);

        break;
    }
  }
}
