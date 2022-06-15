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
  private boolean enableBasicUI = false;
  
  private class ConsoleLine {
    private int interval = 0;
    private int pos = 0;
    private String message;
    private color messageColor;
    
    public ConsoleLine() {
      messageColor = color(255,255);
      interval = 0;
      this.message = "";
      this.pos = initialPos;
      basicui = new BasicUI();
    }

    public void enableUI() {
      enableBasicUI = true;
    }

    public void disableUI() {
      enableBasicUI = false;
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
    
    public void message(String message, color messageColor) {
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
            fill(0, 4.25*float(interval));
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
            fill(this.messageColor, 4.25*float(interval));
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
  
  public void consolePrint(Object message, color c) {
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
    if (enableBasicUI) {
      this.basicui.showWarningWindow(message);
    }
  }
  public void error(String message) {
    this.consolePrint("ERROR!! "+message, color(255, 30, 30));
  }
  public void info(Object message) {
    if (this.debugInfo) {
      this.consolePrint(message, color(127));
    }
  }
  public void infoOnce(Object message) {
    if (this.timeout == 0) {
      if (this.debugInfo) {
        this.consolePrint(message, color(127));
      }
    }
    this.timeout = messageDelay;
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
      if (enableBasicUI) {
        this.basicui.showWarningWindow(message);
      }
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
    
    radius *= 0.90;
    
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
