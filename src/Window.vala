namespace Pomodoro {

public class Window : Gtk.ApplicationWindow {
    //public static GLib.Settings settings;
    private const string LIGHT_MODE = "display-brightness-symbolic";
    private const string DARK_MODE = "weather-clear-night-symbolic";
    bool darkmode;
    double timeelapsed;
    double timelim = 90; //minutes

    public Window(Application app) {
        // TODO: Look into requesting position to stop window from jumping on open
        Object (application: app, //app instance
                height_request: 600,
                width_request: 800); //eliminate need to set size every start
        // TC: Has other side effects, such as making the above dimens the min size.
        // I don't consider this a bad thing, but in case we want the default 
        // size to be smaller in the future, this is a good note to have
    }

    Gtk.Label minuteslabel; //we declare these globally Pomodoro namespace
    Gtk.Label secondslabel; //so that we can access them in member functions
    private GLib.Timer timer;

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
        var miscbutton = new Gtk.Button.with_label("Start Timer");
        miscbutton.get_style_context().add_class("suggested-action");
        miscbutton.valign = Gtk.Align.CENTER; //center in HB
        
        /* Settings Menu */
        // add icon button -> submenu/popup
        var menu_button = new Gtk.MenuButton(); //autoconnects a menu
        menu_button.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        menu_button.tooltip_text = "Menu";

        //and it's menu
        var menu_popover = new Gtk.Popover (menu_button);
        menu_button.popover = menu_popover;
        var tf_button = new Gtk.Button.with_label ("25");
        tf_button.tooltip_markup = Granite.markup_accel_tooltip (
            {"25min"},
            ("Pomodoro Length"));
        var to_button = new Gtk.Button.with_label ("30");
        tf_button.tooltip_markup = Granite.markup_accel_tooltip (
            {"30min"},
            ("Pomodoro Length"));
        var ff_button = new Gtk.Button.with_label ("45");
        tf_button.tooltip_markup = Granite.markup_accel_tooltip (
            {"45min"},
            ("Pomodoro Length"));

        var pomodoro_grid = new Gtk.Grid();
        pomodoro_grid.column_homogeneous = true;
        pomodoro_grid.hexpand = true;
        pomodoro_grid.margin = 12;

        pomodoro_grid.add (tf_button);
        pomodoro_grid.add (to_button);
        pomodoro_grid.add (ff_button);
        // break length buttons
        var tfb_button = new Gtk.Button.with_label ("3/15");
        tf_button.tooltip_markup = Granite.markup_accel_tooltip (
            {"3min Break"},
            ("15min Long Break"));
        var ftb_button = new Gtk.Button.with_label ("5/25");
        tf_button.tooltip_markup = Granite.markup_accel_tooltip (
            {"5min Break"},
            ("25min Long Break"));
        var ttb_button = new Gtk.Button.with_label ("10/30");
        tf_button.tooltip_markup = Granite.markup_accel_tooltip (
            {"10min Break"},
            ("30min Long Break"));

        var break_grid = new Gtk.Grid();
        break_grid.column_homogeneous = true;
        break_grid.hexpand = true;
        break_grid.margin = 12;
        
        break_grid.add(tfb_button);
        break_grid.add(ftb_button);
        break_grid.add(ttb_button);

        var reset_label = new Gtk.Label ("Reset Pomodoros");
        reset_label.halign = Gtk.Align.START;
        reset_label.hexpand = true;
        reset_label.margin_start = 3;
        reset_label.margin_end = 3;

        var quit_button = new Gtk.Button ();
        // makes button flat with menus css
        quit_button.get_style_context ().add_class (Gtk.STYLE_CLASS_MENUITEM);

        var reset_grid = new Gtk.Grid();
        reset_grid.column_homogeneous = true;
        reset_grid.hexpand = true;
        reset_grid.margin = 6;
        
        reset_grid.add (reset_label);
        quit_button.add (reset_grid);


        //popover separators
        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.margin_top = separator.margin_bottom = 3;
        var separator2 = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator2.margin_top = separator2.margin_bottom = 3;
        // connect all grids to the popover
        var menu_grid = new Gtk.Grid();
        menu_grid.margin_bottom = 3;
        menu_grid.width_request = 200;

        menu_grid.attach (pomodoro_grid, 0, 0);
        menu_grid.attach (separator, 0, 1);
        menu_grid.attach (break_grid, 0, 2);
        menu_grid.attach (separator2, 0, 3);
        menu_grid.attach (quit_button, 0, 4);
        menu_grid.show_all();

        menu_popover.add (menu_grid);
        /* End Settings Menu */

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
        minuteslabel = new Gtk.Label("00:");
        secondslabel = new Gtk.Label("00");
        minuteslabel.get_style_context ().add_class ("h1");
        secondslabel.get_style_context ().add_class ("h1");

        var pomogrid = new Gtk.Grid ();
        pomogrid.attach(minuteslabel, 0, 0, 1, 1); //col, row, colW, rowW
        pomogrid.attach(secondslabel, 1, 0, 1, 1);
        add(pomogrid); //commit the grid that was constructed

        /*          BUTTON EVENTS                   */
        /* connect to miscbutton's "clicked" signal */
        miscbutton.clicked.connect (() => {
			// Emitted when the button has been activated:
            timer = new GLib.Timer();
            timer.start();
            //this will run timeLeft every 1s until !timeLeft
            GLib.Timeout.add_seconds(1, timeLeft);//its more clear passing the function
			miscbutton.label = "Stop Timer";
		});
        /*connect menu buton
        menu_button.clicked.connect (() => { // Emitted when button clicked:
            //miscbutton.label = "Settings requested";
		});*/

        int posx = Application.settings.get_int ("position-x");
        int posy = Application.settings.get_int ("position-y");
        int winx = Application.settings.get_int ("window-width");
        int winy = Application.settings.get_int ("window-height");

        if (posx != -1 ||  posy != -1) {
            this.move(posx, posy);
        }
        if (winx != -1 || winy != -1) {
            this.resize (winx, winy);
        }
        //Recursively shows widgets, and any child widgets (if widget is container) 
        show_all();
    } //construct

    public void startTimer() {}

    public bool timeLeft() {
        timeelapsed = Math.ceil(timelim - timer.elapsed());
        stdout.printf("p-te: %f", timeelapsed);
        if(timeelapsed < 0) { //< lets the timer hit 0
            return false; } //call alarm
        updateTimer(timeelapsed);
        return true;
    }

    public void updateTimer(double timeelapsed) {
            double t = Math.ceil(timeelapsed);
            //db: stdout.printf("tlim: %d, te %d, t:%d\n", (int)timelim, (int)timeelapsed, (int)t);
            int m;
            int s;
            double r;
            time_to_ms(t, out m, out s, out r);
            //db: stdout.printf("time-ms: %d\n", (int)t);
            updateTimerLabel(m, s);
    }

    public void updateTimerLabel(int m, int s) {
        string tm = "%02d:".printf(m);
        string ts = "%02d".printf(s);
        minuteslabel.set_text(tm);
        secondslabel.set_text(ts);
    }
    //Derives time in 60's, modfied from gnome clocks
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
    // the function return false and close the program as requested\
    public bool before_destroy () {
        int width, height, x, y;
        //if(Pomo.Window.mode_switch(darkmode))
        get_size(out width, out height);
        get_position(out x, out y);
        Pomodoro.Application.settings.set_int("position-x", x);
        Pomodoro.Application.settings.set_int("position-y", y);
        Pomodoro.Application.settings.set_int("window-width", width);
        Pomodoro.Application.settings.set_int("window-height", height);
        if(darkmode) {
            Application.settings.set_boolean("dark-mode", true);
        } else {
            Application.settings.set_boolean("dark-mode", false); 
        }
        return false;
    }
}
} //namespace Pomodoro
