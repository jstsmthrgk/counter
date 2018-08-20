enum EState {
  SETUP,
  GAME;
}

PImage crown;
EState state = EState.SETUP;
int playernum = 4;
int mousemovement = 0;
int current = -1;
int[] points;
int[] progress;
float[] lastknown;
int common = 0;

void setup() {
  fullScreen();
  crown  = loadImage("crown.png");
}

void draw() {
  background(255);
  fill(0);
  stroke(0);
  strokeWeight(4);
  textAlign(CENTER,CENTER);
  if(state == EState.SETUP){
    line(0,height*0.9,width,height*0.9);
    line(0,height*0.5,width,height*0.5);
    textSize(height*0.1);
    text("Start",width*0.5,height*0.95);
    textSize(height*0.2);
    text(Integer.toString(playernum),width*0.5,height*0.7);
  } else {
    textSize(width*0.2);
    translate(width*0.5, height*0.5);
    rotate(PI*1.5);
    text(Integer.toString(common),0,0);
    rotate(PI*0.5);
    textSize(width*0.1);
    float angle = 2 * PI / playernum;
    rotate(PI);
    int bestnum = Integer.MIN_VALUE;
    int bestpl = -1;
    boolean justone = false;
    for(int p = 0; p < playernum; p++){
      if (points[p] > bestnum) {
        bestnum = points[p];
        bestpl = p;
        justone = true;
      } else if (points[p] == bestnum) {
        justone = false;
      }
      text(Integer.toString(points[p]),0,width*0.4);
      rotate(angle);
    }
    if(bestpl != -1 && justone) {
      rotate(bestpl * angle);
      imageMode(CENTER);
      image(crown, 0, width*0.25, width*0.15, width*0.15);
    }
  }
}

void mouseDragged() {
  if(state == EState.SETUP){
    mousemovement += pmouseX - mouseX + pmouseY - mouseY;
    playernum += mousemovement / ((int)(height * 0.05));
    mousemovement = mousemovement % ((int)(height * 0.05));
    if (playernum < 1){
      playernum = 1;
    }
  } else {
    if ( current == -1 )
      return;
    int x = mouseX - width/2;
    int y = mouseY - height/2;
    float r = sqrt(pow(x,2)+pow(y,2));
    progress[current] += lastknown[current] - r;
    lastknown[current] = r;
    int change = -progress[current] / (int)(width * 0.025);
    progress[current] = progress[current] % (int)(width * 0.025);
    points[current] += change;
    common -= change;
  }
}

void mousePressed() {
  if(state == EState.SETUP){
    
  } else {
    int x = mouseX - width/2;
    int y = mouseY - height/2;
    int r = (int) sqrt(pow(x,2)+pow(y,2));
    if(r < width*0.1){
      current = -1;
      return;
    }
    float phi = atan2(x,y) + PI;
    float angle = 2 * PI / playernum;
    phi = phi - angle/2;
    phi = ( phi + 2 * PI ) % ( 2* PI );
    current = playernum - (int) (phi / angle) - 1;
    lastknown[current] = r;
  }
}

void mouseReleased() {
  if(state == EState.SETUP){
    mousemovement = 0;
    if(mouseY > height * 0.9) {
      state = EState.GAME;
      points = new int[playernum];
      progress = new int[playernum];
      lastknown = new float[playernum];
      current = -1;
      for(int p = 0; p < playernum; p++){
        points[p] = 0;
        progress[p] = 0;
      }
    }
  } else {
    for(int p = 0; p < playernum; p++){
      progress[p] = 0;
    }
  }
}