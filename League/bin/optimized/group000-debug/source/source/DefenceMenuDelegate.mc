import Toybox.Lang;
import Toybox.WatchUi;

class DefenceMenuDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item as MenuItem) as Void {
    var pre_0;
    pre_0 = 0;
    switch (item.getId().toString() as String) {
      case "Tackle":
        EVENTS.add(new DefenceEvent("T"));

        popView(pre_0 as Toybox.WatchUi.SlideType);

        break;

      case "Foul":
        EVENTS.add(new DefenceEvent("F"));

        popView(pre_0 as Toybox.WatchUi.SlideType);

        break;

      case "Block":
        EVENTS.add(new DefenceEvent("B"));

        popView(pre_0 as Toybox.WatchUi.SlideType);

        break;
    }
  }
}
