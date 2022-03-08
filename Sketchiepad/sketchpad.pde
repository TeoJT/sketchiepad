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
boolean exitWhenMusicEnds      = false;
boolean extraDebugInfo         = true;
//*******************************************
//************IMAGE ATTRIBUTES***************
String imgAttributes[] = {
 "snoot:mini",
 "food:mini",
 "nom:mini"
};
//*******************************************
//*************SETUP CODE HERE***************
void ready() {
  //playMusic("music.wav", 148., 0.5);
}
//*******************************************
//*************LOOP CODE HERE****************
boolean updown = false;
void looper() {
  //back("back");
  float f = framecount*0.5;
  
  float s = 2.0;
  
  sprite("782384", "dougg");
  sprite("7384", "shirt");
}
//*******************************************k
