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
  GAME,
  INFO;
}

PImage crown, info, plus, minus, back, iclose, pause;
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
int scroll;
String infotext;
int direction = 0;
int untilnext = 0;

void setup() {
  fullScreen();
  crown = loadImage("crown.png");
  info = loadImage("info.png");
  plus = loadImage("plus.png");
  minus = loadImage("minus.png");
  back = loadImage("back.png");
  iclose = loadImage("close.png");
  pause = loadImage("pause.png");
  dateformatter = new SimpleDateFormat("HH:mm");
  numformatter = new DecimalFormat("0.##");
  context = getContext();
  savefile = context.getFilesDir().getAbsolutePath() + "/savegame.bin";
  scroll = (int) (-width*0.05);
  infotext = "";
  for(String line : loadStrings("info.txt")) {
    infotext += line + "\n";
  }
}

void draw() {
  if(state == EState.START){
    background(255);
    fill(0);
    stroke(0);
    strokeWeight(1);
    textSize(width*0.1);
    textAlign(CENTER,CENTER);
    line(0,height*0.5,width,height*0.5);
    text("Continue",width*0.5,height*0.25);
    text("New Game",width*0.5,height*0.75);
    imageMode(CORNER);
    image(info, width*0.85, 0, width*0.15, width*0.15);
    image(iclose, 0, 0, width*0.15, width*0.15);
  } else if(state == EState.SETUP){
    background(255);
    fill(0);
    stroke(0);
    strokeWeight(1);
    textAlign(CENTER,CENTER);
    imageMode(CENTER);
    image(plus,width*0.75,height*0.35,width*0.025,width*0.025);
    image(minus,width*0.75,height*0.45,width*0.025,width*0.025);
    image(plus,width*0.75,height*0.55,width*0.025,width*0.025);
    image(minus,width*0.75,height*0.65,width*0.025,width*0.025);
    image(plus,width*0.75,height*0.75,width*0.025,width*0.025);
    image(minus,width*0.75,height*0.85,width*0.025,width*0.025);
    line(0,height*0.3,width,height*0.3);
    line(0,height*0.5,width,height*0.5);
    line(0,height*0.7,width,height*0.7);
    line(0,height*0.9,width,height*0.9);
    textSize(height*0.1);
    text("New Game",width*0.5,height*0.15);
    textSize(width*0.1);
    text(numformatter.format(unit),width*0.75,height*0.4);
    text(numformatter.format(initialpoints*unit),width*0.75,height*0.6);
    text(Integer.toString(playernum),width*0.75,height*0.8);
    text("Start",width*0.5,height*0.95);
    textAlign(LEFT,CENTER);
    text("Unit",width*0.1,height*0.4);
    text("Initial",width*0.1,height*0.6);
    text("Players",width*0.1,height*0.8);
    imageMode(CORNER);
    image(back, 0, 0, width*0.15, width*0.15);
    if(direction != 0 && untilnext == 0) {
      setupChange();
    }
    untilnext--;
  } else if(state == EState.GAME) {
    background(0);
    fill(255);
    stroke(255);
    strokeWeight(0);
    ellipse(width*0.5,height*0.5,width,width);
    ellipse(width*0.5,height*0.5,width*0.3,width*0.3);
    textAlign(RIGHT,TOP);
    textSize(width*0.1);
    text(dateformatter.format(new Date()),width*0.98,width*0.02);
    imageMode(CORNER);
    image(pause, 0, 0, width*0.15, width*0.15);
    fill(0);
    stroke(0);
    strokeWeight(1);
    textAlign(CENTER,CENTER);
    translate(width*0.5, height*0.5);
    text(numformatter.format(common*unit),0,0);
    float angle = 2 * PI / playernum;
    rotate(PI);
    int bestnum = Integer.MIN_VALUE;
    int bestpl = -1;
    boolean justone = false;
    for(int p = 0; p < playernum; p++){
      imageMode(CENTER);
      image(plus,0,width*0.25,width*0.025,width*0.025);
      image(minus,0,width*0.45,width*0.025,width*0.025);
      if (points[p] > bestnum) {
        bestnum = points[p];
        bestpl = p;
        justone = true;
      } else if (points[p] == bestnum) {
        justone = false;
      }
      text(numformatter.format(points[p]*unit),0,width*0.35);
      rotate(angle);
    }
    if(bestpl != -1 && justone) {
      rotate(bestpl * angle);
      imageMode(CENTER);
      image(crown, 0, width*0.2, width*0.15, width*0.1);
    }
    if(direction != 0 && untilnext == 0) {
      points[current] += direction;
      common -= direction;
      untilnext = 2;
    }
    untilnext--;
  } else if(state == EState.INFO) {
    background(255);
    stroke(0);
    fill(0);
    textSize(width*0.03);
    textAlign(LEFT,TOP);
    text(infotext, width*0.05, 0-scroll, width*0.9, height+scroll);
    stroke(255);
    fill(255);
    rect(0,height*0.9,width,height*0.1);
    stroke(0);
    fill(0);
    strokeWeight(1);
    line(0,height*0.9,width,height*0.9);
    textAlign(CENTER,CENTER);
    textSize(width*0.1);
    text("Back",width*0.5,height*0.95);
  }
}

void setupChange() {
  if(current == 0) {
      int num = (int) (unit / pow(10,unitlevel));
      if(direction < 0) {
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
      }
      unit = num * pow(10,unitlevel);
      if(unitlevel < -2) {
        unit = 0.01;
        unitlevel = -2;
      } else if(unit > 100) {
        unit = 100;
        unitlevel = 2;
      }
      if(unitlevel < 0) {
        numformatter.setMinimumFractionDigits(-unitlevel);
        numformatter.setMaximumFractionDigits(-unitlevel);
      } else {
        numformatter.setMinimumFractionDigits(0);
        numformatter.setMaximumFractionDigits(0);
      }
  } else if(current == 1) {
    initialpoints += direction;
  } else if(current == 2) {
    playernum += direction;
    if (playernum < 2){
      playernum = 2;
    } else if(playernum > 8) {
      playernum = 8;
    }
  }
  untilnext = current == 1 ? 2 : 10 ;
}

void mouseDragged() {
  if(state == EState.INFO) {
    if(current == 0)
      scroll -= mouseY - pmouseY;
    if(scroll < (int) (-width*0.05))
      scroll = (int) (-width*0.05);
  }
}

void mousePressed() {
  if(mouseY < width*0.5 && mouseX < width*0.5) {
    current = -2;
    direction = 0;
    return;
  }
  if(state == EState.START) {
    if(mouseY < width*0.15 && mouseX > width*0.85) {
      current = 2;
    } else if(mouseY < height*0.5) {
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
    if(current != -1) {
      direction = (mouseY % (height*0.2)) < height*0.1 ? -1 : 1 ;
      setupChange();
      untilnext = 20;
    }
  } else if(state == EState.GAME) {
    int x = mouseX - width/2;
    int y = mouseY - height/2;
    int r = (int) sqrt(pow(x,2)+pow(y,2));
    if(r < width*0.15 || r > width*0.5){
      current = -1;
      return;
    }
    float phi = atan2(x,y) + PI;
    float angle = 2 * PI / playernum;
    phi = phi - angle/2;
    phi = ( phi + 2 * PI ) % ( 2* PI );
    current = playernum - (int) (phi / angle) - 1;
    direction = r < width*0.35 ? 1 : -1 ;
    points[current] += direction;
    common -= direction;
    untilnext = 20;
  } else if(state == EState.INFO) {
    if(mouseY > height*0.9) {
      current = 1;
    } else {
      current = 0;
    }
  }
}

void mouseReleased() {
  if(current == -2) {
    if(state == EState.START) {
      System.exit(0);
    } else {
      state = EState.START;
    }
    return;
  }
  if(state == EState.START){
    if(current == 0){
      loadGame();
      state = EState.GAME;
    } else if(current == 1) {
      state = EState.SETUP;
    } else {
      state = EState.INFO;
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
  } else if(state == EState.GAME) {
    saveGame();
  } else if(state == EState.INFO) {
    if(current == 1)
      state = EState.START;
  }
  direction = 0;
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