class Beat {
  private float bpm = 120;
  private SoundFile music;
  private int playhead;
  
  private int markBeat;
  private float vol;
  private int framecount;
  private float framerate = 60.0;
  
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
    music.amp(0.0);
  }
  public void unmute() {
    music.amp(vol);
  }
  
  public boolean isPlaying() {
    float currentTime = float(millis()-playhead)/1000.0;
    return (currentTime < this.music.duration());
  }
  
  public void syncMusic(float fr, int fc) {
    this.framecount = fc;
    this.framerate  = fr;
    float currentTime = float(millis()-playhead)/1000.0;
    float expectedDuration = fc/fr;
    float tolerance = 0.05;
    if ((currentTime > expectedDuration+tolerance) || (currentTime < expectedDuration-tolerance)) {
      float difference = currentTime-expectedDuration;
      music.jump(currentTime-difference);
      playhead += int(difference*1000.0);
    }
  }
  
  public float getPlayhead() {
    return playhead/1000.;
  }
  
  public float duration() {
    return music.duration();
  }
  
  public void musicJumpAhead(float t) {
      float currentTime = float(millis()-playhead)/1000.0;
      float difference = currentTime-t;
      music.jump(currentTime-difference);
      playhead += int(difference*1000.0);
  }
  
  
  private float myFrameCount() {
    return this.framecount-1;
  }
  
  
  private float framesPerBeat() {
    return ((this.framerate/(bpm/this.framerate))*2.);
  }
  public int totalBeats() {
    return floor(myFrameCount()/framesPerBeat())+1;
  }
  public int beatToFrameCount(int beat) {
    return round(float(beat-1)*framesPerBeat());
  }
  
  
  private float framesPerStep() {
    return ((this.framerate/(this.bpm/(this.framerate/4)))*2);
  }
  public int totalSteps() {
    return floor(myFrameCount()/framesPerStep())+1;
  }
  public int stepToFrameCount(int step) {
    return round(float(step-1)*framesPerStep());
  }
  public int relativeStep() {
    return floor(myFrameCount()/framesPerStep())+5-this.totalBeats()*4;
  }
  
  public boolean flashBeat() {
    int offset = int(this.framerate);
    return ((myFrameCount()+offset) % framesPerBeat() < 1.0);
  }
  public boolean flashStep() {
    int offset = int(this.framerate);
    return ((myFrameCount()+offset) % framesPerStep() < 1.0);
  }
  public boolean flashBeat(int interval, int intervalDelay) {
    int offset = int(this.framerate);
    return (((myFrameCount()+offset) - (framesPerStep()*float(intervalDelay)) ) % (framesPerBeat()*interval) < 1.0);
  }
  public boolean flashStep(int interval, int intervalDelay) {
    int offset = int(this.framerate);
    return (((myFrameCount()+offset) - (framesPerStep()*float(intervalDelay)) )%(framesPerStep()*interval) < 1.0);
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
  private color col;
  private int depth;
  public void visualBeat(int interval, int intervalDelay, int depth, color col) {
    if (this.flashStep(interval, intervalDelay)) {
      fade = 1.0;
      this.col = col;
      this.depth = depth;
    }
    
    renderVisualBeat();
  }
  
  public void visualBeatNow(int depth, color col) {
    fade = 1.0;
    this.col = col;
    this.depth = depth;
  }
  
  public void renderVisualBeat() {
    strokeWeight(1);
    noFill();
    for (int x = 0; x < this.depth; x++) {
      float c = ((-float(x)+this.depth)/float(this.depth))*fade;
      stroke(this.col, c*255);
      rect(x,x,width-x*2,height-x*2);
    }
    fade *= 0.90;
  }
  
  public void setMark() {
    markBeat = this.totalBeats();
  }
  
  public int fromMarkBeat() {
    return this.totalBeats()-markBeat;
  }
}
