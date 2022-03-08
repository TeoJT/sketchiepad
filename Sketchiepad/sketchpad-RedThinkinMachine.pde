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
 "food:mini"
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
  
  sprite("05xzcxxv83", "back");
  sprite("34zxcv685", "mini starboard");
  sprite("dougg");
  //sprite("doug");
  //sprite("food");
  //sprite("snoot");
  
  //vertex0("face", sin(f)*50*s, cos(f)*30*s);
  //vertex1("face", sin(f)*50*s, cos(f)*30*s);
  
  //move("snoot", sin(f)*30*s, cos(f)*30*s);
  
  //float ss = 50;
  //vertex0("food", sin(f)*ss*s, cos(f)*ss*s);
  //vertex1("food", sin(f)*ss*s, cos(f)*ss*s);
}
//*******************************************k
