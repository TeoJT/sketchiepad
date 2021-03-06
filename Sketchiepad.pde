import java.io.File;
import java.io.IOException;
import java.awt.Desktop;
import processing.sound.*;


PApplet app;
boolean record = false;
SketchieEngine sketchie;
float framecount = 0;
boolean doneLoading = true;

void settings() {
  System.setProperty("jogl.disable.openglcore", "false");
  size(frameWidth, frameHeight, P2D);
}
SoundFile sndNope;



void setup() {
  loadingBar();
  app = this;
  sndNope = new SoundFile(app, PATH_SND_NOPE);
  sketchie = new SketchieEngine(renderScale);
  dis = sketchie.draw.display;
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

void draw() {
  background(clearColor);
  sketchie.emptySpriteStack();
  framecount = float(sketchie.draw.getFramecount());
  if (frameCount == 2) {
    loadingBar();
    sketchie.draw.prepareLoadAllImages(PATH_IMG);
    sketchie.draw.prepareLoadAllImages(PATH_DEFAULTIMG);
    ready();
    if (rec) {
       File directory = new File(FRAMES_FOLDER_DIR);
       if (!directory.exists()) {
         error("\"frames\" directory not found.");
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
    sketchie.draw.setFramecount(0);
  }
  else if (frameCount > 2) {
    dis.beginDraw();
    looper();
    dis.endDraw();
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
  globalKeyPressed = false;
  globalEnter = false;
}
