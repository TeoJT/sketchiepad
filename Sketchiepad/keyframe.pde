

class KeyframeWindow {
    boolean interactable = true;
    boolean visible = false;
    boolean promptActive = false;
    boolean promptComplete = true;
    Keyframe currentKeyframe;
    Keyframe startKeyframe = null;
    final float wi = 100.;
    Console console;
    int sentThing = 0;
    JSONArray keyframeJSON;
    final String DEFAULT_KEYFRAMES = PATH_KEYFRAMES+"keyframes.json";
    String keyframesPath = "";
    Stack<String> triggeredKeyframes;

    float typeVel = 0.0;

    {
        triggeredKeyframes = new Stack<String>(20); //We'll go for a max of 20 for now.
    }

    public KeyframeWindow(Console c) {
        this.console = c;
        loadAllKeyframes(DEFAULT_KEYFRAMES);
        keyframesPath = DEFAULT_KEYFRAMES;
    }

    public KeyframeWindow(Console c, String path) {
        this.console = c;
        loadAllKeyframes(path);
        keyframesPath = path;
    }

    public void loadAllKeyframes(String path) {
        File f = new File(path);
        if (!f.exists()) {
            keyframeJSON = new JSONArray();
            return;
        }
        JSONObject json = loadJSONObject(path);
        keyframeJSON = json.getJSONArray("keyframes");
        for (int i = 0; i < keyframeJSON.size(); i++) {
            JSONObject k = keyframeJSON.getJSONObject(i); 

            newKeyframe(k.getInt("frame"), k.getString("name"));
        }
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

    public void keyframePrompt() {
        promptActive = true;
        visible = true;
    }

    public boolean promptIsActive() {
        return this.promptActive;
    }

    public boolean promptIsComplete() {
        return this.promptComplete;
    }

    public void saveKeyframe(Keyframe k) {
        JSONObject p = new JSONObject();

        p.setInt("frame", k.getFrame());
        p.setString("name", k.getName());

        keyframeJSON.setJSONObject(keyframeJSON.size(), p);

        JSONObject json = new JSONObject();
        json.setJSONArray("keyframes", keyframeJSON);
        saveJSONObject(json, keyframesPath);
    }

    public boolean keyframe(String name) {
        int i = 0;
        while (true) {
            try {
                if (triggeredKeyframes.peek(i++).equals(name)) {
                    return true;
                }
            }
            catch (StackException e) {
                return false;
            }
        }
    }

    public void run(int frame) {
        Keyframe k = startKeyframe;
        float fpxl = (width/this.wi);
        this.promptComplete = false;
        triggeredKeyframes.empty();
        float fadeinfadeout = sin(frameCount*0.1)*127+127;
        if (visible) {
            stroke(fadeinfadeout);
            strokeWeight(1);
            line(width/2, 0, width/2, height);

            if (promptActive) {
                if (globalKeyPressed) {
                    typeVel += 0.5;
                }
                if (globalEnter) {
                    this.promptComplete = true;
                    this.promptActive   = false;
                    saveKeyframe(newKeyframe(frame, globalKeyboardMessage));
                    console.log("New keyframe "+globalKeyboardMessage+" added.");
                }

                noStroke();
                fill(0, 100);
                float b = 20*typeVel;
                float w = 300, h = 100;
                float x = b*sin(frameCount), y = b*cos(frameCount);
                rect(width/2-w+x, height/2-h+y, w*2, h*2);
                fill(255);
                textAlign(CENTER, CENTER);
                textSize(20);
                text("Enter keyframe name:", width/2+x, height/2-h+20+y);
                textSize(42);
                text(globalKeyboardMessage, width/2+x, height/2+y);

                typeVel *= 0.90;
            }
        }
        while (k != null) {
            
            //Keyframe is triggered.
            if (frame == k.getFrame()) {
                fill(color(255, 255, 255, 200));
                triggeredKeyframes.push(k.getName());

                if (sentThing != frame) {
                    this.console.info("Keyframe "+k.getName()+" triggered.");
                    sentThing = frame;
                }
            }
            else {
                fill(color(0, 255, 0, 200));
            }

            if (visible) {
                //Translate the position.
                float pos = fpxl*float(k.getFrame()-frame)+width/2.;

                float p = pos-10;
                float w = 20;
                float h = height/2;
                
                noStroke();
                rect(p, h, w, w);
                fill(fadeinfadeout);
                textAlign(CENTER, CENTER);
                textSize(26);
                text(k.getName(), pos, h-20);


            }
            
            
            k = k.getNextKeyframe();
        }
    }

    public Keyframe newKeyframe(int f, String n) {
        Keyframe k = new Keyframe(f, n);
        if (startKeyframe == null) {
            currentKeyframe = k;
            startKeyframe   = k;
            return k;
        }
        currentKeyframe.append(k);
        currentKeyframe = k;
        return k;
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

    public String getName() {
        return this.name;
    }

}

