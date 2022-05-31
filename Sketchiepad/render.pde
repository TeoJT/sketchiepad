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
  private Float framerate  = 60.0;
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
    this.ready(w, int(height*aspect));
  }
  
  public Render(float scale) {
    this.ready(int(width*scale), int(height*scale));
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
          float aspect = float(I.width)/float(I.height);
          if (I.height >= I.width) {
            wid  = int(float(lowResBase)*aspect);
            high = lowResBase;
          }
          else {
            wid  = lowResBase;
            high = int(lowResBase/aspect);
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
    this.hi = s.getHeight()-int((float)s.getHeight()*s.getBop());
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
    this.hi = s.getHeight()-int((float)s.getHeight()*s.getBop());
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
  
  public void tint(color col) {
    display.tint(col);
  }
  
  public void noTint() {
    display.noTint();
  }
  
  private float zpos = 1.0;
  
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
    
    float w = 0.0, h = 0.0;
    
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
      display.stroke(sin(frameCount*0.1)*127+127, 100);
      display.strokeWeight(2);
    }
    else {
      display.noStroke();
    }
    display.beginShape();
    display.texture(p.getImg());
    
    float startX = 0.0, startY = 0.0;
    float endX = 0.0,   endY = 0.0  ;
    
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
  
  
  public void gradientHorizontal(int x, int y, float w, float h, color c1, color c2) {
    display.beginDraw();
    display.noFill();
  
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      display.stroke(c);
      display.line(x, i, x+w, i);
    }
    display.endDraw();
  }
  
  public void gradientVertical(int x, int y, float w, float h, color c1, color c2) {
    display.beginDraw();
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
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
    if (flash > 0.0) {
      display.beginDraw();
      display.blendMode(ADD);
      display.fill(this.flash);
      this.flash -= 5.0;
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
    return (float(loadImageIndex)/float(allImages.size()));
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
         s.set("u_resolution", float(width), float(height));
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
