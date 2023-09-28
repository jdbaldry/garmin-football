import Toybox.Lang;
import Toybox.WatchUi;

class AssistMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId().toString() as String;

        EVENTS.add(new HelpEvent(id));

        popView(SLIDE_IMMEDIATE);
        popView(SLIDE_IMMEDIATE);
        popView(SLIDE_IMMEDIATE);
    }

    function onBack() as Void {
        popView(SLIDE_IMMEDIATE);
        popView(SLIDE_IMMEDIATE);
        popView(SLIDE_IMMEDIATE);
    }
}
