namespace Pomodoro {

public class Window : Gtk.ApplicationWindow {
    public static GLib.Settings settings;
    private const string LIGHT_MODE = "display-brightness-symbolic";
    private const string DARK_MODE = "weather-clear-night-symbolic";
    int hbtn_counter = 0;
    int i = 0;
    bool darkmode;
    double timeelapsed;
    double timelim = 25;
    //double timeleft;

    private Window window;

    public Window(Application app) {
        // TODO: Look into requesting position to stop window from jumping on open
        Object (application: application,
                height_request: 480,
                width_request: 800); //eliminate need to set size every start
        // TC: This has other side effects, such as making the above dimens the min size.
        // I don't consider this a bad thing, but in case we want the default size to be smaller
        // in the future, this is a good note to have
    }

    Gtk.Label minuteslabel;
    Gtk.Label secondslabel;

    construct {

        border_width = 10;
        //connect before_destroy() to window terminator
        delete_event.connect(e => {
            //return false;
            return before_destroy();
        });

        /*  Start Headerbar */
        /*                  */
        //add buttons for headerbar
        var miscbutton = new Gtk.Button.with_label("New Timer (0)");
        miscbutton.get_style_context().add_class("suggested-action");
        miscbutton.valign = Gtk.Align.CENTER; //center in HB

        // add icon button -> submenu/popup
        var menu_button = new Gtk.Button.from_icon_name("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        menu_button.valign = Gtk.Align.CENTER;

        //light/dark Granite.ModeSwitch
        var gtk_settings = Gtk.Settings.get_default ();
        var mode_switch = new Granite.ModeSwitch.from_icon_name (LIGHT_MODE, DARK_MODE);
        mode_switch.primary_icon_tooltip_text = "Light Mode";
        mode_switch.secondary_icon_tooltip_text = "Dark Mode";
        mode_switch.valign = Gtk.Align.CENTER;
        mode_switch.bind_property ("active", gtk_settings, "gtk_application_prefer_dark_theme");

        //initialize the headerbar
        var headerbar = new Gtk.HeaderBar ();
        headerbar.set_title("DreamTeam Pomodoro");
        headerbar.set_subtitle("What will you accomplish today?");
        headerbar.show_close_button = true;
        headerbar.pack_start(miscbutton); //push to  left of HB
        headerbar.pack_end (menu_button); //push to right of HB
        headerbar.pack_end (mode_switch);
        set_titlebar (headerbar); //activate the headerbar
        /* End Headerbar */
        /* Start MainWindow */
        //var minuteslabel = new Gtk.Label("00:");
        //var secondslabel = new Gtk.Label("00");
        minuteslabel.set_label("00:");
        secondslabel.set_label("00:");
        minuteslabel.get_style_context ().add_class ("h1");
        secondslabel.get_style_context ().add_class ("h1");

        var pomogrid = new Gtk.Grid ();
        pomogrid.attach(secondslabel, 0, 0, 3, 1);
        pomogrid.attach(minuteslabel, 1, 1, 3, 1);
        add(pomogrid);

        /*          BUTTON EVENTS                   */
        /* connect to miscbutton's "clicked" signal */
        miscbutton.clicked.connect (() => {
			// Emitted when the button has been activated:
            var timer = new GLib.Timer();
            timer.start();
            for(i = 0; i < timelim; i++) {
                timeelapsed = timelim - timer.elapsed();
                GLib.Timeout.add_seconds(1, () => {
                    updateTimer(timeelapsed);
                    //secondslabel.set_label(timeleft.to_string());                    
                    return true;
                });
            }
			miscbutton.label = "I was clicked (%d) times!".printf (++this.hbtn_counter);
		});
        //connect menu buton
        menu_button.clicked.connect (() => {
			// Emitted when the button has been activated:
            miscbutton.label = "Settings requested";
		});

        int posx = settings.get_int ("position-x");
        int posy = settings.get_int ("position-y");
        int winx = settings.get_int ("window-width");
        int winy = settings.get_int ("window-height");

        if (posx != -1 ||  posy != -1) {
            this.move(posx, posy);
        }
        if (winx != -1 || winy != -1) {
            this.resize (winx, winy);
        }
        //Recursively shows a widget, and any child widgets (if the widget is a container)
        show_all();
    } //construct

    public void startTimer() {}

    public void updateTimer(double timeelapsed) {
        double t = Math.ceil(timelim - timeelapsed);
            int m;
            int s;
            double r;
            time_to_ms(t, out m, out s, out r);
            updateTimerLabel(m, s);

    }

    public void updateTimerLabel(int m, int s) {
        minuteslabel.set_label(m.to_string());
        secondslabel.set_label(s.to_string());
    }

    public void time_to_ms (double t, out int m, out int s, out double remainder) {
        m = (int) t / 60;
        t = t % 60;
        s = (int) t;
        remainder = t - s;
    }

    // This function returns false by default, and has no default actions
    // Here, we hi-jack the function to add saving the window dimen/location to gsettings
    // so they can be re-loaded when the application is launched again.
    // Only after getting the current info and saving that info to gschema.xml does
    // the function return false and close the program as requested
    public bool before_destroy () {
        int width, height, x, y;
        //if(Pomo.Window.mode_switch(darkmode))
        get_size(out width, out height);
        get_position(out x, out y);
        settings.set_int("position-x", x);
        settings.set_int("position-y", y);
        settings.set_int("window-width", width);
        settings.set_int("window-height", height);
        if(darkmode) {
            settings.set_boolean("dark-mode", true);
        } else {
            settings.set_boolean("dark-mode", false); 
        }
        return false;
    }
}
} //namespace Pomodoro
