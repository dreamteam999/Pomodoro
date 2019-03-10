public class Pomodoro : Gtk.Application { //Pomodoro extends Gtk.Application class
    public static GLib.Settings settings;

    public Pomodoro () {
        Object(application_id: "com.github.DreamTeam999.Pomodoro", flags: ApplicationFlags.FLAGS_NONE);
    }

    static construct {
        //setup gsettings as a global obj
        settings = new GLib.Settings ("com.github.DreamTeam999.Pomodoro");
    }

    protected override void activate () {
        //new window object as defined in Window.vala
        var window = new Pomo.Window (this);
        var posx = settings.get_int ("position-x");
        var posy = settings.get_int ("position-y");
        var winx = settings.get_int ("window-width");
        var winy = settings.get_int ("window-height");

        if (posx != -1 ||  posy != -1)
            window.move(posx, posy); // TODO: this noticably moves window at startup
        if (winx != -1 || winy != -1)
            window.resize (winx, winy);
        //probably wont need this since we get sizing from gsettings now
        //window.window_position = Gtk.WindowPosition.CENTER;

        add_window (window);
    }

}

public static int main (string[] args) {
        // Create new Pomodoro object defined in Pomodoro.vala
        Pomodoro pomo = new Pomodoro ();
        return pomo.run (args);
}
