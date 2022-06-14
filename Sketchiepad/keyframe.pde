

class KeyframeWindow {
    boolean interactable = true;
    boolean visible = false;
    Keyframe currentKeyframe;
    Keyframe startKeyframe = null;
    final float wi = 100.;
    Console console;

    public KeyframeWindow(Console c) {
        this.console = c;
    }

    public void showKeyframeWindow() {
        visible = true;
    }

    public void hideKeyframeWindow() {
        visible = false;
    }

    public void toggleVisible() {
        visible = !visible;
    }

    public void run(int frame) {
        Keyframe k = startKeyframe;
        float fpxl = (width/this.wi);
        if (visible) {
            stroke(sin(frameCount*0.1)*127+127);
            strokeWeight(1);
            line(width/2, 0, width/2, height);
        }
        while (k != null) {

            if (frame == k.getFrame()) {
                fill(color(255, 255, 255, 200));
            }
            else {
                fill(color(0, 255, 0, 200));
            }

            if (visible) {
                //Translate the position.
                float pos = fpxl*float(k.getFrame()-frame)+width/2.;

                float p = pos-10;
                float w = 20;
                
                noStroke();
                rect(p, height/2, w, w);

            }
            
            
            k = k.getNextKeyframe();
        }
    }

    public void newKeyframe(int f) {
        Keyframe k = new Keyframe(f);
        if (startKeyframe == null) {
            currentKeyframe = k;
            startKeyframe   = k;
            return;
        }
        currentKeyframe.append(k);
        currentKeyframe = k;
    }


}

class Keyframe {
    private int frame = 0;
    private Keyframe nextKeyframe;
    String name = "";


    public Keyframe(int frame, String n) {
        this.name = n;
        this.frame = frame;
    }

    public Keyframe getNextKeyframe() {
        return nextKeyframe;
    }

    public void append(Keyframe k) {
        nextKeyframe = k;
    }

    public int getFrame() {
        return frame;
    }

}

