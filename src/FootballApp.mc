using Toybox.Application;
using Toybox.System;

class FootballApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
        System.println("Hello World");
    }

    function onStop(state as Dictionary?) as Void {}

    function getInitialView() as Array<Views or InputDelegates>?{
        return [new FootballView()] as Array<Views or InputDelegates>;
    }
}

function getApp() as FootballApp {
    return Application.getApp() as FootballApp;
}
