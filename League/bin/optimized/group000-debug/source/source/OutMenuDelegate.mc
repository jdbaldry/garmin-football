import Toybox.Lang;
import Toybox.WatchUi;

class OutMenuDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item as MenuItem) as Void {
    item /*>id<*/ = item.getId().toString() as String;

    EVENTS.add(new OutEvent(item /*>id<*/));

    popView(0 as Toybox.WatchUi.SlideType);
  }
}
