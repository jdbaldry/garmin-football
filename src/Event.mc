public class Event {
    private var _event;

    public function initialize(event) {
        _event = event;
    }

    public function jsonLog() {
        throw new NotImplementedException("jsonLog");
    }
}

public class ActionEvent extends Event {
    private var _action;

    public function initialize(action) {
        Event.initialize("A")
        _action = action;
    }

    public function jsonLog() {
        $.jsonLog(["event", _event, "value", _action]);
    }
}

public class StartedEvent extends ActionEvent {
    public function initialize() {
        ActionEvent.initialize("started")
    }
}

public class PausedEvent extends ActionEvent {
    public function initialize() {
        ActionEvent.initialize("paused")
    }
}

public class StoppedEvent extends ActionEvent {
    public function initialize() {
        ActionEvent.initialize("stopped")
    }
}

public class KeeperEvent extends Event {
    private var _team;
    private var _player;

    public function initialize(team, player) {
        Event.initialize("K")
        _team = team;
        _player = player;
    }

    public function jsonLog() {
        $.jsonLog(["event", _event, "team", _team, "player", _player]);
    }
}

public class GoalEvent extends Event {
    private var _team;
    private var _player;
    private var _keeper;

    public function initialize(team, player) {
        Event.initialize("G")
        _team = team;
        _player = player;
        _keeper = keeper;
    }

    public function jsonLog() {
        $.jsonLog(["event", _event, "team", _team, "player", _player, "keeper", _keeper]);
    }
}

public class CaptainEvent extends Event {
    private var _team;
    private var _captain;

    public function initialize(team, captain) {
        Event.initialize("C")
        _team = team;
        _captain = captain;
    }

    public function jsonLog() {
        $.jsonLog(["event", _event, "team", _team, "player", _player]);
    }
}

public class TeamEvent extends Event {
    private var _team;
    private var _players;

    public function initialize(team, players) {
        Event.initialize("T")
        _team = team;
        _players = players;
    }

    public function jsonLog() {
        $.jsonLog(["event", _event, "team", _team, "players", _players]);
    }
}

public class OwnGoalEvent extends Event {
    private var _team;
    private var _player;
    private var _keeper;

    public function initialize(team, player) {
        Event.initialize("OG")
        _team = team;
        _player = player;
        _keeper = keeper;
    }

    public function jsonLog() {
        $.jsonLog(["event", _event, "team", _team, "player", _player, "keeper", _keeper]);
    }
}

public class CardEvent extends Event {
    private var _team;
    private var _player;

    public function initialize(event, team, player) {
        Event.initialize(event)
        _team = team;
        _player = player;
    }

    public function jsonLog() {
        $.jsonLog(["event", _event, "team", _team, "player", _player]);
    }
}

public class YellowCardEvent extends CardEvent {
    public function initialize(team, player) {
        CardEvent.initialize("YC", team, player)
    }
}

public class RedCardEvent extends Event {
    public function initialize(team, player) {
        CardEvent.initialize("RC", team, player)
    }
}
