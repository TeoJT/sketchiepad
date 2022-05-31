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
  
  void togglePlayPause() {
    sketchie.togglePlayPause();
  }
  
  void setNormalSpeed() {
    frameRate(sketchie.draw.getFramerate());
  }
  
  
  void setHalfSpeed() {
    frameRate(sketchie.draw.getFramerate()*0.5);
  }
  
  void setQuarterSpeed() {
    frameRate(sketchie.draw.getFramerate()*0.25);
  }
  
  void setSuperslowSpeed() {
    frameRate(sketchie.draw.getFramerate()*0.1);
  }
  
  void record() {
    sketchie.draw.disableFastRendering();
    sketchie.hideUI();
    record = true;
    frameRate(999);
    log("Recording starting.");
  }
  
  void back(String name) {
    sketchie.draw.autoImg(name, 0, 0, sketchie.draw.width(), sketchie.draw.height());
  }
  
  void img(String name) {
    sketchie.draw.autoImg(name, 0, 0, sketchie.draw.width(), sketchie.draw.height());
  }
  
  void img(String name, int x, int y) {
    sketchie.draw.autoImg(name, x, y, sketchie.draw.width(), sketchie.draw.height());
  }
  
  void img(String name, int x, int y, int w, int h) {
    sketchie.draw.autoImg(name, x, y, w, h);
  }
  
  void sprite(String identifier, String imgname) {
    sketchie.sprite(identifier, imgname);
  }
  
  void sprite(String nameAndID) {
    sketchie.sprite(nameAndID, nameAndID);
  }
  
  void move(String identifier, float x, float y) {
    sketchie.getSprite(identifier).offmove(x, y);
  }
  
  void size(String identifier, float w, float h) {
    sketchie.getSprite(identifier).offsetWidth((int)w);
    sketchie.getSprite(identifier).offsetHeight((int)h);
  }
  
  void vertex0(String identifier, float x, float y) {
    sketchie.getSprite(identifier).offvertex(0, x, y);
  }
  
  void vertex1(String identifier, float x, float y) {
    sketchie.getSprite(identifier).offvertex(1, x, y);
  }
  
  void vertex2(String identifier, float x, float y) {
    sketchie.getSprite(identifier).offvertex(2, x, y);
  }
  
  void vertex3(String identifier, float x, float y) {
    sketchie.getSprite(identifier).offvertex(3, x, y);
  }
  
  void bop(String identifier) {
    sketchie.bop(identifier, 0.2);
  }
  
  void bop(String identifier, float b) {
    sketchie.bop(identifier, b);
  }
  
  void resetBop(String identifier) {
    sketchie.resetBop(identifier);
  }
  
  void playMusic(String name, float tempo, float amp) {
    sketchie.playMusic("data/music/"+name, tempo, amp);
  }
  
  void exitWhenMusicEnds() {
    sketchie.exitWhenMusicEnds();
  }
  
  PShader getShaderByName(String shaderName) {
    return sketchie.draw.getShaderByName(shaderName);
  }
  
  void addPostProcessingShader(String shaderName) {
    sketchie.draw.addPostProcessingShader(shaderName);
  }
  
  void autoSetShader(String imgName, String shadderName) {
    sketchie.draw.autoSetShader(imgName, shadderName);
  }
  
  void runScript(String scriptName) {
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
  void loadMusic() {
    loadedMusic = new SoundFile(app, musicFileName);
  }
  
  boolean beat() {
    return sketchie.beat();
  }
  
  boolean halfBeat() {
    return sketchie.halfBeat();
  }
  
  boolean doubleBeat() {
    return sketchie.doubleBeat();
  }
  
