import Toybox.Application;
import Toybox.System;

class FootballApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {}

    function onStop(state as Dictionary?) as Void {}

    function getInitialView() as Array<Views or InputDelegates>?{
        var view = new $.FootballView();
        var delegate = new $.FootballDelegate(view);
        return [view, delegate] as Array<Views or InputDelegates>;
    }
}
