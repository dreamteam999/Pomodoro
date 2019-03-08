public class Pomodoro : Gtk.Application { //Pomodoro extends Gtk.Application class

    public Pomodoro() {
        Object(application_id: "com.github.DreamTeam999.Pomodoro", flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate() {

        //new window object as defined in Window.vala
        var window = new Pomo.Window(this);

        add_window(window);

    }

}
