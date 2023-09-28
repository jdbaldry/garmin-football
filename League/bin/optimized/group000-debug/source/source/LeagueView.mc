using Toybox.Activity;
using Rez;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class LeagueView extends WatchUi.View {
  function initialize() {
    View.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.MainLayout(dc));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  // Update the view
  function onUpdate(dc as Dc) as Void {
    var pre___02d_, pre_2;
    pre_2 = 2;
    pre___02d_ = "%02d";
    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);

    dc.setColor(
      16777215 as Toybox.Graphics.ColorValue,
      0 as Toybox.Graphics.ColorValue
    );

    var now = System.getClockTime();
    dc.drawText(
      dc.getWidth() / pre_2,
      dc.getFontHeight(4 as Toybox.Graphics.FontDefinition),
      pre_2 as Toybox.Graphics.FontDefinition,
      now.hour.format(pre___02d_) +
        ":" +
        now.min.format(pre___02d_) +
        ":" +
        now.sec.format(pre___02d_),
      1 as Toybox.Graphics.TextJustification
    );

    dc.drawText(
      dc.getWidth() / pre_2,
      dc.getHeight() / pre_2,
      4 as Toybox.Graphics.FontDefinition,
      SCORE_A + " : " + SCORE_B,
      1 as Toybox.Graphics.TextJustification
    );

    if (MATCH_STATE != 0 && MATCH_STATE != 3) {
      pre___02d_ /*>timerTime<*/ = Activity.getActivityInfo().timerTime;
      if (pre___02d_ /*>timerTime<*/ != null) {
        dc.drawText(
          dc.getWidth() / pre_2,
          dc.getHeight() -
            dc.getFontHeight(pre_2 as Toybox.Graphics.FontDefinition),
          10,
          timerTimeToString(pre___02d_ /*>timerTime<*/),
          5
        );
      }
    }
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}
}
