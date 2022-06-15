//*******************************************
//*****************SETTINGS******************
int frameWidth = 1024, frameHeight = 1024;
int     framerate              = 60;
color   clearColor             = color(0);
float   renderScale            = 1.0;
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
void ready() {
  playMusic("music.wav", 107.96, 0.5);
}
//*******************************************
//*************LOOP CODE HERE****************
int blinkk = 0;
void looper() {
  back("sunset");
  float f = (framecount/60.)*2.+HALF_PI;
  
  
  for (int i = 1; i < 30; i++) {
    float ii = float(i);
    float t = f*0.2 + noise(ii)*15.;
    float size = 2.;
    img("cloud", 1000-int(  (t-floor(t))*2000.  ), int(  height-500 ), int( size*500*noise(ii) ), int( size*300*noise(ii) ) );
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
    float ii = float(i);
    float t = f*0.2 + noise(ii)*15.;
    float size = 4.;
    img("cloud", 1000-int(  (t-floor(t))*2000.  ), int(  height-400 ), int( size*500*noise(ii) ), int( size*300*noise(ii) ) );
  }


  if (keyframe("x")) {
    sketchie.draw.pump(100);
    dis.fill(color(255,0,0));
    dis.rect(20, 20, 100, 100);
  }
  
  sketchie.draw.bootsAndCats();
  
  if (framecount > 300) {
    //exit();
  }
  
  sprite("sigblack");
}
//*******************************************k
