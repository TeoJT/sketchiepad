import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.io.File; 
import java.io.IOException; 
import java.awt.Desktop; 
import processing.sound.*; 
import java.lang.reflect.Method; 
import java.util.LinkedList; 
import java.util.Arrays; 
import java.nio.ByteBuffer; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Sketchiepad extends PApplet {







PApplet app;
boolean record = false;
SketchieEngine sketchie;
float framecount = 0;
boolean doneLoading = true;

public void settings() {
  System.setProperty("jogl.disable.openglcore", "false");
  size(frameWidth, frameHeight, P2D);
}
SoundFile sndNope;

public void setup() {
  loadingBar();
  app = this;
  sndNope = new SoundFile(app, PATH_SND_NOPE);
  sketchie = new SketchieEngine(renderScale);
  if (fastRendering) {
    sketchie.draw.enableFastRendering();
  }
  else {
    sketchie.draw.disableFastRendering();
  }
  if (interval != 1) {
    log("Note: Repositioning may not work properly at different speeds");
  }
  frameRate(framerate);
  sketchie.draw.setFramerate(framerate);
  background(0);
  log("Starting, please wait...");
  if (loadOnGo) {
    sketchie.draw.loadOnGo();
  }
  if (exitWhenMusicEnds) {
    exitWhenMusicEnds();
  }
  if (extraDebugInfo) {
    sketchie.console.enableDebugInfo();
  }
  if (rec) {
    record();
  }
}

public void draw() {
  background(clearColor);
  sketchie.emptySpriteStack();
  framecount = PApplet.parseFloat(sketchie.draw.getFramecount());
  if (frameCount == 2) {
    loadingBar();
    sketchie.draw.prepareLoadAllImages("data/img/");
    sketchie.draw.prepareLoadAllImages("data/engine/defaultimg/");
    ready();
    if (rec) {
      String FRAMES_FOLDER_DIR = "C:/mydata/temp/frames/";
       File directory = new File(FRAMES_FOLDER_DIR);
       if (!directory.exists()) {
         error("\"Frames\" directory not found.");
       }
       else {
         for (File file : directory.listFiles()) {
           file.delete();
         }
       }
    }
  }
  else if (frameCount > 2 && sketchie.draw.loading()) {
    loadingBar();
  }
  else if (frameCount > 2 && doneLoading) {
    doneLoading = false;
  }
  else if (frameCount > 2) {
    looper();
    sketchie.draw.loopRun();
  }
  sketchie.draw.display();
  if (sketchie.playing()) {
    if (frameCount % interval == 0) {
      sketchie.draw.nextFrame();
    }
  }
  resetShader();
  sketchie.engine();
  //if (record)
    //saveFrame("C:/My Data/Frames/######.tiff");
}
class Beat {
  private float bpm = 120;
  private SoundFile music;
  private int playhead;
  
  private int markBeat;
  private float vol;
  private int framecount;
  private float framerate = 60.0f;
  
  public Beat(SoundFile m, float bpm) {
    this.bpm = bpm;
    this.music = m;
  }
  
  public void beginMusic() {
    music.play();
    playhead = millis();
  }
  public void startPlaying() {
    beginMusic();
  }
  public void setMusicVol(float v) {
    vol = v;
    music.amp(v);
  }
  public void mute() {
    music.amp(0.0f);
  }
  public void unmute() {
    music.amp(vol);
  }
  
  public boolean isPlaying() {
    float currentTime = PApplet.parseFloat(millis()-playhead)/1000.0f;
    return (currentTime < this.music.duration());
  }
  
  public void syncMusic(float fr, int fc) {
    this.framecount = fc;
    this.framerate  = fr;
    float currentTime = PApplet.parseFloat(millis()-playhead)/1000.0f;
    float expectedDuration = fc/fr;
    float tolerance = 0.05f;
    if ((currentTime > expectedDuration+tolerance) || (currentTime < expectedDuration-tolerance)) {
      float difference = currentTime-expectedDuration;
      music.jump(currentTime-difference);
      playhead += PApplet.parseInt(difference*1000.0f);
    }
  }
  
  public float getPlayhead() {
    return playhead/1000.f;
  }
  
  public float duration() {
    return music.duration();
  }
  
  public void musicJumpAhead(float t) {
      float currentTime = PApplet.parseFloat(millis()-playhead)/1000.0f;
      float difference = currentTime-t;
      music.jump(currentTime-difference);
      playhead += PApplet.parseInt(difference*1000.0f);
  }
  
  
  private float myFrameCount() {
    return this.framecount-1;
  }
  
  
  private float framesPerBeat() {
    return ((this.framerate/(bpm/this.framerate))*2.f);
  }
  public int totalBeats() {
    return floor(myFrameCount()/framesPerBeat())+1;
  }
  public int beatToFrameCount(int beat) {
    return round(PApplet.parseFloat(beat-1)*framesPerBeat());
  }
  
  
  private float framesPerStep() {
    return ((this.framerate/(this.bpm/(this.framerate/4)))*2);
  }
  public int totalSteps() {
    return floor(myFrameCount()/framesPerStep())+1;
  }
  public int stepToFrameCount(int step) {
    return round(PApplet.parseFloat(step-1)*framesPerStep());
  }
  public int relativeStep() {
    return floor(myFrameCount()/framesPerStep())+5-this.totalBeats()*4;
  }
  
  public boolean flashBeat() {
    int offset = PApplet.parseInt(this.framerate);
    return ((myFrameCount()+offset) % framesPerBeat() < 1.0f);
  }
  public boolean flashStep() {
    int offset = PApplet.parseInt(this.framerate);
    return ((myFrameCount()+offset) % framesPerStep() < 1.0f);
  }
  public boolean flashBeat(int interval, int intervalDelay) {
    int offset = PApplet.parseInt(this.framerate);
    return (((myFrameCount()+offset) - (framesPerStep()*PApplet.parseFloat(intervalDelay)) ) % (framesPerBeat()*interval) < 1.0f);
  }
  public boolean flashStep(int interval, int intervalDelay) {
    int offset = PApplet.parseInt(this.framerate);
    return (((myFrameCount()+offset) - (framesPerStep()*PApplet.parseFloat(intervalDelay)) )%(framesPerStep()*interval) < 1.0f);
  }
  
  
  public void indicator() {
    if (this.flashBeat()) {
      fill(255);
    }
    else {
      fill(0);
    }
    noStroke();
    rect(30,30,20,20);
    
    if (this.flashStep()) {
      fill(255);
    }
    else {
      fill(0);
    }
    noStroke();
    rect(70,30,20,20);
    
    
    fill(255);
    sketchie.draw.txt(str(relativeStep()), 120, 40, 30);
  }
  
  
  private float fade = 0;
  private int col;
  private int depth;
  public void visualBeat(int interval, int intervalDelay, int depth, int col) {
    if (this.flashStep(interval, intervalDelay)) {
      fade = 1.0f;
      this.col = col;
      this.depth = depth;
    }
    
    renderVisualBeat();
  }
  
  public void visualBeatNow(int depth, int col) {
    fade = 1.0f;
    this.col = col;
    this.depth = depth;
  }
  
  public void renderVisualBeat() {
    strokeWeight(1);
    noFill();
    for (int x = 0; x < this.depth; x++) {
      float c = ((-PApplet.parseFloat(x)+this.depth)/PApplet.parseFloat(this.depth))*fade;
      stroke(this.col, c*255);
      rect(x,x,width-x*2,height-x*2);
    }
    fade *= 0.90f;
  }
  
  public void setMark() {
    markBeat = this.totalBeats();
  }
  
  public int fromMarkBeat() {
    return this.totalBeats()-markBeat;
  }
}
class Console {
  
  private ConsoleLine[] consoleLine;
  int timeout = 0;
  final static int messageDelay = 60;
  final static int totalLines = 60;
  final static int displayLines = 5;
  private int initialPos = 0;
  private boolean force = false;
  private boolean debugInfo = false;
  PFont consoleFont;
  public BasicUI basicui;
  
  private class ConsoleLine {
    private int interval = 0;
    private int pos = 0;
    private String message;
    private int messageColor;
    
    public ConsoleLine() {
      messageColor = color(255,255);
      interval = 0;
      this.message = "";
      this.pos = initialPos;
      basicui = new BasicUI();
    }
    
    public void move() {
      this.pos++;
    }
    
    public int getPos() {
      return this.pos;
    }
    
    public boolean isBusy() {
      return (interval > 0);
    }
    
    public void kill() {
      interval = 0;
    }
    
    public void message(String message, int messageColor) {
      this.pos = 0;
      this.interval = 200;
      this.message = message;
      this.messageColor = messageColor;
    }
    
    public void display() {
      textFont(consoleFont);
      if (force) {
        if (interval > 0) {
          interval--;
        }
        
        int ypos = pos*32;
        noStroke();
        fill(0);
        int recWidth = width/2;
        if (recWidth < textWidth(this.message)) {
          recWidth = (int)textWidth(this.message)+10;
        }
        rect(0, ypos, recWidth, 32);
        textSize(24);
        textAlign(LEFT);
        fill(this.messageColor);
        text(message, 5, ypos+20);
      }
      else {
        if (interval > 0 && pos < displayLines) {
          interval--;
          int ypos = pos*32;
          noStroke();
          if (interval < 60) {
            fill(0, 4.25f*PApplet.parseFloat(interval));
          }
          else {
            fill(0);
          }
          int recWidth = width/2;
          if (recWidth < textWidth(this.message)) {
            recWidth = (int)textWidth(this.message)+10;
          }
          rect(0, ypos, recWidth, 32);
          textSize(24);
          textAlign(LEFT);
          if (interval < 60) {
            fill(this.messageColor, 4.25f*PApplet.parseFloat(interval));
          }
          else {
            fill(this.messageColor);
          }
          text(message, 5, ypos+20);
        }
      }
    }
  }
  
  public Console() {
    this.consoleLine = new ConsoleLine[totalLines];
    this.generateConsole();
    
    consoleFont = createFont("data/font/SourceCodePro-Regular.ttf", 24);
  }
  
  private void generateConsole() {
    for (int i = 0; i < consoleLine.length; i++) {
      consoleLine[i] = new ConsoleLine();
      this.initialPos++;
    }
  }
  
  private void enableDebugInfo() {
    this.debugInfo = true;
    this.info("Extra debug info enabled.");
  }
  private void disableDebugInfo() {
    this.debugInfo = false;
  }
  
  private void killLines() {
      for (int i = 0; i < totalLines; i++) {
        this.consoleLine[i].kill();
      }
  }
  
  private void display(boolean doDisplay) {
    if (doDisplay) {
      for (int i = 0; i < totalLines; i++) {
        this.consoleLine[i].display();
      }
    }
    if (this.timeout > 0) {
      this.timeout--;
    }
    force = false;
  }
  
  public void force() {
    this.force = true;
  }
  
  public void consolePrint(Object message, int c) {
    int l = totalLines;
    int i = 0;
    int last = 0;
    
    String m = "";
    if (message instanceof String) {
      m = (String)message;
    }
    else if (message instanceof Integer) {
      m = str((Integer)message);
    }
    else if (message instanceof Float) {
      m = str((Float)message);
    }
    else if (message instanceof Boolean) {
      m = str((Boolean)message);
    }
    else {
      m = message.toString();
    }
    
    while (i < l) {
      if (consoleLine[i].getPos() == (l - 1)) {
        last = i;
      }
      consoleLine[i].move();
      i++;
    }
    consoleLine[last].message(m, c);
    println(message);
  }
  
  public void log(Object message) {
    this.consolePrint(message, color(255));
  }
  public void warn(String message) {
    this.consolePrint("WARNING!! "+message, color(255, 200, 30));
    this.basicui.showWarningWindow(message);
  }
  public void error(String message) {
    this.consolePrint("ERROR!! "+message, color(255, 30, 30));
  }
  public void info(Object message) {
    if (this.debugInfo) {
      this.consolePrint(message, color(127));
    }
  }
  
  public void logOnce(Object message) {
    if (this.timeout == 0) {
      this.consolePrint(message, color(255));
    }
    this.timeout = messageDelay;
  }
  public void warnOnce(String message) {
    if (this.timeout == 0) {
      this.consolePrint("WARNING!! "+message, color(255, 200, 30));
      this.basicui.showWarningWindow(message);
    }
    this.timeout = messageDelay;
  }
  public void errorOnce(String message) {
    if (this.timeout == 0) {
      this.consolePrint("ERROR!! "+message, color(255, 30, 30));
    }
    this.timeout = messageDelay;
  }
}




class BasicUI {
  
  
  public BasicUI() {
    
  }
  
  private boolean displayingWindow = false;
  private float offsetX = 0, offsetY = 0;
  private float radius = 30;
  private String message = "hdasklfhwea ewajgf awfkgwe fehwafg eawhjfgew ajfghewafg jehwafgghaf hewafgaehjfgewa fg aefhjgew fgewafg egaf ghewaf egwfg ewgfewa fhgewf e wgfgew afgew fg egafwe fg egwhahjfgsd asdnfv eahfhedhajf gweahj fweghf";
  
  private void warningWindow() {
    offsetX = sin(frameCount)*radius;
    offsetY = cos(frameCount)*radius;
    
    radius *= 0.90f;
    
    stroke(0);
    strokeWeight(4);
    fill(200);
    rect(200+offsetX, 300+offsetY, width-400, height-500);
    fill(color(255, 127, 0));
    rect(200+offsetX, 200+offsetY, width-400, 100);
    
    noStroke();
    
    textAlign(CENTER, CENTER);
    textSize(62);
    fill(255);
    text("WARNING!!", width/2+offsetX, 240+offsetY);
    
    textAlign(LEFT, LEFT);
    
    textSize(24);
    fill(0);
    text(message+"\n\n[press x to dismiss]", 220+offsetX, 320+offsetY, width-440, height-500);
  }
  
  public void showWarningWindow(String m) {
    sndNope.play();
    message = m;
    radius = 50;
    displayingWindow = true;
  }
  
  public boolean displayingWindow() {
    return displayingWindow;
  }
  
  public void stopDisplayingWindow() {
    displayingWindow = false;
  }  
  
  public void display() {
    if (displayingWindow) {
      warningWindow();
    }
  }
  
}






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
  private float beatVol = 1.0f;
  private Sprite unusedSprite;
  
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
  
  private boolean keyPressAllowed = true;
  private void keyPress() {
    if (this.displayUI && keyPressAllowed) {
      if (keyPressed && !buttonDown) {
        buttonDown = true;
        if (key == 'q') {
          
        }
        if (keyCode == LEFT) {
          console.log("Frame (before seek): "+draw.framecount);
          draw.changeFramecount(-PApplet.parseInt(draw.framerate*2));
        }
        if (keyCode == RIGHT) {
          console.log("Frame (before seek): "+draw.framecount);
          draw.changeFramecount(PApplet.parseInt(draw.framerate*2));
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
        if (key == ' ') {
          togglePlayPause();
          if (!playing()) {
            console.log("Frame: "+draw.framecount);
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
    if (s.equals(selectedSprite) || (keyPressed && key == 'r')) {
      draw.showWireframe();
      String txt = s.getName() + "   x:" + str((int)s.getX()) + " y:" + str((int)s.getY());
      draw.txt(txt, s.getX()*draw.getScaleX()*1.f, s.getY()*draw.getScaleY() - 5.f, 12.f);
    }
    draw.zPosition(s.getZ());
    //draw.autoImg(s.getImg(), s.getX(), s.getY()+s.getHeight()*s.getBop(), s.getWidth(), s.getHeight()-int((float)s.getHeight()*s.getBop()));
    
    switch (s.mode) {
      case SINGLE:
      draw.autoImg(s.getImg(), s.getX(), s.getY()+s.getHeight()*s.getBop(), s.getWidth(), s.getHeight()-PApplet.parseInt((float)s.getHeight()*s.getBop()));
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
    this.runSpriteInteraction(); //<>// //<>//
    console.display(this.displayUI);
    if (console.basicui.displayingWindow()) {
      console.basicui.display();
      playing = false;
      if (music != null)
        music.mute();
      if (keyPressed && key == 'x') {
        console.basicui.stopDisplayingWindow();
        playing = true;
        if (music != null)
          music.unmute();
      }
    }
  }
}
enum Transform {
    SINGLE,
    DOUBLE,
    VERTEX,
    ROTATE
}

class Sprite {

  private String imgName = "";
  private String name;
  
  private float xpos, ypos, zpos;
  private int wi = 0, hi = 0;
  public QuadVertices vertex;
  
  
  private float defxpos, defypos, defzpos;
  private int defwi = 0, defhi = 0;
  private QuadVertices defvertex;
  private float defrot = HALF_PI;
  private float defradius = 100.f; //radiusY = 50.;
  
  private float offxpos, offypos;
  private int offwi = 0, offhi = 0;
  private QuadVertices offvertex;
  private float offrot = HALF_PI;
  private float offradius = 100.f; //radiusY = 50.;
  
  private int spriteOrder;
  
  
  private float repositionDragStartX;
  private float repositionDragStartY;
  public QuadVertices repositionV;
  private float aspect;
  private Click resizeDrag;
  private Click repositionDrag;
  private Click select;
  private int currentVertex = 0;
  private boolean hoveringOverResizeSquare = false;
  private Render r;
  private boolean lock = false;
  private int lastFrameShown = 0;
  private float bop = 0.0f;
  private Transform mode = Transform.SINGLE;
  private float rot = HALF_PI;
  private float radius = 100.f; //radiusY = 50.;
  
  private float BOX_SIZE = 50;
  
  
  
  //Scale modes:
  //1 - pixel width height (int)
  //2 - scale multiplier (float)

  public Sprite(String name, Render r) {
    xpos = 0;
    ypos = 0;
    this.name = name;
    vertex = new QuadVertices();
    offvertex = new QuadVertices();
    defvertex = new QuadVertices();
    repositionV = new QuadVertices();
    resizeDrag     = new Click();
    repositionDrag = new Click();
    select         = new Click();
    this.r = r;
  }
  
  public void setOrder(int order) {
    this.spriteOrder = order;
  }
  
  public int getOrder() {
    return spriteOrder;
  }

  public float getBop() {
    return bop;
  }

  public void bop() {
    bop = 0.2f;
  }

  public void bop(float b) {
    bop = b;
  }

  public void resetBop() {
    bop = 0.0f;
  }
  
  public String getModeString() {
    switch (mode) {
      case SINGLE:
      return "SINGLE";
      case DOUBLE:
      return "DOUBLE";
      case VERTEX:
      return "VERTEX";
      case ROTATE:
      return "ROTATE";
      default:
      return "SINGLE";
    }
  }
  
  public void setMode(Transform m) {
    this.mode = m;
  }
  
  public void setModeString(String m) {
    if (m.equals("SINGLE")) {
      mode = Transform.SINGLE;
    }
    else if (m.equals("DOUBLE")) {
      mode = Transform.DOUBLE;
    }
    else if (m.equals("VERTEX")) {
      mode = Transform.VERTEX;
    }
    else if (m.equals("ROTATE")) {
      mode = Transform.ROTATE;
    }
    else {
      mode = Transform.SINGLE;
    }
  }

  public String getName() {
    return this.name;
  }

  public void lock() {
    lock = true;
  }
  public void unlock() {
    lock = false;
  }
  public void poke(int f) {
    //rot += 0.05;
    bop *= 0.85f;
    lastFrameShown = f;
  }
  public boolean beingUsed(int f) {
    return (f == lastFrameShown-1 || f == lastFrameShown || f == lastFrameShown+1);
  }
  public boolean isLocked() {
    return lock;
  }
  public void setImg(String name) {
    imgName = name;
    if (wi == 0) { 
      wi = (int)r.getImg(name).getWidth();
      defwi = wi;
    }
    if (hi == 0) {
      hi = (int)r.getImg(name).getHeight();
      defhi = hi;
    }
    aspect = r.getImg(imgName).getHeight()/r.getImg(imgName).getWidth();
  }

  public String getImg() {
    return imgName;
  }

  public void move(float x, float y) {
    float oldX = xpos;
    float oldY = ypos;
    xpos = x;
    ypos = y;
    defxpos = x;
    defypos = y;
    
    //Vertex position
    for (int i = 0; i < 4; i++) {
      vertex.v[i].add(x-oldX, y-oldY);
    }
  }
  
  public void offmove(float x, float y) {
    float oldX = xpos;
    float oldY = ypos;
    offxpos = x;
    offypos = y;
    xpos = defxpos+x;
    ypos = defypos+y;
    
    for (int i = 0; i < 4; i++) {
      vertex.v[i].add(xpos-oldX, ypos-oldY);
    }
  }
  
  public void vertex(int v, float x, float y) {
    vertex.v[v].set(x, y);
    defvertex.v[v].set(x, y);
  }
  
  public void offvertex(int v, float x, float y) {
    offvertex.v[v].set(x, y);
    vertex.v[v].set(defvertex.v[v].x+x, defvertex.v[v].y+y);
  }

  public void setX(float x) {
    xpos = x;
    defxpos = x;
  }

  public void setY(float y) {
    ypos = y;
    defypos = y;
  }
  
  public void offsetX(float x) {
    offxpos = x;
    xpos = defxpos+x;
  }

  public void offsetY(float y) {
    offypos = y;
    ypos = defxpos+y;
  }

  public void setZ(float z) {
    zpos = z;
    defzpos = z;
  }

  public void setWidth(int w) {
    this.wi = PApplet.parseInt((float)w*r.getScaleX());
    defwi =   PApplet.parseInt((float)w*r.getScaleX());
  }

  public void setHeight(int h) {
    this.hi = PApplet.parseInt((float)h*r.getScaleY());
    defhi =   PApplet.parseInt((float)h*r.getScaleY());
  }
  
  public void offsetWidth(int w) {
    this.offwi = w;
    this.wi = defwi+w;
  }

  public void offsetHeight(int h) {
    this.offhi = h;
    this.hi = defhi+h;
  }

  public float getX() {
    return this.xpos;
  }

  public float getY() {
    return this.ypos;
  }

  public float getZ() {
    return this.zpos;
  }

  public int getWidth() {
    return this.wi;
  }

  public int getHeight() {
    return this.hi;
  }
  
  
  
  private boolean polyPoint(PVector[] vertices, float px, float py) {
    boolean collision = false;
  
    // go through each of the vertices, plus
    // the next vertex in the list
    int next = 0;
    for (int current=0; current<vertices.length; current++) {
  
      // get next vertex in list
      // if we've hit the end, wrap around to 0
      next = current+1;
      if (next == vertices.length) next = 0;
  
      // get the PVectors at our current position
      // this makes our if statement a little cleaner
      PVector vc = vertices[current];    // c for "current"
      PVector vn = vertices[next];       // n for "next"
  
      // compare position, flip 'collision' variable
      // back and forth
      if (((vc.y >= py && vn.y < py) || (vc.y < py && vn.y >= py)) &&
           (px < (vn.x-vc.x)*(py-vc.y) / (vn.y-vc.y)+vc.x)) {
              collision = !collision;
      }
    }
    return collision;
  }



  public boolean mouseWithinSquare() {
    switch (mode) {
      case SINGLE: {
        float d = BOX_SIZE, x = (float)wi/r.getScaleX()-d+xpos, y = (float)hi/r.getScaleY()-d+ypos;
        if (mouseX > x && mouseY > y && mouseX < x+d && mouseY < y+d) {
          return true;
        }
      }
      break;
      case DOUBLE:
      
      break;
      case VERTEX: {
        for (int i = 0; i < 4; i++) {
          float d = BOX_SIZE;
          float x = vertex.v[i].x;
          float y = vertex.v[i].y;
          if (mouseX > x-d/2 && mouseY > y-d/2 && mouseX < x+d/2 && mouseY < y+d/2) {
            return true;
          }
        }
      }
      break;
      case ROTATE:
      //float decx = float(mouseX)-cx;
      //float decy = cy-float(mouseY);
      //if (decy < 0) {
      //  rot = atan(-decx/decy);
      //}
      //else {
      //  rot = atan(-decx/decy)+PI;
      //}
      float cx = xpos+wi/2, cy = ypos+hi/2;
      float d = BOX_SIZE;
      float x = cx+sin(rot)*radius,  y = cy+cos(rot)*radius;
      
      if (mouseX > x-d/2 && mouseY > y-d/2 && mouseX < x+d/2 && mouseY < y+d/2) {
        return true;
      }
      break;
    }
    return false;
  }
  
  public float getRot() {
    return this.rot;
  }
  
  public void setRot(float r) {
    this.rot = r;
  }
  
  public boolean rotateCollision() {
    float r = HALF_PI/2 + rot;
    float xr = radius;
    float yr = radius;
    float xd = xpos+PApplet.parseFloat(wi)/2;
    float yd = ypos+PApplet.parseFloat(hi)/2;
    float f = 0;
    if (wi > hi) {
      f = 1-(PApplet.parseFloat(hi)/PApplet.parseFloat(wi));
    }
    else if (hi > wi) {
      f = 1-(PApplet.parseFloat(wi)/PApplet.parseFloat(hi));
    }
    else {
      f = 0;
    }
    
    float x = sin(r+f)*xr + xd;
    float y = cos(r+f)*yr + yd;
    vertex.v[0].x = x;
    vertex.v[0].y = y;
    x = sin(r-f+HALF_PI)*xr + xd;
    y = cos(r-f+HALF_PI)*yr + yd;
    vertex.v[1].x = x;
    vertex.v[1].y = y;
    x = sin(r+f+PI)*xr + xd;
    y = cos(r+f+PI)*yr + yd;
    vertex.v[2].x = x;
    vertex.v[2].y = y;
    x = sin(r-f+HALF_PI+PI)*xr + xd;
    y = cos(r-f+HALF_PI+PI)*yr + yd;
    vertex.v[3].x = x;
    vertex.v[3].y = y;
    x = sin(r+f)*xr + xd;
    y = cos(r+f)*yr + yd;
    vertex.v[0].x = x;
    vertex.v[0].y = y;
    
    return polyPoint(vertex.v, mouseX, mouseY);
  }
  
  
  public boolean mouseWithinSprite() {
    switch (mode) {
      case SINGLE:
        float x = xpos, y = ypos;
        return (mouseX > x && mouseY > y && mouseX < x+wi/r.getScaleX() && mouseY < y+hi/r.getScaleY() && !repositionDrag.isDragging());
      case DOUBLE:
      
      case VERTEX:
        return polyPoint(vertex.v, mouseX, mouseY);
      case ROTATE: {
        return rotateCollision();
      }
        
    }
    return false;
  }
  
  public boolean mouseWithinHitbox() {
    return mouseWithinSprite() || mouseWithinSquare();
  }

  public boolean clickedOn() {
    return (mouseWithinHitbox() && repositionDrag.clicked());
  }
  
  public void updateJSON() {
      JSONObject attributes = new JSONObject();
      
      attributes.setString("name", name);
      attributes.setString("mode", getModeString());
      attributes.setBoolean("locked", this.isLocked());
      attributes.setInt("x", (int)this.defxpos);
      attributes.setInt("y", (int)this.defypos);
      attributes.setInt("w", (int)this.defwi);
      attributes.setInt("h", (int)this.defhi);
      
      for (int i = 0; i < 4; i++) {
        attributes.setInt("vx"+str(i), (int)defvertex.v[i].x);
        attributes.setInt("vy"+str(i), (int)defvertex.v[i].y);
      }
      
      //resetDefaults();
      
      saveJSONObject(attributes, PATH_SPRITES_ATTRIB+name+".json");
  }
  
  public boolean isDragging() {
    return resizeDrag.isDragging() || repositionDrag.isDragging();
  }

  public void dragReposition() {
    boolean dragging = mouseWithinSprite() && !mouseWithinSquare();
    if (mode == Transform.VERTEX) {
      //dragging = mouseWithinSprite();
    }
    if (dragging && !repositionDrag.isDragging()) {
      repositionDrag.beginDrag();
      
      //X and Y position
      repositionDragStartX = this.xpos-mouseX;
      repositionDragStartY = this.ypos-mouseY;
      
      //Vertex position
      for (int i = 0; i < 4; i++) {
        repositionV.v[i].set(vertex.v[i].x-mouseX, vertex.v[i].y-mouseY);
      }
    }
    if (repositionDrag.isDragging()) {
      //X and y position
      this.xpos = repositionDragStartX+mouseX;
      this.ypos = repositionDragStartY+mouseY;
      
      defxpos = xpos-offxpos;
      defypos = ypos-offypos;
      
      //Vertex position
      for (int i = 0; i < 4; i++) {
        vertex.v[i].set(repositionV.v[i].x+mouseX, repositionV.v[i].y+mouseY);
        defvertex.v[i].set(vertex.v[i].x-offvertex.v[i].x, vertex.v[i].y-offvertex.v[i].y);
      }
    }
    if (repositionDrag.draggingEnded()) {
      updateJSON();
    }

    repositionDrag.update();
  }

  public boolean hoveringOverResizeSquare() {
    return this.hoveringOverResizeSquare;
  }

  public boolean hoveringVertex(float px, float py) {
    boolean collision = false;
    int next = 0;
    for (int current=0; current<vertex.v.length; current++) {

      // get next vertex in list
      // if we've hit the end, wrap around to 0
      next = current+1;
      if (next == vertex.v.length) next = 0;

      PVector vc = vertex.v[current];    // c for "current"
      PVector vn = vertex.v[next];       // n for "next"

      if ( ((vc.y > py) != (vn.y > py)) && (px < (vn.x-vc.x) * (py-vc.y) / (vn.y-vc.y) + vc.x) ) {
        collision = !collision;
      }
    }

    return false;
  }

  public void resizeSquare() {
    switch (mode) {
      case SINGLE: {
        float d = BOX_SIZE, x = (float)wi/r.getScaleX()-d+xpos, y = (float)hi/r.getScaleY()-d+ypos;
        resizeDrag.update();
        this.square((float)wi/r.getScaleX()-d+xpos, (float)hi/r.getScaleY()-d+ypos, d);
        if (mouseX > x && mouseY > y && mouseX < x+d && mouseY < y+d) {
          resizeDrag.beginDrag();
          this.hoveringOverResizeSquare = true;
        } else {
          this.hoveringOverResizeSquare = false;
        }
        if (resizeDrag.isDragging()) {
          wi = PApplet.parseInt((mouseX+d/2-xpos)*r.getScaleX());
          hi = PApplet.parseInt((mouseX+d/2-xpos)*r.getScaleX()*aspect);
          
          defwi = wi-offwi;
          defhi = hi-offhi;
          
          /*
          if (mouseX*aspect > mouseY) {
           wi = int((mouseX-xpos)*r.getScaleX());
           hi = int((mouseX-xpos)*r.getScaleX()*aspect);
           }
           else {
           wi = int((mouseY-ypos)*r.getScaleY());
           hi = int((mouseY-ypos)*r.getScaleY()*aspect);
           }
           */
        }
        if (resizeDrag.draggingEnded()) {
          updateJSON();
        }
      }
      break;
        
        
        
      case DOUBLE:
      
      break;
      
      case VERTEX: {
        resizeDrag.update();
        for (int i = 0; i < 4; i++) {
          float d = BOX_SIZE;
          float x = vertex.v[i].x;
          float y = vertex.v[i].y;
          this.square(x-d/2, y-d/2, d);
          
          if (mouseX > x-d/2 && mouseY > y-d/2 && mouseX < x+d/2 && mouseY < y+d/2) {
            resizeDrag.beginDrag();
            currentVertex = i;
            this.hoveringOverResizeSquare = true;
          } else {
            this.hoveringOverResizeSquare = false;
          }
          if (resizeDrag.isDragging() && currentVertex == i) {
            vertex.v[i].x = mouseX;
            vertex.v[i].y = mouseY;
            defvertex.v[i].set(vertex.v[i].x-offvertex.v[i].x, vertex.v[i].y-offvertex.v[i].y);
          }
        }
        if (resizeDrag.draggingEnded()) {
          updateJSON();
        }
      }
      break;
      
      
      case ROTATE: {
        resizeDrag.update();
        float cx = xpos+wi/2, cy = ypos+hi/2;
        float d = BOX_SIZE;
        float x = cx+sin(rot)*radius,  y = cy+cos(rot)*radius;
        
        this.square(x-d/2, y-d/2, d);
          
        if (mouseX > x-d/2 && mouseY > y-d/2 && mouseX < x+d/2 && mouseY < y+d/2) {
          resizeDrag.beginDrag();
          this.hoveringOverResizeSquare = true;
        } else {
          this.hoveringOverResizeSquare = false;
        }
        
        if (resizeDrag.isDragging()) {
          float decx = PApplet.parseFloat(mouseX)-cx;
          float decy = cy-PApplet.parseFloat(mouseY);
          if (decy < 0) {
            rot = atan(-decx/decy);
          }
          else {
            rot = atan(-decx/decy)+PI;
          }
          
          float a = PApplet.parseFloat(wi)/PApplet.parseFloat(hi);
          float s = sin(rot);//, c = a*-cos(rot);
          if (s != 0.0f) {
            radius = decx/s;
          }
          
          
        }
      }
      break;
        
    }
  }
  
  public void setRadius(float x) {
    radius = x;
  }
  
  public float getRadius() {
    return radius;
  }
  
  public void createVertices() {
    vertex.v[0].set(xpos, ypos);
    vertex.v[1].set(xpos+wi, ypos);
    vertex.v[2].set(xpos+wi, ypos+hi);
    vertex.v[3].set(xpos, ypos+hi);
    
    defvertex.v[0].set(xpos, ypos);
    defvertex.v[1].set(xpos+wi, ypos);
    defvertex.v[2].set(xpos+wi, ypos+hi);
    defvertex.v[3].set(xpos, ypos+hi);
  }

  private void square(float x, float y, float d) {
    noStroke();
    fill(sin(frameCount*0.1f)*50+200, 100);
    rect(x, y, d, d);
  }
}
class StackException extends RuntimeException{    
  public StackException(String err) {
    super(err);
  }
}

public class Stack<T> {
  private Object[] S;
  private int top;
  private int capacity;
  
  public Stack(int size){
    capacity = size;
    S = new Object[size];
    top = -1;
  }

  public Stack(){
    this(100);
  }
  
  public T peek() {
    if(isEmpty())
      throw new StackException("stack is empty");
    return (T)S[top];
  }
  
  public T peek(int indexFromTop) {
    //Accessing negative indexes should be impossible.
    if(top-indexFromTop < 0)
      throw new StackException("stack is empty");
    return (T)S[top-indexFromTop];
  }
  
  public boolean isEmpty(){
    return top < 0;
  }
  
  public int size(){
    return top+1; 
  }
  
  public void seek(int index) {
  
  }
  
  public void empty() {
    top = -1;
  }

  public void push(T e){
    if(size() == capacity)
      throw new StackException("stack is full");
    S[++top] = e;
  }
  
  public T pop() throws StackException{
    if(isEmpty())
      throw new StackException("stack is empty");
    // this type cast is safe because we type checked the push method
    return (T) S[top--];
  }
  
  public T top() throws StackException{
    if(isEmpty())
      throw new StackException("stack is empty");
    // this type cast is safe because we type checked the push method
    return (T) S[top];
  }
}














class Click {
  private boolean dragging = false;
  private int clickDelay = 0;
  private boolean click = false;
  private boolean draggingEnd = false;
  
  public boolean isDragging() {
    return dragging;
  }
  
  public void update() {
    draggingEnd = false;
    if (!mousePressed && dragging) {
      dragging = false;
      draggingEnd = true;
    }
    if (clickDelay > 0) {
      clickDelay--;
    }
    if (!click && mousePressed) {
      click = true;
      clickDelay = 1;
    }
    if (click && !mousePressed) {
      click = false;
    }
  }
  
  public boolean draggingEnded() {
    return draggingEnd;
  }
  
  public void beginDrag() {
    if (mousePressed && clickDelay > 0) {
      dragging = true;
    }
  }
  
  public boolean clicked() {
    return (clickDelay > 0);
  }
  
  
}



class QuadVertices {
    public PVector v[] = new PVector[4];
    
    {
      v[0] = new PVector(0,0);
      v[1] = new PVector(0,0);
      v[2] = new PVector(0,0);
      v[3] = new PVector(0,0);
    }
    
    public QuadVertices() {
    
    }
    public QuadVertices(float xStart1,float yStart1,float xStart2,float yStart2,float xEnd1,float yEnd1,float xEnd2,float yEnd2) {
      v[0].set(xStart1, yStart1);
      v[1].set(xStart2, yStart2);
      v[2].set(xEnd1,   yEnd1);
      v[3].set(xEnd2,   yEnd2);
    }
}
String PATH_CACHE                = sketchPath()+"/data/engine/cache/";
String PATH_IMG                  = sketchPath()+"/data/img/";
String PATH_SHADER               = sketchPath()+"/data/shaders/";
String PATH_SPRITES_ATTRIB       = sketchPath()+"/data/engine/sprites/";
String FRAMES_FOLDER_DIR         = sketchPath()+"/data/frames/";


String PATH_MISSING_ICO               = sketchPath()+"/data/engine/icos/missing.png";
String PATH_SND_NOPE                  = sketchPath()+"/data/engine/sounds/nope.wav";
class Render {
  private float rot = 0;
  private int drawPoint = CORNER;
  private HashMap<String, SketchImage> imgMap;
  public  ArrayList<String> imgNames;
  private float wi, hi;
  private float wiPix, hiPix;
  private int scaleMode = 0;
  private boolean loadOnGoMode = false;
  private boolean caching = true;
  private boolean fastMode = true;
  private int lowResBase = 256;
  private PImage missingImg;
  private PGraphics display;
  private PGraphics shaderCanvas;
  private ArrayList<PShader> postProcessingShaders;
  private ArrayList<PShader> shaders;
  private IntDict shaderNames;
  private Integer framecount = 0;
  private Float framerate  = 60.0f;
  private QuadVertices vertex;
  private float sceneScaleX, sceneScaleY;
  private Console console;
  private boolean wireframe = false;
  private boolean looperHasRun = false;
  private float radius;
  
  public Render(int w, int h) {
    ready(w, h);
  }
  
  public Render(int w) {
    float aspect = (float)w/width;
    this.ready(w, PApplet.parseInt(height*aspect));
  }
  
  public Render(float scale) {
    this.ready(PApplet.parseInt(width*scale), PApplet.parseInt(height*scale));
  }
  
  private void ready(int w, int h) {
    this.display      = createGraphics(w, h, P3D);
    this.shaderCanvas = createGraphics(w, h, P2D);
    this.sceneScaleX = (float)w/app.width;
    this.sceneScaleY = (float)h/app.height;
    imgMap = new HashMap<String, SketchImage>();
    console = new Console();
    missingImg = loadImage(PATH_MISSING_ICO);
    postProcessingShaders  = new ArrayList<PShader>();
    shaderNames = new IntDict();
    imgNames = new ArrayList<String>();
    shaders = new ArrayList<PShader>();
  }
  
  private void setConsole(Console console) {
    this.console = console;
  }
  public float getScaleX() {
    return sceneScaleX;
  }
  public float getScaleY() {
    return sceneScaleY;
  }
  
  public void loopRun() {
    looperHasRun = true;
  }
  
  
  
  
  public int width() {
    return display.width;
  }

  public int height() {
    return display.height;
  }
  
  public Float getFramerate() {
    return this.framerate;
  }
  
  public void changeFramecount(int amount) {
    this.framecount += amount;
    if (this.framecount < 0) {
      this.framecount = 0;
    }
  }
  
  public void setFramecount(int amount) {
    this.framecount = amount;
    if (this.framecount < 0) {
      this.framecount = 0;
    }
  }
  
  
  public Integer getFramecount() {
    return this.framecount;
  }
  
  public void showWireframe() {
    wireframe = true;
  }
  
  public void hideWireframe() {
    wireframe = false;
  }
  
  public void setFramerate(float framerate) {
    this.framerate = framerate;
    frameRate(framerate);
  }
  
  public void enableFastRendering() {
    fastMode = true;
    if (caching) {
      console.log("Fast mode enabled");
    }
    else {
      console.warn("Fast mode enabled but caching disabled.");
    }
  }
  public void disableFastRendering() {
    fastMode = false;
  }
  
  public void loadOnGo() {
    loadOnGoMode = true;
    console.log("Sketch will load assets on the go.");
  }
  
  public boolean attribExists(String attrib) {
    
    for (String a : imgAttributes) {
      if (a.equals(attrib)) {
        return true;
      }
    }
    return false;
  }
 
  private String cacheFileType = ".png";
  
  public void loadImg(String imgPath) {
    console.info(imgPath);
    File f = new File(imgPath);
    String n = f.getName();
    String ext = "";
    {
      try {
        ext = n.substring(n.length()-4, n.length());
      }
      catch (StringIndexOutOfBoundsException e) {
        console.warn("The file type (\"\") is not an image.");
        imgMap.put(n, new SketchImage(missingImg));
        return;
      }
      if (!(ext.equals(".png") || ext.equals(".gif") || ext.equals(".jpg") || ext.equals(".tif"))) {
        console.warn("The file type for "+n+" ("+ext+") is not an image.");
        imgMap.put(n, new SketchImage(missingImg));
        return;
      }
    }
    int fileSize = (int)f.length();
    n = n.substring(0, n.length()-4);
    SketchImage img;
    if (!f.exists()) {
      console.warn("File "+imgPath+" not found.");
      imgMap.put(n, new SketchImage(missingImg));
      return;
    }
    if (caching && fastMode) {
      SketchImage lowResImage = tryGetCache(n);
      //If cache doesn't exist...
      if (lowResImage == null) {
        PImage I = loadImage(imgPath);
        if (I.width <= 0 || I.height <= 0) {
          console.warn("A problem with "+imgPath+" occured and could not be loaded.");
          imgMap.put(n, new SketchImage(missingImg));
          return;
        }
        
        int originWid = I.width;
        int originHi  = I.height;
        if (attribExists(n+":mini") || attribExists("ALL:mini")) {
          I = minimiseImg(I);
        }
        
        PGraphics lowRes;
        if ((originWid > lowResBase) && (originHi > lowResBase)) {
          int wid;
          int high;
          float aspect = PApplet.parseFloat(I.width)/PApplet.parseFloat(I.height);
          if (I.height >= I.width) {
            wid  = PApplet.parseInt(PApplet.parseFloat(lowResBase)*aspect);
            high = lowResBase;
          }
          else {
            wid  = lowResBase;
            high = PApplet.parseInt(lowResBase/aspect);
          }
          lowRes = createGraphics(wid, high);
          lowRes.beginDraw();
          lowRes.clear();
          lowRes.image(I, 0, 0, wid, high);
          lowRes.endDraw();
          img = new SketchImage(lowRes, I.width, I.height);
          imgMap.put(n, img);
          imgNames.add(n);
          storeCache(img, n, fileSize, f.getAbsolutePath());
        }
        else {
          img = new SketchImage(I);
          imgMap.put(n, img);
          imgNames.add(n);
        }
      }
      else {
        img = lowResImage;
        imgMap.put(n, img);
        imgNames.add(n);
      }
    }
    else {
      PImage I = loadImage(imgPath);
      
      if (I.width <= 0 || I.height <= 0) {
        console.warn("A problem with "+imgPath+" occured and could not be loaded.");
        imgMap.put(n, new SketchImage(missingImg));
        return;
      }
      
      if (attribExists(n+":mini") || attribExists("ALL:mini")) {
        I = minimiseImg(I);
      }
      
      img = new SketchImage(I);
      imgMap.put(n, img);
      imgNames.add(n);
    }
  }
  
  private void storeCache(SketchImage img, String name, int fileSize, String originalPath) {
    if (caching) {
      File cachedImage = new File(PATH_CACHE+name+cacheFileType);
      if (!cachedImage.exists()) {
        console.info("Cache for "+name+" created.");
        img.getImg().save(PATH_CACHE+name+cacheFileType);
        JSONObject properties = new JSONObject();
        properties.setString("path", originalPath);
        properties.setInt("width", (int)img.getWidth());
        properties.setInt("height", (int)img.getHeight());
        properties.setBoolean("mini", attribExists(name+":mini") || attribExists("ALL:mini"));
        properties.setInt("size", fileSize);
        saveJSONObject(properties, PATH_CACHE+name+".json");
      }
    }
  }
  
  private SketchImage tryGetCache(String name) {
    if (caching) {
      PImage cachedImg;
      float wid  = 0;
      float high = 0;
      File cachedImage = new File(PATH_CACHE+name+cacheFileType);
      if (cachedImage.exists()) {
        cachedImg = loadImage(PATH_CACHE+name+cacheFileType);
        
        File propertiesFile = new File(PATH_CACHE+name+".json");
        if (!propertiesFile.exists()) {
          console.info("Missing JSON. Cache will be re-created.");
          return null;
        }
        JSONObject properties = loadJSONObject(PATH_CACHE+name+".json");
        wid  = (float)properties.getInt("width");
        if (cacheFileType.equals(".tga")) {               //Because of a bug in processing, we need to flip images upside down if therethe file type the cached images are in is tga.
          high = -properties.getInt("height");
        }
        else {
          high = properties.getInt("height");
        }
        
        //Return null so we can apply new attributes.
        if (properties.getBoolean("mini") != (attribExists(name+":mini") || attribExists("ALL:mini"))) {
          console.info("Mini attribute changed. Cache will be re-created.");
          return null;
        }
        
        String path = properties.getString("path");
        
        int s = (int)(new File(path)).length();
        if (properties.getInt("size") != s) {
          console.info(name+" is different ("+str(properties.getInt("size"))+", "+str(s)+") Cache will be re-created.");
          return null;
        }
        
      }
      else {
        console.info("No cache for "+name+" found.");
        return null;
      }
      console.info("Loaded cache: "+name);
      return new SketchImage(cachedImg, wid, high);
    }
    else {
      console.info("Caching disabled, no cache for "+name+" loaded.");
      return null;
    }
  }
  
  public SketchImage getImg(String imgName) {
    if (loadOnGoMode) {
      SketchImage img;
      img = imgMap.get(imgName);
      if (img == null) {
        loadImg(PATH_IMG+imgName+".png");
        img = imgMap.get(imgName);
        if (img == null) {
          console.warnOnce("Could not find "+imgName+" in memory.");
          return new SketchImage(missingImg);
        }
      }
      return img;
    }
    else {
      SketchImage img;
      img = imgMap.get(imgName);
      if (img == null) {
        console.warnOnce("Could not find "+imgName+" in memory.");
        return new SketchImage(missingImg);
      }
      return img;
    }
  }
  
  public PImage get(String imgName) {
    SketchImage img;
    img = imgMap.get(imgName);
    if (img == null) {
      console.warnOnce("Could not find "+imgName+" in memory.");
      return missingImg;
    }
    return img.getImg();
  }
  
  public void minimiseImg(String imgName) {
    SketchImage img = getImg(imgName);
    int[] d = minimise(img.getImg());
    img.setImg(img.getImg().get(d[0], d[1], d[2]-d[0], d[3]-d[1]));
    img.setWi(d[2]-d[0]);
    img.setHi(d[3]-d[1]);
  }
  public PImage minimiseImg(PImage img) {
    int[] d = minimise(img);
    return (img.get(d[0], d[1], d[2]-d[0], d[3]-d[1]));
  }
  
  public void autoImg(String imgName, float xpos, float ypos) {this.scaleMode = 0; this.bitmapImg(this.getImg(imgName), xpos, ypos);}
  public void autoImg(String imgName, float xpos, float ypos, int w, int h) {drawPoint = CORNER; this.scaleMode = 1; this.wiPix = (float)w; this.hiPix = (float)h; this.bitmapImg(this.getImg(imgName), xpos, ypos);}
  public void autoImg(String imgName, float xpos, float ypos, float w, float h) {this.scaleMode = 2; this.wi = w; this.hi = h; this.bitmapImg(this.getImg(imgName), xpos, ypos);}
  
  public void autoImg(Sprite s, float xpos, float ypos, float w, float h) {
    drawPoint = CORNER;
    this.scaleMode = 2; 
    this.wi = w; 
    this.hi = h;
    QuadVertices v = this.vertex;
    this.vertex = s.vertex;
    this.bitmapImg(this.getImg(s.getImg()), xpos, ypos);
    this.vertex = v;
  }
  
  public void autoImgRotate(Sprite s) {
    drawPoint = ROUND; 
    rot = s.getRot();
    radius = s.getRadius();
    this.scaleMode = 2; 
    this.wi = s.getWidth();
    this.hi = s.getHeight()-PApplet.parseInt((float)s.getHeight()*s.getBop());
    float x = s.getX();
    float y = s.getY()+s.getHeight()*s.getBop();
    this.bitmapImg(this.getImg(s.getImg()), x, y);
  }
  
  public void autoImgVertex(Sprite s) {
    if (s.getName().equals("glow")) {
      display.blendMode(ADD);
    }
    drawPoint = QUAD;
    this.scaleMode = 2; 
    this.wi = s.getWidth();
    this.hi = s.getHeight()-PApplet.parseInt((float)s.getHeight()*s.getBop());
    QuadVertices v = this.vertex;
    this.vertex = s.vertex;
    float x = s.getX();
    float y = s.getY()+s.getHeight()*s.getBop();
    this.bitmapImg(this.getImg(s.getImg()), x, y);
    this.vertex = v;
    
    if (s.getName().equals("glow")) {
      display.blendMode(NORMAL);
    }
  }
  
  public void img(PImage p, float xpos, float ypos) {this.scaleMode = 0; this.bitmapImg(p,xpos,ypos);}
  public void img(PImage p, float xpos, float ypos, int w, int h) {this.scaleMode = 1; this.wiPix = (float)w; this.hiPix = (float)h; this.bitmapImg(p,xpos,ypos);}
  public void img(PImage p, float xpos, float ypos,  float w, float h) {this.scaleMode = 2; this.wi = w; this.hi = h; this.bitmapImg(p,xpos,ypos);}
  
  public void autoSetShader(String imgName, PShader shader) {
    this.getImg(imgName).setShader(shader);
  }
  public void autoSetShader(String imgName, String shaderName) {
    this.getImg(imgName).setShader(this.getShaderByName(shaderName));
  }
  public PShader autoGetShader(String imgName) {
    return this.getImg(imgName).getShader();
  }
  
  public void rotation(float deg) {
    rot = radians(deg);
  }
  
  public void drawFrom(int mode) {
    drawPoint = mode;
  }
  
  private void bitmapImg(PImage p, float xpos, float ypos) {
    this.bitmapImg(new SketchImage(p, p.width, p.height), xpos, ypos);
  }
  
  public void tint(int col) {
    display.tint(col);
  }
  
  public void noTint() {
    display.noTint();
  }
  
  private float zpos = 1.0f;
  
  public void zPosition(float z) {
    this.zpos = z;
  }
  
  public void danceFloor() {
    display.beginDraw();
    display.noStroke();
    display.fill(0, 100);
    display.rect(0, this.height()-200, this.width(), 200);
    display.endDraw();
  }
  
  private float fract(float x, float y) {
      if (x > y) {
        return y/x;
      }
      else if (y > x) {
        return x/y;
      }
      else {
        return 1;
      }
  }
  
  public void setAddMode() {
    display.beginDraw();
    display.blendMode(ADD);
    display.endDraw();
  }
  
  public void setNormalMode() {
    display.beginDraw();
    display.blendMode(NORMAL);
    display.endDraw();
  }
  
  private void bitmapImg(SketchImage p, float xpos, float ypos) {
    //setAddMode();
    display.beginDraw();
    //display.pushMatrix();
    //display.translate(xpos, ypos);
    //display.rotate(rot);
    
    xpos *= this.sceneScaleX;
    ypos *= this.sceneScaleY;
    
    if (p.hasShader()) {
      display.shader(p.getShader());
    }
    
    float w = 0.0f, h = 0.0f;
    
    switch (this.scaleMode) {
      case 0:
      w = (p.getWidth()) * this.sceneScaleX;
      h = (p.getHeight()) * this.sceneScaleY;
      break;
      case 1:
      w = (this.wiPix);
      h = (this.hiPix);
      break;
      case 2:
      w = p.getWidth() * this.wi * this.sceneScaleX;
      h = p.getHeight() * this.hi * this.sceneScaleX;
      break;
    }
    
    if (this.wireframe) {
      display.stroke(sin(frameCount*0.1f)*127+127, 100);
      display.strokeWeight(2);
    }
    else {
      display.noStroke();
    }
    display.beginShape();
    display.texture(p.getImg());
    
    float startX = 0.0f, startY = 0.0f;
    float endX = 0.0f,   endY = 0.0f  ;
    
    switch (drawPoint) {
      case CENTER:
        startX = -w/2; startY = -h/2;
        endX   = startX+w; endY   = startY+h;
      break;
      case CORNER:
        startX = xpos;     startY = ypos;
        endX   = startX+w; endY   = startY+(h);
      break;
      case ROUND:
        startX = xpos;     startY = ypos;
        endX   = startX+w; endY   = startY+(h);
      break;
    }
    
    
    
    if (drawPoint == QUAD) {
      this.display.vertex(vertex.v[0].x, vertex.v[0].y, this.zpos, 0, 0);
      this.display.vertex(vertex.v[1].x, vertex.v[1].y, this.zpos, p.getTrueWidth(), 0);
      this.display.vertex(vertex.v[2].x, vertex.v[2].y, this.zpos, p.getTrueWidth(), p.getTrueHeight());
      this.display.vertex(vertex.v[3].x, vertex.v[3].y, this.zpos, 0, p.getTrueHeight());
      this.display.vertex(vertex.v[0].x, vertex.v[0].y, this.zpos, 0, 0);
      drawPoint = prevDrawPoint;
    }
    else if (drawPoint == ROUND) {
      float r = HALF_PI/2 + rot;
      float xr = radius;
      float yr = radius;
      float xd = startX+wi/2;
      float yd = startY+hi/2;
      float f = atan(wi/hi);
      float x = sin(r+f)*xr + xd;
      float y = cos(r+f)*yr + yd;
      this.display.vertex(x, y, this.zpos, p.getTrueWidth(), 0);
      x = sin(r-f+HALF_PI)*xr + xd;
      y = cos(r-f+HALF_PI)*yr + yd;
      this.display.vertex(x, y, this.zpos, 0, 0);
      x = sin(r+f+PI)*xr + xd;
      y = cos(r+f+PI)*yr + yd;
      this.display.vertex(x, y, this.zpos, 0, p.getTrueHeight());
      x = sin(r-f+HALF_PI+PI)*xr + xd;
      y = cos(r-f+HALF_PI+PI)*yr + yd;
      this.display.vertex(x, y, this.zpos, p.getTrueWidth(), p.getTrueHeight());
      x = sin(r+f)*xr + xd;
      y = cos(r+f)*yr + yd;
      this.display.vertex(x, y, this.zpos, p.getTrueWidth(), 0);
      
      
      //float x = sin(r)*xr + xd;
      //float y = cos(r)*yr + yd;
      //this.display.vertex(x, y, this.zpos, 0, 0);
      //x = sin(r-HALF_PI)*xr + xd;
      //y = cos(r-HALF_PI)*yr + yd;
      //this.display.vertex(x, y, this.zpos, p.getTrueWidth(), 0);
      //x = sin(r-PI)*xr + xd;
      //y = cos(r-PI)*yr + yd;
      //this.display.vertex(x, y, this.zpos, p.getTrueWidth(), p.getTrueHeight());
      //x = sin(r-HALF_PI-PI)*xr + xd;
      //y = cos(r-HALF_PI-PI)*yr + yd;
      //this.display.vertex(x, y, this.zpos, 0, p.getTrueHeight());
      //x = sin(r-TWO_PI)*xr + xd;
      //y = cos(r-TWO_PI)*yr + yd;
      //this.display.vertex(x, y, this.zpos, 0, 0);
    }
    else {
      this.display.vertex(startX, startY, this.zpos, 0, 0);
      this.display.vertex(endX, startY,   this.zpos, p.getTrueWidth(), 0);
      this.display.vertex(endX, endY,     this.zpos, p.getTrueWidth(), p.getTrueHeight());
      this.display.vertex(startX, endY,   this.zpos, 0, p.getTrueHeight());
      this.display.vertex(startX, startY, this.zpos, 0, 0);
    }
    
    
    display.endShape();
    display.endDraw();
    display.resetShader();
    if (p.hasShader()) {
      p.getShader().set("time", this.getFramecount() / this.getFramerate());
      display.resetShader();
    }
    
    //setNormalMode();
  }
  
  private int prevDrawPoint;
  
  
  public void gradientHorizontal(int x, int y, float w, float h, int c1, int c2) {
    display.beginDraw();
    display.noFill();
  
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      int c = lerpColor(c1, c2, inter);
      display.stroke(c);
      display.line(x, i, x+w, i);
    }
    display.endDraw();
  }
  
  public void gradientVertical(int x, int y, float w, float h, int c1, int c2) {
    display.beginDraw();
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      int c = lerpColor(c1, c2, inter);
      display.stroke(c);
      display.line(i, y, i, y+h);
    }
    display.endDraw();
  }
    
  public void txt(String t, float x, float y, float size) {
    display.beginDraw();
    display.textAlign(LEFT, LEFT);
    display.textSize(size);
    display.fill(255);
    display.text(t, x, y);
    display.endDraw();
  }
  
  private float flash;
  public void bootsAndCats() {
    if (flash > 0.0f) {
      display.beginDraw();
      display.blendMode(ADD);
      display.fill(this.flash);
      this.flash -= 5.0f;
      display.noStroke();
      display.rect(0,0,display.width,display.height);
      display.blendMode(NORMAL);
      display.endDraw();
    }
  }
  
  public void pump(float flash) {
    this.flash = flash;
  }
  

  
  private ArrayList<File> allImages = new ArrayList<File>();
  private int loadImageIndex = 0;
  
  public void prepareLoadAllImages(String dir) {
    if (!loadOnGoMode) {
       File directory = new File(sketchPath()+"/"+dir);
       if (!directory.exists()) {
         console.error(dir+" directory not found.");
       }
       File[] imgs = directory.listFiles();
       
       for (File f : imgs) {
         allImages.add(f);
         if (f.isDirectory()) {
           prepareLoadAllImages(dir+f.getName()+"/");
         }
       }
       
       
    }
  }
  
  public boolean loading() {
    if (loadImageIndex >= allImages.size()) {
      return false;
    }
    File f = allImages.get(loadImageIndex++);
    this.loadImg(f.getAbsolutePath());
    return true;
  }
  
  public float loadPercentage() {
    return (PApplet.parseFloat(loadImageIndex)/PApplet.parseFloat(allImages.size()));
  }
  
  
  private int minimiseThreshold = 10;
  private int minimise(PImage p)[] {
    p.loadPixels();
    
    int dimensions[] = {0, 0, 0, 0};
    
    //From left
    for (int x = 0; x < p.width; x++) {
      for (int y = 0; y < p.height; y++) {
        if (((p.pixels[(p.width)*(y)+x] >> 24) & 0x000000FF) > minimiseThreshold) {
          dimensions[0] = x;
          
          //End the loops by force setting the conditions to be false.
          x = p.width;
          y = p.height;
        }
      }
    }
    
    //From top
    for (int y = 0; y < p.height; y++) {
      for (int x = 0; x < p.width; x++) {
        if (((p.pixels[(p.width)*(y)+x] >> 24) & 0x000000FF) > minimiseThreshold) {
          dimensions[1] = y;
          
          //End the loops by force setting the conditions to be false.
          x = p.width;
          y = p.height;
        }
      }
    }
    
    //From right
    for (int x = p.width-1; x > 0; x--) {
      for (int y = 0; y < p.height; y++) {
        if (((p.pixels[(p.width)*(y)+x] >> 24) & 0x000000FF) > minimiseThreshold) {
          dimensions[2] = x;
          //End the loops by force setting the conditions to be false.
          x = 0;
          y = p.height;
        }
      }
    }
    
    //From bottom
    for (int y = p.height-1; y > 0; y--) {
      for (int x = 0; x < p.width; x++) {
        if (((p.pixels[(p.width)*(y)+x] >> 24) & 0x000000FF) > minimiseThreshold) {
          dimensions[3] = y;
          
          //End the loops by force setting the conditions to be false.
          x = p.width;
          y = 0;
          
        }
      }
    }
    
    return dimensions;
  }
  
  /*
  private int minimise(PImage p)[] {
    p.loadPixels();
    
    if (((p.pixels[(p.width)*(p.height/2)+p.width/2] >> 24) & 0x000000FF) > minimiseThreshold) 
    {
      return minimise(p, p.width/2, p.height/2);
    }
    else {
      for (int y = 0; y < p.height; y++) {
        for (int x = 0; x < p.width; x++) {
          if (((p.pixels[(p.width)*(y)+x] >> 24) & 0x000000FF) > minimiseThreshold) 
          {
            return minimise(p, x, y);
          }
        }
      }
    }
    int[] empty = {0, 0, 0, 0};
    return empty;
    
  }
  
  private int minimiseThreshold = 127;
  private int minimise(PImage p, int x, int y)[] {
    int dimensions[] = new int[4];
    dimensions[0] = -1;
    dimensions[1] = -1;
    dimensions[2] = -1;
    dimensions[3] = -1;
    if (x-1 >= 0) {
      if (((p.pixels[y*p.height+x-1] >> 24) & 0x000000FF) > minimiseThreshold) {
        p.pixels[y*p.height+x] = 0;
        dimensions[0] = minimise(p, x-1, y)[0];
      }
    }
    if (y-1 >= 0) {
      if (((p.pixels[((y-1)*p.height)] >> 24) & 0x000000FF) > minimiseThreshold) {
        p.pixels[y*p.height+x] = 0;
        dimensions[1] = minimise(p, x, y-1)[1];
      }
    }
    if (x+1 < p.width) {
      if (((p.pixels[y*p.height+x+1] >> 24) & 0x000000FF) > minimiseThreshold) {
        dimensions[2] = minimise(p, x+1, y)[2];
      }
    }
    if (y+1 < p.height) {
      if (((p.pixels[((y+1)*p.height)] >> 24) & 0x000000FF) > minimiseThreshold) {
        p.pixels[y*p.height+x] = 0;
        dimensions[3] = minimise(p, x, y+1)[3];
      }
    }
    
    
    if (dimensions[0] == -1) {
      dimensions[0] = x;
    }
    if (dimensions[1] == -1) {
      dimensions[1] = y;
    }
    if (dimensions[2] == -1) {
      dimensions[2] = x;
    }
    if (dimensions[3] == -1) {
      dimensions[3] = y;
    }
    
    println(dimensions);
    
    
    return dimensions;
  }
  */
  
  
  public void loadAllShaders() {
    if (!loadOnGoMode) {
       File directory = new File(PATH_SHADER);
       if (!directory.exists()) {
         console.error("\""+PATH_SHADER+"\" directory not found.");
       }
       for (File file : directory.listFiles()) {
         PShader s = loadShader(file.getAbsolutePath());
         s.set("u_resolution", PApplet.parseFloat(width), PApplet.parseFloat(height));
         //s.set("iResolution", float(width), float(height));
         shaders.add(s);
         
         String initialName = file.getName();
         String name = initialName.substring(0, initialName.indexOf('.'));
         console.info("Loaded shader "+name);
         shaderNames.set(name, shaders.size()-1);
       }
    }
  }
  
  public PShader getShaderByName(String shaderName) {
    return shaders.get(shaderNames.get(shaderName));
  }
  
  public void addPostProcessingShader(PShader shader) {
    postProcessingShaders.add(shader);
  }
  
  public void addPostProcessingShader(String shaderName) {
    postProcessingShaders.add(getShaderByName(shaderName));
  }
  
  public void nextFrame() {
    this.framecount++;
  }
  
  private int recFrame = 0;
  public void display() {
    
    for (PShader shader : shaders) {
      shader.set("u_time", this.getFramecount() / this.getFramerate());
      //shader.set("iTime", this.getFramecount() / this.getFramerate());
    }
    
    for (PShader shader : postProcessingShaders) {
      this.shaderCanvas.beginDraw();
      this.shaderCanvas.shader(shader);
      this.shaderCanvas.image(this.display, 0, 0, this.display.width, this.display.height);
      this.shaderCanvas.endDraw();
      display.beginDraw();
      display.clear();
      display.endDraw();
      this.display.beginDraw();
      this.display.image(this.shaderCanvas, 0, 0, this.display.width, this.display.height);
      this.display.endDraw();
      
    }
    
    image(this.display, 0, 0, width, height);
    
    if (record && looperHasRun) {
      if (recFrame == 0) {
        recFrame++;        
      }
      else {
        String fn = "";
        if (recFrame < 10) {
          fn = "0000"+str(recFrame);
        }
        else if (recFrame < 100) {
          fn = "000"+str(recFrame);
        }
        else if (recFrame < 1000) {
          fn = "00"+str(recFrame);
        }
        else if (recFrame < 10000) {
          fn = "0"+str(recFrame);
        }
        recFrame++;
        display.save(FRAMES_FOLDER_DIR+fn+".tiff");
      }
    }
    //display.save("C:/My Data/Frames/"+str(this.framecount)+".tga");
    
    display.beginDraw();
    display.clear();
    display.endDraw();
    shaderCanvas.beginDraw();
    shaderCanvas.clear();
    shaderCanvas.endDraw();
    looperHasRun = false;
    
    
  }
}



public class SketchImage {
    PImage img;
    PShape quad;
    float wid;
    float high;
    boolean ready = false;
    PShader shader;
    
    
    public SketchImage(PImage img, float w, float h) {
      this.img = img;
      this.wid = w;
      this.high = h;
      this.createQuad();
    }
    public SketchImage(PImage img) {
      this.img = img;
      this.wid = img.width;
      this.high = img.height;
      this.createQuad();
    }
    
    private void createQuad() {
      this.quad = createShape();
      this.quad.setVisible(true);
      this.quad.beginShape(QUAD);
      this.quad.noStroke();
      this.quad.texture(this.img);
      this.quad.normal(0, 0, 1);
      
      float startX = 0, startY = this.wid;
      float endX   = 0, endY   = this.high;
      
      this.quad.vertex(startX, startY, 0, 0);
      this.quad.vertex(endX, startY, this.img.width, 0);
      this.quad.vertex(endX, endY, this.img.width, this.img.height);
      this.quad.vertex(startX, endY, 0, this.img.height);
      this.quad.endShape();
    }
    
    public void setWi(float w) {
      this.wid = w;
    }
    
    public void setHi(float h) {
      this.high = h;
    }
    
    public boolean hasShader() {
      return !(this.shader == null);
    }
    
    public PShader getShader() {
      return this.shader;
    }
    public void setShader(PShader shader) {
      this.shader = shader;
    }
    
    public void setImg(PImage i) {
      this.img = i;
    }
    
    public boolean isReady() {
      if (this.getImg().width != 0) {
        this.ready = false;
        return true;
      }
      else {
        return false;
      }
    }
    
    public boolean errorOccured() {
      return (this.getImg().width <= -1);
    }
    
    public PImage getImg() {
      return this.img;
    }
    public float getWidth() {
      return this.wid;
    }
    public float getHeight() {
      return this.high;
    }
    
    public float getTrueWidth() {
      return this.img.width;
    }
    public float getTrueHeight() {
      return this.img.height;
    }
    
    public boolean intertedHeight() {
      return (this.getHeight() < 0);
    }
  }
//*******************************************
//*****************SETTINGS******************
int frameWidth = 1024, frameHeight = 1024;
int     framerate              = 60;
int   clearColor             = color(0);
float   renderScale            = 1.0f;
int     interval               = 1;
boolean rec                    = false;
boolean loadOnGo               = false;
boolean fastRendering          = true;
boolean exitWhenMusicEnds      = true;
boolean extraDebugInfo         = true;
//*******************************************
//************IMAGE ATTRIBUTES***************
String imgAttributes[] = {
};
//*******************************************
//*************SETUP CODE HERE***************
public void ready() {
  playMusic("music.wav", 107.96f, 0.5f);
}
//*******************************************
//*************LOOP CODE HERE****************
int blinkk = 0;
public void looper() {
  back("sunset");
  float f = (framecount/60.f)*2.f+HALF_PI;
  
  
  for (int i = 1; i < 30; i++) {
    float ii = PApplet.parseFloat(i);
    float t = f*0.2f + noise(ii)*15.f;
    float size = 2.f;
    img("cloud", 1000-PApplet.parseInt(  (t-floor(t))*2000.f  ), PApplet.parseInt(  height-500 ), PApplet.parseInt( size*500*noise(ii) ), PApplet.parseInt( size*300*noise(ii) ) );
  }
  
  boolean glo = false;


  int ne = floor(framecount/10)%3 + 1;
  String nee = "n"+str(ne);
  if (floor(framecount/10)%12 + 1 == 12) {
    nee = "n"+str(ne)+"_blinkk";
  }
  sprite("neeeeeeee", nee);
  sprite("anchor");
  if (glo) sprite("glow", "back");
  sprite("overlay", "sky");
  if (glo) sketchie.draw.getShaderByName("starboard_glow").set("off", (float)sketchie.getSprite("glow").getX(), (float)sketchie.getSprite("glow").getY());
  sketchie.draw.getShaderByName("starboard_overlay").set("off", (float)sketchie.getSprite("overlay").getX(), (float)sketchie.getSprite("overlay").getY());
  autoSetShader("back", "starboard_glow");
  autoSetShader("sky", "starboard_overlay");
  if (glo) move("glow", 0, sin(f)*50);
  move("overlay", 0, sin(f)*50);
  move("neeeeeeee", 0, sin(f)*50);
  move("anchor", 0, sin(f)*50 - 50);
  //sprite("782384", "dougg");
  //sprite("7384", "shirt");
  
  for (int i = 1; i < 20; i++) {
    float ii = PApplet.parseFloat(i);
    float t = f*0.2f + noise(ii)*15.f;
    float size = 4.f;
    img("cloud", 1000-PApplet.parseInt(  (t-floor(t))*2000.f  ), PApplet.parseInt(  height-400 ), PApplet.parseInt( size*500*noise(ii) ), PApplet.parseInt( size*300*noise(ii) ) );
  }
  
  if (framecount > 300) {
    //exit();
  }
  
  sprite("sigblack");
}
//*******************************************k
  public float getScaleX() {
    return sketchie.draw.getScaleX();
  }
  
  public float getScaleY() {
    return sketchie.draw.getScaleY();
  }
  
  public void loadingBar() {
    noStroke();
    float w = 200;
    float h = 40;
    fill(80);
    rect(width/2-w/2, height/2-h/2, w, h);
    fill(255);
    if (sketchie != null) {
      rect(width/2-w/2, height/2-h/2, w*sketchie.draw.loadPercentage(), h);
    }
  }
  
  public void log(Object s) {
    sketchie.console.log(s);
  }
  
  public void log(int s) {
    sketchie.console.log(str(s));
  }
  
  public void log(String s) {
    sketchie.console.log(s);
  }
  
  public void warn(String s) {
    sketchie.console.warn(s);
  }
  
  public void error(String s) {
    sketchie.console.error(s);
  }
  
  public void info(String s) {
    sketchie.console.info(s);
  }
  
  public void togglePlayPause() {
    sketchie.togglePlayPause();
  }
  
  public void setNormalSpeed() {
    frameRate(sketchie.draw.getFramerate());
  }
  
  
  public void setHalfSpeed() {
    frameRate(sketchie.draw.getFramerate()*0.5f);
  }
  
  public void setQuarterSpeed() {
    frameRate(sketchie.draw.getFramerate()*0.25f);
  }
  
  public void setSuperslowSpeed() {
    frameRate(sketchie.draw.getFramerate()*0.1f);
  }
  
  public void record() {
    sketchie.draw.disableFastRendering();
    sketchie.hideUI();
    record = true;
    frameRate(999);
    log("Recording starting.");
  }
  
  public void back(String name) {
    sketchie.draw.autoImg(name, 0, 0, sketchie.draw.width(), sketchie.draw.height());
  }
  
  public void img(String name) {
    sketchie.draw.autoImg(name, 0, 0, sketchie.draw.width(), sketchie.draw.height());
  }
  
  public void img(String name, int x, int y) {
    sketchie.draw.autoImg(name, x, y, sketchie.draw.width(), sketchie.draw.height());
  }
  
  public void img(String name, int x, int y, int w, int h) {
    sketchie.draw.autoImg(name, x, y, w, h);
  }
  
  public void sprite(String identifier, String imgname) {
    sketchie.sprite(identifier, imgname);
  }
  
  public void sprite(String nameAndID) {
    sketchie.sprite(nameAndID, nameAndID);
  }
  
  public void move(String identifier, float x, float y) {
    sketchie.getSprite(identifier).offmove(x, y);
  }
  
  public void size(String identifier, float w, float h) {
    sketchie.getSprite(identifier).offsetWidth((int)w);
    sketchie.getSprite(identifier).offsetHeight((int)h);
  }
  
  public void vertex0(String identifier, float x, float y) {
    sketchie.getSprite(identifier).offvertex(0, x, y);
  }
  
  public void vertex1(String identifier, float x, float y) {
    sketchie.getSprite(identifier).offvertex(1, x, y);
  }
  
  public void vertex2(String identifier, float x, float y) {
    sketchie.getSprite(identifier).offvertex(2, x, y);
  }
  
  public void vertex3(String identifier, float x, float y) {
    sketchie.getSprite(identifier).offvertex(3, x, y);
  }
  
  public void bop(String identifier) {
    sketchie.bop(identifier, 0.2f);
  }
  
  public void bop(String identifier, float b) {
    sketchie.bop(identifier, b);
  }
  
  public void resetBop(String identifier) {
    sketchie.resetBop(identifier);
  }
  
  public void playMusic(String name, float tempo, float amp) {
    sketchie.playMusic("data/music/"+name, tempo, amp);
  }
  
  public void exitWhenMusicEnds() {
    sketchie.exitWhenMusicEnds();
  }
  
  public PShader getShaderByName(String shaderName) {
    return sketchie.draw.getShaderByName(shaderName);
  }
  
  public void addPostProcessingShader(String shaderName) {
    sketchie.draw.addPostProcessingShader(shaderName);
  }
  
  public void autoSetShader(String imgName, String shadderName) {
    sketchie.draw.autoSetShader(imgName, shadderName);
  }
  
  public void runScript(String scriptName) {
    try {
      Desktop desktop = null;
      if (Desktop.isDesktopSupported()) {
        desktop = Desktop.getDesktop();
      }

       desktop.open(new File(sketchPath()+"/data/engine/scripts/"+scriptName));
    } catch (IOException ioe) {
      ioe.printStackTrace();
    }
    
  }
  
  
  String musicFileName = "";
  SoundFile loadedMusic;
  public void loadMusic() {
    loadedMusic = new SoundFile(app, musicFileName);
  }
  
  public boolean beat() {
    return sketchie.beat();
  }
  
  public boolean halfBeat() {
    return sketchie.halfBeat();
  }
  
  public boolean doubleBeat() {
    return sketchie.doubleBeat();
  }
  
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Sketchiepad" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
