enum EState {
  SETUP,
  GAME;
}

EState state = EState.SETUP;
int playernum = 4;
int mousemovement = 0;
int[] points;
int[] progress;
int common = 0;

void setup() {
  fullScreen();
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
    textSize(height / playernum / 2);
    for(int p = 0; p < playernum; p++){
      text(Integer.toString(points[p]),width*0.25,height/playernum*(p+0.5));
    }
    text(Integer.toString(common),width*0.75,height*0.5);
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
    int player = pmouseY / (height / playernum);
    progress[player] += pmouseX - mouseX;
    int change = progress[player] / (int)(width * 0.1);
    progress[player] = progress[player] % (int)(width * 0.1);
    points[player] += change;
    common -= change;
    for(int p = 0; p < playernum; p++){
      if(p != player)
        progress[p] = 0;
    }
  }
}

void mousePressed() {
  if(state == EState.SETUP && mouseY > height * 0.9){
    state = EState.GAME;
    points = new int[playernum];
    progress = new int[playernum];
    for(int p = 0; p < playernum; p++){
      points[p] = 0;
      progress[p] = 0;
    }
  }
}

void mouseReleased() {
  if(state == EState.SETUP){
    mousemovement = 0;
  } else {
    for(int p = 0; p < playernum; p++){
      progress[p] = 0;
    }
  }
}