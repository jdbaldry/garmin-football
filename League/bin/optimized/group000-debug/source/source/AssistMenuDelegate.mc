import Toybox.Lang;
import Toybox.WatchUi;

class AssistMenuDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item as MenuItem) as Void {
    var pre_0;
    pre_0 = 0;
    item /*>id<*/ = item.getId().toString() as String;

    EVENTS.add(new HelpEvent(item /*>id<*/));

    popView(pre_0 as Toybox.WatchUi.SlideType);
    popView(pre_0 as Toybox.WatchUi.SlideType);
    popView(pre_0 as Toybox.WatchUi.SlideType);
  }

  function onBack() as Void {
    var pre_0;
    pre_0 = 0;
    popView(pre_0 as Toybox.WatchUi.SlideType);
    popView(pre_0 as Toybox.WatchUi.SlideType);
    popView(pre_0 as Toybox.WatchUi.SlideType);
  }
}
