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
  private float defradius = 100.; //radiusY = 50.;
  
  private float offxpos, offypos;
  private int offwi = 0, offhi = 0;
  private QuadVertices offvertex;
  private float offrot = HALF_PI;
  private float offradius = 100.; //radiusY = 50.;
  
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
  private float bop = 0.0;
  private Transform mode = Transform.SINGLE;
  private float rot = HALF_PI;
  private float radius = 100.; //radiusY = 50.;
  
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
    bop = 0.2;
  }

  public void bop(float b) {
    bop = b;
  }

  public void resetBop() {
    bop = 0.0;
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
    bop *= 0.85;
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
    this.wi = int((float)w*r.getScaleX());
    defwi =   int((float)w*r.getScaleX());
  }

  public void setHeight(int h) {
    this.hi = int((float)h*r.getScaleY());
    defhi =   int((float)h*r.getScaleY());
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
    float xd = xpos+float(wi)/2;
    float yd = ypos+float(hi)/2;
    float f = 0;
    if (wi > hi) {
      f = 1-(float(hi)/float(wi));
    }
    else if (hi > wi) {
      f = 1-(float(wi)/float(hi));
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
          wi = int((mouseX+d/2-xpos)*r.getScaleX());
          hi = int((mouseX+d/2-xpos)*r.getScaleX()*aspect);
          
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
          float decx = float(mouseX)-cx;
          float decy = cy-float(mouseY);
          if (decy < 0) {
            rot = atan(-decx/decy);
          }
          else {
            rot = atan(-decx/decy)+PI;
          }
          
          float a = float(wi)/float(hi);
          float s = sin(rot);//, c = a*-cos(rot);
          if (s != 0.0) {
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
    fill(sin(frameCount*0.1)*50+200, 100);
    rect(x, y, d, d);
  }
}
