namespace Pomodoro {
namespace Timer {

public class PTimer : Gtk.Grid {
    int POM_CONST = 25; //seconds for now
    int numPoms; 
    int i;
    private uint timeout_id;
    private int timeleft;
    GLib.Timer timer;

    public void startTimer () {
    //countdown_frame.get_style_context ().remove_class ("clocks-paused");
    //update_countdown_label (h, m, s);
    //timerstate = State.RUNNING;
        timer.start ();
        timeout_id = GLib.Timeout.add(40, () => {
	        /*if (state != State.RUNNING) {
                timeout_id = 0;
                return false;
            }*/

            var e = timer.elapsed ();
            if (e >= timeleft) {
                //reset ();
                //ring ();
                timeout_id = 0;
                return false;
            }
            //update_countdown (e);
            return true;
        });

        int lim = POM_CONST;
        timer.start();
        //timeLeft = POM_CONST        
        for(i = 0; i < lim; i++) {
             //create/start timer
            lim = lim - 1;
            //leave it counting down
            
            //g_timeout_add_seconds(1, gtk_label_set_text(ptimerLabel, lim)); //tick each second
        }
    }

    void stopTimer() {
        //take an existing timer
        //check if timer doesn't exist
        //run timerstop, reset the timer to POM_CONST
        timer.stop();
    }

    construct {
        var ptimerLabel = new Gtk.Label ("00:00");
        // make themeable in app.css
        ptimerLabel.get_style_context ().add_class ("h1");
        var ptimer = new GLib.Timer();
        this.attach(secondslabel, 0, 0, 3, 1);
        add(this);
        ptimer.start();
    }

}

} //namespace Timer
} //namespace Pomodoro
