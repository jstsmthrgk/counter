import java.text.SimpleDateFormat;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.Date;

enum EState {
  SETUP,
  GAME;
}

PImage crown;
EState state = EState.SETUP;
int playernum = 4;
float unit = 1;
int initialpoints = 0;
int mousemovement = 0;
int current = -1;
int[] points;
int[] progress;
float[] lastknown;
int common = 0;
DateFormat dateformatter;
NumberFormat numformatter;

void setup() {
  fullScreen();
  crown  = loadImage("crown.png");
  dateformatter = new SimpleDateFormat("HH:mm");
  numformatter = new DecimalFormat("0.#");
}

void draw() {
  if(state == EState.SETUP){
    background(255);
    fill(0);
    stroke(0);
    strokeWeight(4);
    textAlign(CENTER,CENTER);
    line(0,height*0.3,width,height*0.3);
    line(0,height*0.5,width,height*0.5);
    line(0,height*0.7,width,height*0.7);
    line(0,height*0.9,width,height*0.9);
    textSize(height*0.1);
    text("New Game",width*0.5,height*0.15);
    text(numformatter.format(unit),width*0.75,height*0.4);
    text(numformatter.format(initialpoints*unit),width*0.75,height*0.6);
    text(Integer.toString(playernum),width*0.75,height*0.8);
    textSize(height*0.075);
    text("Start",width*0.5,height*0.95);
    textAlign(LEFT,CENTER);
    text("Unit",width*0.1,height*0.4);
    text("Initial",width*0.1,height*0.6);
    text("Players",width*0.1,height*0.8);
  } else {
    background(0);
    fill(255);
    stroke(255);
    strokeWeight(0);
    ellipse(width*0.5,height*0.5,width,width);
    textAlign(LEFT,TOP);
    textSize(width*0.1);
    text(dateformatter.format(new Date()),width*0.02,width*0.02);
    fill(0);
    stroke(0);
    strokeWeight(4);
    textAlign(CENTER,CENTER);
    textSize(width*0.2);
    translate(width*0.5, height*0.5);
    text(numformatter.format(common*unit),0,0);
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
      text(numformatter.format(points[p]*unit),0,width*0.4);
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
    mousemovement += mouseX - pmouseX;
    int change = mousemovement / ((int)(height * 0.05));
    mousemovement = mousemovement % ((int)(height * 0.05));
    if(current == 0) {
      unit += change;
    } else if(current == 1) {
      initialpoints += change;
    } else if(current == 2) {
      playernum += change;
      if (playernum < 2){
        playernum = 2;
      }
    }
  } else {
    if ( current == -1 )
      return;
    int x = mouseX - width/2;
    int y = mouseY - height/2;
    float angle = 2 * PI / playernum;
    float pos = x * sin(angle*current) - y * cos(angle*current);
    progress[current] += lastknown[current] - pos;
    lastknown[current] = pos;
    int change;
    if (true)
      change = -progress[current] / (int)(width * 0.025);
    else
      change = progress[current] / (int)(width * 0.025);
    progress[current] = progress[current] % (int)(width * 0.025);
    points[current] += change;
    common -= change;
  }
}

void mousePressed() {
  if(state == EState.SETUP) {
    if(mouseY < height*0.3) {
    } else if(mouseY < height*0.5) {
      current = 0;
    } else if(mouseY < height*0.7) {
      current = 1;
    } else if(mouseY < height*0.9) {
      current = 2;
    } else {
      current = 3;
    }
    mousemovement = 0;
  } else {
    int x = mouseX - width/2;
    int y = mouseY - height/2;
    int r = (int) sqrt(pow(x,2)+pow(y,2));
    if(r < width*0.1 || r > width*0.5){
      current = -1;
      return;
    }
    float phi = atan2(x,y) + PI;
    float angle = 2 * PI / playernum;
    phi = phi - angle/2;
    phi = ( phi + 2 * PI ) % ( 2* PI );
    current = playernum - (int) (phi / angle) - 1;
    float pos = x * sin(angle*current) - y * cos(angle*current);
    lastknown[current] = pos;
  }
}

void mouseReleased() {
  if(state == EState.SETUP){
    if(current == 3) {
      state = EState.GAME;
      points = new int[playernum];
      progress = new int[playernum];
      lastknown = new float[playernum];
      current = -1;
      for(int p = 0; p < playernum; p++){
        points[p] = initialpoints;
        progress[p] = 0;
      }
    }
    mousemovement = 0;
  } else {
    for(int p = 0; p < playernum; p++){
      progress[p] = 0;
    }
  }
}