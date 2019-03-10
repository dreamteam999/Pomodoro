# Pomodoro

Current ready-status is: dry noodles.

A simple Pomodoro timer designed with eOS and Pantheon in mind.

### The Pomodoro Technique

 1. Decide on the task to be done.
 2. Set the pomodoro timer to `n` minutes (traditionally n = 25). This is the length of one pomodoro, or `pom`.
 3. Work on the task until the timer rings. If a distraction pops into your head, write it down for later, but then *immediately* get back on task.
 4. When the timer at the `n` minute mark rings, amrk that you have completed one `pom`.
 5. If you have fewer than four `poms`, take a short break (3–5 minutes), start a new `pom`.
 6. After four pomodoros, take a long break (15–30 minutes). It’s a good idea to get away maybe go on a walk during long breaks. Reset the `pom` counter and start over.

### Building a Timer obj

 * Timer
    * 
    * string: timername
    * string: alarmname (path to alarm sound)
    * double: timeleft
    * int:    position in timer stack (1-NaN)
    * int:    pomodoro's completed (1-4)
    * struct containing an enum for one of 25/30/60 `pomodoro` sizes
    * struct containing four break timer values 5/10 for short, 30/40 for long

See [glib.Timer](https://developer.gnome.org/glib/stable/glib-Timers.html)

### Building a Layout

I suspect we will have to build a `gtk.GridView` containing `gtk.Widget`s which contain:
 * a "clock" `gicon`
 * the title of a task (can be blank by default but updated from a textbox widget)
 * the number of `pomodoro`s completed
 * the time left in the current `pomodoro`

### What do we want in settings?

[Building the Menu](https://valadoc.org/gtk+-3.0/Gtk.MenuButton.html)

 * Cancel current timer
 * Trinary widget for Pomodoro size
 * Trinary widget for short break sizes
 * Trinary widget for long break sizes (consider tying the long/short break denominations together forcing 25/5:30, 30/10:40. 

### Etc

* [Glib Basic Types](https://developer.gnome.org/glib/unstable/glib-Basic-Types.html#gchar)
* [Cleaning gsettings](https://askubuntu.com/posts/582663/revisions)
* [Dconf/Gsettings Brief](https://askubuntu.com/questions/22313/what-is-dconf-what-is-its-function-and-how-do-i-use-it)
* [GTK2 Events](http://zetcode.com/gui/gtk2/gtkevents/)
* [GTK Buton With Label](https://developer.gnome.org/gtk3/stable/GtkButton.html#gtk-button-set-label)
* [labelsettext()](https://developer.gnome.org/gtk3/stable/GtkLabel.html#gtk-label-set-text)
* [Signals and Callbacks Ref](https://developer.gnome.org/gtk-tutorial/stable/x159.html)
* [ELEMENTARY OS: Developer Guide (Getting Started)](https://elementary.io/docs/code/getting-started#getting-started)
* [Setting background colors in GTK+ 3.0+ (Example)](https://mail.gnome.org/archives/gtk-app-devel-list/2016-August/msg00021.html)
* [Using timers (GLib, Vala)](https://valadoc.org/glib-2.0/GLib.Timer.html)
