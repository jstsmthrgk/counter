import java.text.SimpleDateFormat;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.Date;
import java.nio.ByteBuffer;
import android.content.Context;

enum EState {
  START,
  SETUP,
  GAME;
}

PImage crown;
EState state = EState.START;
int playernum = 4;
float unit = 1;
int unitlevel = 0;
int initialpoints = 0;
int mousemovement = 0;
int current = -1;
int[] points;
int progress = 0;
float lastknown;
int common = 0;
DateFormat dateformatter;
NumberFormat numformatter;
Context context;
String savefile;

void setup() {
  fullScreen();
  crown  = loadImage("crown.png");
  dateformatter = new SimpleDateFormat("HH:mm");
  numformatter = new DecimalFormat("0.##");
  context = getContext();
  savefile = context.getFilesDir().getAbsolutePath() + "/savegame.bin";
}

void draw() {
  if(state == EState.START){
    background(255);
    fill(0);
    stroke(0);
    strokeWeight(4);
    textSize(height*0.1);
    textAlign(CENTER,CENTER);
    line(0,height*0.5,width,height*0.5);
    text("Continue",width*0.5,height*0.25);
    text("New Game",width*0.5,height*0.75);
  } else if(state == EState.SETUP){
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
      image(crown, 0, width*0.3, width*0.15, width*0.1);
    }
  }
}

void mouseDragged() {
  if(state == EState.SETUP){
    mousemovement += mouseX - pmouseX;
    int change;
    if(current == 1) {
      change = mousemovement / ((int)(width * 0.025));
      mousemovement = mousemovement % ((int)(width * 0.025));
    } else {
      change = mousemovement / ((int)(width * 0.1));
      mousemovement = mousemovement % ((int)(width * 0.1));
    }
    if(current == 0) {
      while(change != 0) {
        int num = (int) (unit / pow(10,unitlevel));
        if(change < 0) {
          if(num == 1) {
            num = 5;
            unitlevel--;
          } else if(num == 2) {
            num = 1;
          } else if(num == 5) {
            num = 2;
          } else {
            unit = 1;
            unitlevel = 0;
          }
          change++;
        } else {
          if(num == 1) {
            num = 2;
          } else if(num == 2) {
            num = 5;
          } else if(num == 5) {
            num = 1;
            unitlevel++;
          } else {
            unit = 1;
            unitlevel = 0;
          }
          change--;
        }
        unit = num * pow(10,unitlevel);
        if(unitlevel < -2) {
          unit = 0.01;
          unitlevel = -2;
        }
        if(unitlevel < 0) {
          numformatter.setMinimumFractionDigits(-unitlevel);
          numformatter.setMaximumFractionDigits(-unitlevel);
        } else {
          numformatter.setMinimumFractionDigits(0);
          numformatter.setMaximumFractionDigits(0);
        }
      }
    } else if(current == 1) {
      initialpoints += change;
    } else if(current == 2) {
      playernum += change;
      if (playernum < 2){
        playernum = 2;
      }
    }
  } else if(state == EState.GAME) {
    if ( current == -1 )
      return;
    int x = mouseX - width/2;
    int y = mouseY - height/2;
    float angle = 2 * PI / playernum;
    float pos = x * sin(angle*current) - y * cos(angle*current);
    progress += lastknown - pos;
    lastknown = pos;
    int change;
    if (true)
      change = -progress / (int)(width * 0.025);
    else
      change = progress / (int)(width * 0.025);
    progress = progress % (int)(width * 0.025);
    points[current] += change;
    common -= change;
  }
}

void mousePressed() {
  if(state == EState.START) {
    if(mouseY < height*0.5) {
      current = 0;
    } else {
      current = 1;
    }
  }else if(state == EState.SETUP) {
    if(mouseY < height*0.3) {
      current = -1;
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
    if(r < width*0.025 || r > width*0.5){
      current = -1;
      return;
    }
    float phi = atan2(x,y) + PI;
    float angle = 2 * PI / playernum;
    phi = phi - angle/2;
    phi = ( phi + 2 * PI ) % ( 2* PI );
    current = playernum - (int) (phi / angle) - 1;
    float pos = x * sin(angle*current) - y * cos(angle*current);
    lastknown = pos;
    progress = 0;
  }
}

void mouseReleased() {
  if(state == EState.START){
    if(current == 0){
      loadGame();
      state = EState.GAME;
    } else {
      state = EState.SETUP;
    }
  } else if(state == EState.SETUP){
    if(current == 3) {
      state = EState.GAME;
      points = new int[playernum];
      current = -1;
      for(int p = 0; p < playernum; p++){
        points[p] = initialpoints;
      }
    }
    mousemovement = 0;
  } else {
    saveGame();
  }
}

void saveGame(){
  ByteBuffer data = ByteBuffer.allocate(4*(4+playernum));
  data.putFloat(unit);
  data.putInt(unitlevel);
  data.putInt(playernum);
  data.putInt(common);
  for(int i = 0; i < playernum; i++) {
    data.putInt(points[i]);
  }
  saveBytes(savefile,data.array());
}

void loadGame(){
  byte[] databytes = loadBytes(savefile);
  ByteBuffer data = ByteBuffer.wrap(databytes);
  unit = data.getFloat();
  unitlevel = data.getInt();
  if(unitlevel < 0) {
    numformatter.setMinimumFractionDigits(-unitlevel);
    numformatter.setMaximumFractionDigits(-unitlevel);
  } else {
    numformatter.setMinimumFractionDigits(0);
    numformatter.setMaximumFractionDigits(0);
  }
  playernum = data.getInt();
  common = data.getInt();
  points = new int[playernum];
  for(int i = 0; i < playernum; i++) {
    points[i] = data.getInt();
  }
}