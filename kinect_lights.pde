import SimpleOpenNI.*;
SimpleOpenNI context;

ColorBlast[] lights;
final int NUM_LIGHTS = 3;
final int[] LIGHT_CHANNELS = {
  13, 1, 7, 4, 
};

PDS150e ps;
final byte[] PDS150E_IP = {
  (byte)10, (byte)0, (byte)115, (byte)130
};
InetAddress wiredIp = null;

ArrayList handVecList = new ArrayList();


ArrayList sliders;
Slider activeSlider;

void getWiredIp() {
  try {
    NetworkInterface en0 = NetworkInterface.getByName("en0");
    Enumeration addresses = en0.getInetAddresses();
    for (Object addr : Collections.list(addresses))
    {
      if (addr instanceof Inet4Address) {
        wiredIp = (InetAddress)addr;
        //println("Wired IP: " + wiredIp);
        break;
      }
    }
  }
  catch (Exception e) {
    e.printStackTrace();
  }
}

void setupLights() {
  lights = new ColorBlast[NUM_LIGHTS];
  for (int i = 0; i < NUM_LIGHTS; i++) {
    lights[i] = new ColorBlast(LIGHT_CHANNELS[i]);
    ps.addFixture(lights[i]);
  }
}

void setup() {
  size(640, 480);

  // get wired ip
  getWiredIp();

  // create the power supply
  try {
    ps = new PDS150e(InetAddress.getByAddress(PDS150E_IP));
  }
  catch (Exception e) {
    e.printStackTrace();
  }
  setupLights();
  setupSliders();

  // startup the kinect
  context = new SimpleOpenNI(this);
  // mirror is by default enabled
  context.setMirror(true);
  context.enableDepth();
  
  context.enableHands();
}

void setupSliders() {
  sliders = new ArrayList();
}

void draw() {
  //listne to the kinect
  context.update();

  int[ ] allDepths = new int[640*480];
  context.depthMap(allDepths );

  PImage myImg = context.depthImage();

  image(myImg, 0, 0);

  text("Depth: " + allDepths[mouseY * 640 + mouseX], mouseX, mouseY);

  for (int i = 0; i < sliders.size(); i++)
    drawSlider((Slider)sliders.get(i));

  if (activeSlider != null) {
    text(activeSlider.name + "\n" + activeSlider.val(), width/2, 20);
  }
}

void setAllLights(int r, int g, int b) {
  for (int i = 0; i < lights.length; i++) {
    lights[i].setColor(r, g, b);
  } 
  ps.update();
}

void redRoom() {
  setAllLights(255, 0, 0);
}

void greenRoom() {
  setAllLights(0, 255, 0);
}

void whiteRoom() {
  setAllLights(255, 255, 255);
}

void mousePressed() {
  if (activeSlider == null) {
    for (int i = 0; i < sliders.size(); i++) {
      if (((Slider)(sliders.get(i))).contains(mouseX, mouseY))
        activeSlider = (Slider)sliders.get(i);
    }
  }
}

void mouseDragged() {
  if (activeSlider != null) {
    activeSlider.update(mouseX);
  }
}

void mouseReleased() {
  if (activeSlider != null) {
    activeSlider.update(mouseX);
    activeSlider = null;
  }
}

void drawSlider(Slider s) {
  noStroke();
  strokeWeight(1);
  fill(0, 255, 0);
  rect(s.minX, s.minY, s.maxX-s.minX, s.maxY-s.minY); 
  float valX = s.minX + (s.maxX - s.minX) * s.val;
  fill(200, 200, 200);
  rect(valX-2, s.minY, 4, s.maxY-s.minY);
}

class Slider {
  String name;
  float minX, minY, maxX, maxY;
  float val;
  float range;
  Slider(String n, float r, float d, float x1, float y1, float x2, float y2) {
    println("("+x1+", " + y1 + ", " + x2 + ", " + y2 +")");
    name = n;
    val = d;
    range = r;
    minX = min(x1, x2);
    maxX = max(x1, x2);
    minY = min(y1, y2);
    maxY = max(y1, y2);
  }

  boolean contains(int mouseX, int mouseY) {
    return (mouseX > minX && mouseX < maxX && mouseY > minY && mouseY < maxY);
  } 
  void update(float v) {
    val = max(0.0, min(1.0, (v-minX)/(maxX-minX)));
    //println(name + ": " + val);
  }
  float val() {
    return val * range;
  }
}

void onCreateHands(int handId,PVector pos,float time)
{
  println("onCreateHands - handId: " + handId + ", pos: " + pos + ", time:" + time);
}

void onUpdateHands(int handId,PVector pos,float time)
{
}

void onDestroyHands(int handId,float time)
{
  println("onDestroyHandsCb - handId: " + handId + ", time:" + time);
}

