import java.lang.reflect.Method;
import java.util.LinkedList;
import java.util.Arrays;
import java.nio.ByteBuffer;


//The usage of print, warning and error
//Print is used to print general information used for debugging. It should be used for all expected behaviour.
//Warning is used when the system encounters a problem that may make it act in a way that is not expected. It should only be used when something is broken, NOT for general information.
//Error is used when the system CANNOT perform a specific task due to a problem in the system. If it can perform an alternative action to compensate, you should warn instead.

class SketchieEngine {
  
  private boolean editMode = false;
  private boolean buttonDown = false;
  private boolean displayUI = true;
  private boolean playing = true;
  private boolean calledMusic = false;
  private Beat music;
  private boolean exitWhenMusicEnds = false;
  public Render draw;
  private HashMap<String, Integer> spriteNames;
  private ArrayList<Sprite> sprites;
  private Sprite selectedSprite;
  private Stack<Sprite> selectedSprites;
  private Click generalClick;
  private Stack<Sprite> spritesStack;
  private int newSpriteX = 0, newSpriteY = 0, newSpriteZ = 0;
  private float beatTempo = 120;
  private float beatVol = 1.0;
  private Sprite unusedSprite;
  private KeyframeWindow keyframeWindow;
  
  public Console console;
  
  public SketchieEngine(int w, int h) {
    draw = new Render(w, h);
    this.ready();
  }
  
  public SketchieEngine(int w) {
    draw = new Render(w);
    this.ready();
  }
  
  public SketchieEngine(float scale) {
    draw = new Render(scale);
    this.ready();
  }
  
  private void ready() {
    this.console = new Console();
    this.keyframeWindow = new KeyframeWindow(this.console);
    draw.setConsole(console);
    unusedSprite = new Sprite("UNUSED", draw);
    spriteNames = new HashMap<String, Integer>();
    sprites = new ArrayList<Sprite>();
    spritesStack = new Stack<Sprite>();
    selectedSprites = new Stack<Sprite>();
    generalClick = new Click();
    draw.loadAllShaders();
  }
  
  private String cutChar(String str, int index) {
    return str.substring(0, index) + str.substring(index+1);
  }

  public void loadKeyframesFrom(String path) {
    keyframeWindow = new KeyframeWindow(this.console, path);
  }

  public boolean keyframe(String name) {
    if (!playing()) {
      return false;
    }
    return keyframeWindow.keyframe(name);
  }
  
  private void syncMusic() {
    if (music != null) {
      music.syncMusic(draw.getFramerate(), draw.getFramecount());
      //log(int(draw.getFramerate()));
      if (this.exitWhenMusicEnds && playheadInSeconds() > music.duration()) {
        exit();
      }
    }
    else if (loadedMusic != null) {
      music = new Beat(loadedMusic, beatTempo);
      music.beginMusic();
      music.setMusicVol(beatVol);
      console.log("Music loaded.");
    }
    else if (calledMusic && frameCount == 60) {
      console.log("Music is taking a little while to load, but we're workin' on it!");
    }
  }
  
  public float playheadInSeconds() {
    return (draw.framecount/draw.framerate);
  }
  
  public void playMusic() {
    if (music == null) {
      console.warn("Music not loaded.");
    }
    else {
      music.beginMusic();
      this.calledMusic = true;
    }
  }
  
  public void playMusic(String musicName, float tempo) {
    if (music == null) {
      musicFileName = musicName;
      beatTempo = tempo;
      thread("loadMusic");
      this.calledMusic = true;
    }
  }
  
  public void playMusic(String musicName, float tempo, float vol) {
    playMusic(musicName, tempo);
    beatVol = vol;
  }
  
  public int beatFramecount() {
    return music != null ? music.beatToFrameCount(music.totalBeats()) : 0;
  }
  
  public boolean beat() {
      return music != null ? music.flashBeat() : false;
  }
  
  public boolean step() {
    return music != null ? music.flashStep() : false;
  }
  
  public boolean beatDelay() {
    return music != null ? music.flashBeat(1, 2) : false;
  }
  
  public boolean halfBeat() {
    return music != null ? music.flashStep(2, 4) : false;
  }
  
  public boolean doubleBeat() {
    return music != null ? music.flashBeat(2, 1) : false;
  }
  public boolean doubleBeatDelay() {
    return music != null ? music.flashBeat(2, 2) : false;
  }
  public boolean customBeat(int interval, int offset) {
    return music != null ? music.flashBeat(interval, offset) : false;
  }
  public boolean customStep(int interval, int offset) {
    return music != null ? music.flashStep(interval, offset) : false;
  }
  
  
  public int totalBeats() {
    return music != null ? music.totalBeats() : 0;
  }
  
  public int totalSteps() {
    return music != null ? music.totalSteps() : 0;
  }
  
  
  
  public void exitWhenMusicEnds() {
    this.exitWhenMusicEnds = true;
  }
  
  public void hideUI() {
    console.log("The user UI is hidden.");
    this.displayUI = false;
  }
  public void showUI() {
    console.log("The user UI is now shown.");
    this.displayUI = true;
  }
  private boolean draggingSquare = false;
  private boolean showKeyframes = false;
  private boolean mmuted = false;
  
  private boolean keyPressAllowed = true;
  String lastKeyframeName = "";
  private void keyPress() {
    if (this.displayUI && keyPressAllowed) {
      if (keyPressed && !buttonDown) {
        buttonDown = true;
        if (key == 'q') {
          keyframeWindow.toggleVisible();
        }
        if (keyCode == LEFT) {
          console.log("Frame (before seek): "+draw.framecount);
          draw.changeFramecount(-int(draw.framerate*2));
        }
        if (keyCode == RIGHT) {
          console.log("Frame (before seek): "+draw.framecount);
          draw.changeFramecount(int(draw.framerate*2));
        }
        if (key == 'x') {
          selectedSprite = null;
        }
        if (key == '.') {
          console.log("Frame (before seek): "+draw.framecount);
          draw.changeFramecount(1);
        }
        if (key == ',') {
          console.log("Frame (before seek): "+draw.framecount);
          draw.changeFramecount(-1);
        }
        if (key == 'e') {

        }          
        if (key == 't') {
          
        }
        if (key == 'a') {
          keyPressAllowed = false;
          globalKeyboardMessage = "";
          if (playing()) {
            pause();
          }
          keyframeWindow.keyframePrompt();
        }
        if (key == 's') {
          if (lastKeyframeName.length() == 0) {
            console.log("No keyframe was created.");
          }
          else {
            //Create a new keyframe with the same name as the last keyframe created.
            keyframeWindow.saveKeyframe(keyframeWindow.newKeyframe(draw.framecount, lastKeyframeName)); 
            log("Keyframe "+lastKeyframeName+" created.");
          }
          
        }
        if (key == ' ') {
          togglePlayPause();
          if (!playing()) {
            console.log("Frame: "+draw.framecount);
          }
        }
        if (key == 'm') {
          mmuted = !mmuted;
          if (mmuted) {
            this.music.unmute();
          } 
          else {
            this.music.mute();
          }
        }
        
        //Set sprite modes
        if (selectedSprite != null) {
          if (!selectedSprite.isLocked()) {
            switch (key) {
              case 'o':
                selectedSprite.setMode(Transform.SINGLE);
                console.log("Sprite mode set: SINGLE");
              break;
              case 'p':
                selectedSprite.setMode(Transform.DOUBLE);
                console.log("Sprite mode set: DOUBLE");
              break;
              case '[':
                selectedSprite.setMode(Transform.VERTEX);
                selectedSprite.createVertices();
                console.log("Sprite mode set: VERTEX");
              break;
              case ']':
                selectedSprite.setMode(Transform.ROTATE);
                selectedSprite.setRadius(selectedSprite.getWidth()/2);
                console.log("Sprite mode set: ROTATE");
              break;
            }
            selectedSprite.updateJSON();
          }
          
          if (key == 'l') {
            if (selectedSprite.isLocked()) {
                selectedSprite.unlock();
                console.log("Sprite unlocked");
              }
              else {
                selectedSprite.lock();
                console.log("Sprite locked");
              }
              selectedSprite.updateJSON();
          }
        }   
        
      }
      if (!keyPressed && !mousePressed && buttonDown) {
        buttonDown = false;
      }
      
      if (keyPressed && key == 'w') {
        console.force();
        console.killLines();
      }

      // if (!playing()) {
      //   if (keyPressed && key == 'm') {
      //       this.music.unmute();
      //   }
      //   else {
      //       this.music.mute();
      //   }
      // }
      
    }
  }
  public boolean editMode() {
    return editMode;
  }
  public boolean playing() {
    return this.playing;
  }
  public void play() {
    this.playing = true;
    if (music != null) {
      this.music.unmute();
    }
  }
  public void pause() {
    this.playing = false;
    if (music != null) {
      this.music.mute();
    }
  }
  public void togglePlayPause() {
    if (this.playing) {
      this.pause();
    }
    else {
      this.play();
    }
  }
  
  public void renderSprites() {
    for (Sprite s : sprites) {
      draw.setAddMode();
      renderSprite(s);
      draw.setNormalMode();
    }
  }
  
  public void renderSprite(String name, String img) {
    Sprite s = getSprite(name);
    s.setImg(img);
    renderSprite(s);
  }
  
  public void renderSprite(String name) {
    Sprite s = sprites.get(spriteNames.get(name));
    renderSprite(s);
  }
  
  public Sprite getSprite(String name) {
    try {
      return sprites.get(spriteNames.get(name));
    }
    catch (NullPointerException e) {
      console.warn("Sprite "+name+" does not exist.");
      return unusedSprite;
    }
  }
  
  private void renderSprite(Sprite s) {
    if (s.equals(selectedSprite) || (keyPressed && key == 'r' && keyPressAllowed)) {
      draw.showWireframe();
      String txt = s.getName() + "   x:" + str((int)s.getX()) + " y:" + str((int)s.getY());
      draw.txt(txt, s.getX()*draw.getScaleX()*1., s.getY()*draw.getScaleY() - 5., 12.);
    }
    draw.zPosition(s.getZ());
    //draw.autoImg(s.getImg(), s.getX(), s.getY()+s.getHeight()*s.getBop(), s.getWidth(), s.getHeight()-int((float)s.getHeight()*s.getBop()));
    
    switch (s.mode) {
      case SINGLE:
      draw.autoImg(s.getImg(), s.getX(), s.getY()+s.getHeight()*s.getBop(), s.getWidth(), s.getHeight()-int((float)s.getHeight()*s.getBop()));
      break;
      case VERTEX:
      draw.autoImgVertex(s);
      break;
      case ROTATE:
      draw.autoImgRotate(s);
      break;
    }
    draw.hideWireframe();
    s.poke(draw.getFramecount());
  }
  
  private void setLayer(String name, float z) {
    this.spriteWithName(name).setZ(z);
  }
  
  public void updateSpriteFromJSON(Sprite s) throws NullPointerException {
      JSONObject att = loadJSONObject(PATH_SPRITES_ATTRIB+s.getName()+".json");
      s.move(att.getInt("x"), att.getInt("y"));
      s.setWidth(att.getInt("w"));
      s.setHeight(att.getInt("h"));
      
      s.setModeString(att.getString("mode"));
      if (att.getBoolean("locked")) {
        s.lock();
      }
      
      for (int i = 0; i < 4; i++) {
        s.vertex.v[i].set(att.getInt("vx"+str(i)), att.getInt("vy"+str(i)));
        s.defvertex.v[i].set(att.getInt("vx"+str(i)), att.getInt("vy"+str(i)));
      }
  }
  
  private int totalSprites = 0;
  
  public void addSprite(String identifier, String img) {
    Sprite newSprite = new Sprite(identifier, draw);
    newSprite.setImg(img);
    newSprite.setOrder(++totalSprites);
    addSprite(identifier, newSprite);
    try {
      updateSpriteFromJSON(newSprite);
    }
    catch (NullPointerException e) {
      newSprite.move(newSpriteX, newSpriteY);
      newSprite.setZ(newSpriteZ);
      newSpriteX += 20;
      newSpriteY += 20;
      newSpriteZ += 20;
      newSprite.createVertices();
    }
    
    
    
    
  }
  
  public void emptySpriteStack() {
    spritesStack.empty();
  }
  
  public void sprite(String identifier, String img) {
    if (!spriteExists(identifier)) {
      addSprite(identifier, img);
    }
    Sprite s = getSprite(identifier);
    s.setImg(img);
    spritesStack.push(s);
    renderSprite(s);
  }
  
  public void bop(String identifier, float b) {
    if (!spriteExists(identifier)) {
      addSprite(identifier, "");
    }
    Sprite s = getSprite(identifier);
    s.bop(b);
  }
  
  public void resetBop(String identifier) {
    if (!spriteExists(identifier)) {
      addSprite(identifier, "");
    }
    Sprite s = getSprite(identifier);
    s.resetBop();
  }
  
  private void addSprite(String name, Sprite sprite) {
    sprites.add(sprite);
    spriteNames.put(name, sprites.size()-1);
  }
  
  private Sprite spriteWithName(String name) {
    return sprites.get(spriteNames.get(name));
  }
  public void newSprite(String name) {
    Sprite sprite = new Sprite(name, this.draw);
    this.addSprite(name, sprite);
  }
  public void newSprite(String name, String img) {
    Sprite sprite = new Sprite(name, this.draw);
    sprite.setImg(img);
    this.addSprite(name, sprite);
  }
  public void newSprite(String name, String img, float x, float y) {
    Sprite sprite = new Sprite(name, this.draw);
    sprite.setImg(img);
    sprite.move(x,y);
    this.addSprite(name, sprite);
  }
  public void newSprite(String name, String img, float x, float y, int w, int h) {
    Sprite sprite = new Sprite(name, this.draw);
    sprite.setImg(img);
    sprite.move(x,y);
    sprite.setWidth(w);
    sprite.setHeight(h);
    this.addSprite(name, sprite);
  }
  
  public void lock(String sprite) {
    this.spriteWithName(sprite).lock();
  }
  public void unlock(String sprite) {
    this.spriteWithName(sprite).unlock();
  }
  
  public boolean spriteExists(String identifier) {
    return (spriteNames.get(identifier) != null);
  }
  
  private void runSpriteInteraction() {
    
    if (this.displayUI) {
      if (selectedSprite != null) {
        if (!selectedSprite.beingUsed(draw.framecount)) {
          selectedSprite = null;
        }
      }
      
      boolean hoveringOverAtLeast1Sprite = false;
      boolean clickedSprite = false;
      
      for (int i = 0; i < spritesStack.size(); i++) {
        Sprite s = spritesStack.peek(i);
        if (s.equals(selectedSprite)) {
          if (s.mouseWithinHitbox()) {
             hoveringOverAtLeast1Sprite = true;
          }
          if (!s.isLocked()) {
            s.resizeSquare();
            s.dragReposition();
          }
        }
        else if (s.mouseWithinHitbox()) {
          hoveringOverAtLeast1Sprite = true;
          if (generalClick.clicked()) {
            selectedSprites.push(s);
            clickedSprite = true;
          }
        }
      }
      //Sort through the sprites and select the front-most sprite (sprite with the biggest zpos)
      if (clickedSprite && selectedSprites.size() > 0) {
        boolean performSearch = true;
        if (selectedSprite != null) {
          if (selectedSprite.mouseWithinHitbox()) {
            performSearch = false;
          }
          
          if (selectedSprite.isDragging()) {
            performSearch = false;
          }
        }
        
        if (performSearch) {
          int highest = selectedSprites.top().getOrder();
          Sprite highestSelected = selectedSprites.top();
          for (int i = 0; i < selectedSprites.size(); i++) {
            Sprite s = selectedSprites.peek(i);
            if (s.getOrder() > highest) {
              highest = s.getOrder();
              highestSelected = s;
            }
          }
          selectedSprite = highestSelected;
          selectedSprites.empty();
        }
      }
      
      if (!hoveringOverAtLeast1Sprite && generalClick.clicked()) {
        selectedSprite = null;
      }
    
    }
  }
  
  
  public void engine() {
    if (!console.basicui.displayingWindow()) {
      this.keyPress();
    }
    this.syncMusic();
    this.generalClick.update();
    this.runSpriteInteraction();
    console.display(this.displayUI);
    if (!this.displayUI) {
      this.keyframeWindow.hideKeyframeWindow();
    }
    this.keyframeWindow.run(draw.framecount);
    if (keyframeWindow.promptIsComplete()) {
      this.keyPressAllowed = true;
      console.log(globalKeyboardMessage);
      lastKeyframeName = globalKeyboardMessage;
    }
    if (console.basicui.displayingWindow()) {
      console.basicui.display();
      playing = false;
      if (music != null)
        music.mute();
      if (keyPressed && key == 'x' && keyPressAllowed) {
        console.basicui.stopDisplayingWindow();
        playing = true;
        if (music != null)
          music.unmute();
      }
    }
    
  }
}
