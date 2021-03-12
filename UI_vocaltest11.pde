

Ring circle;
Note note;
//.processing.core.PShape button_light;
HScrollbar tempobar;


//midi
import processing.opengl.*;
import javax.swing.JFileChooser;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.*;

PitchDetectorFFT PD; // Naive
ToneGenerator TG;
AudioSource AS;
Minim minim;
AudioPlayer song;
AudioSample high, low;
int timesize=2048;
float ave_amplitude=0;
PrintWriter writer;
String[] datatxt={};

int fRate = 0;
int tempo = 60;
int beatsPerBar = 4;
int currentBeat = 1;
int tickSize = (fRate * 60)/tempo;//every tempo refresh number

boolean stopornot=false;//check whether the first audio stops
boolean pauseornot=false;//true-pause,false play
boolean[] breath;
boolean breathornot=false;
float restarttime=0;
float pausetime=0;

float whentobreath=0;
float whentoendbreath=0;

boolean upordown=true;//the mark is up or down
boolean startorgo=false;//whether pressed started, pressed--start--true
boolean startornot=false;//the bar is going or stop, (audio finish and bar starts to move)--true--pause icon/(bar stop)--false--start icon
float[] hand44x;
float[] hand44y;
int handindex=0;

//pitch
int f = 0;
int f2midi=0;
processing.core.PShape pitch_shape,s1;
float changepoint=0;
int lastpitch=0;

 //piece1 row1
float piece1_time[] ={0,2,1,1, 2,2, 1,1,1,1, 4, 1,1,1,1, 2,2, 1,1,1,1, 4, 0, 1,1,1,1, 1,1,2, 1,1,1,1, 4, 2,1,1, 1,1,2, 2,2, 4};
int piece1_notenum[]={21,60,64,65, 67,67, 69,71,72,69, 67, 67,72,71,69, 67,64, 62,64,65,67, 64, 0, 64,62,60,62, 64,65,67, 69,69,71,72, 74, 76,74,72, 71,69,67, 64,67,72 };

int barWidth = 20;
int lastBar = -1;
int page=1;

float []pitchline = new float[10000];
float []rhythm = new float[10000];
float []breathtime = new float[10000];
color []colortime = new color[10000];
String []lyrics = new String[10000];
color scale[]={color(0),color(159,30,63),color(214,100,55),color(277,199,14),color(0,138,98),color(120,193,255),color(0,98,191),color(120,79,194)};
boolean[] scorebool=new boolean[15];//score
int startx=80;
int endx=1040;
int w4w=endx-startx;//width of 4*w

PFont lyrics_font;
PFont tempo_font;

float timepoint=0;
float pre=0;//pre (xline-startx)%(w/2)
float pretime=0;//pre (timepoint-starttime)%(songlong/2)
boolean firsttrigger=true;

float timerate=0;
int starttime=0;
float xline=80;
float prexline=80;
float timerevise=0;
float movespeed=2; 

float delta=0;
int section=0;
float lastxline=0;

int xspacing = 1;   // How far apart should each horizontal location be spaced
int w;              // Width of entire wave
float theta = 0.0;  // Start angle at 0
float amplitude = 200.0;  // Height of wave
float period = 100.0;  // How many pixels before the wave repeats
float dx;  // Value for incrementing X, a function of period and xspacing
float[] yvalues;  // Using an array to store height values for the wave

PImage img;

int leftX, leftY;  // Position of left button
int rightX, rightY;  // Position of right button
int playX, playY; // Position of play button
int startX, startY;  // Position of start1

int buttonSize = 30;   // Diameter of circle
boolean leftOver = false;
boolean playOver = false;
boolean rightOver = false;
PImage left,right,start1,play,pause;

//bezier
BezierCurve curve1,curve2;
PVector[] points1,points2;
PVector[] equidistantPoints1,equidistantPoints2;
float tCurve = 2;
float tStep = 0;
final int POINT_COUNT = 80;
int borderSize = 40;
PVector A,B,C,D,E,F,G,H;
PImage lefthand,righthand;

PGraphics pitchlineBG;
float[] inputpitchX;
float[] inputpitchY;
float[] level;
int arrayindex = 0;
int[] arrayinterval;
float circleport=0;

//notes
Table huafeihua;
int songlong;
int sentence;
int notecount;
float timesum;
EachNote eachnote[];
int endy=50;
int starty;
int inputtime;

int startbreath=0;
int sendtime=0;
boolean[] sendornot;
int breathlong=0;

void setup(){
  size(1060, 800);
  noStroke();
  smooth(2);
  w=(width-100)/8;
  starty=height-endy;
  frameRate=(fRate);
  int w=(width-100)/4;
  circle = new Ring();
  note = new Note();
  circle.start(80+2*w,height/2);
  writer=createWriter("data.txt");
  
  //notes
  huafeihua = loadTable("notes_huafeihua.csv", "header");
  notecount=huafeihua.getRowCount();
  //println(huafeihua.getRowCount() + " total rows in table");
  eachnote = new EachNote[50];
  
  for (TableRow row : huafeihua.rows()) {
    int id,np,nextnp,npage,nrow,senl;
    float nl;
    int glideon,breathon;
    timesum=0;
    
    if(row.getInt("id")!=0) id = row.getInt("id");
    else break;
    nl = row.getFloat("notelong");
    np = row.getInt("notepitch");
    nextnp = row.getInt("notenextpitch");
    glideon = row.getInt("glideornot");
    breathon = row.getInt("nextbreathornot");
    npage = row.getInt("notepage");
    nrow = row.getInt("noterow");
    if(id==1) songlong = row.getInt("songlong");
    senl = row.getInt("sentencelong");
  
    eachnote[id] = new EachNote(id,nl,np,nextnp,glideon,breathon,npage,nrow,senl);
    
  }
  
  for(int j=1;j<=notecount;j++){
    eachnote[j].getTimeSum(timesum);
    timesum+=eachnote[j].notelong;//j    
  }
  
  tempo_font = loadFont("AlBayan-Bold-18.vlw");
  
  //pitch
  minim = new Minim(this);
  minim.debugOn();
  inputpitchX=new float[width*4];
  inputpitchY=new float[width*4];
  breath=new boolean[width*4];
  level = new float[width*4];
  arrayinterval = new int[width];
  sendornot = new boolean[width*4];
  
  AS = new AudioSource(minim);
  // Comment the previous block and uncomment the next line for microphone input
  AS.OpenMicrophone();
  
  song = minim.loadFile(note.midi2word(eachnote[1].notepitch)+".wav");
  high = minim.loadSample("High.wav", 512);
  low = minim.loadSample("Low.wav", 512);

  PD = new PitchDetectorFFT();
  PD.ConfigureFFT(timesize, AS.GetSampleRate());
  PD.SetSampleRate(AS.GetSampleRate());
  AS.SetListener(PD);
  
  //TG = new ToneGenerator (minim, AS.GetSampleRate());
  //audio feedback
  
  w = width+16;
  dx = (TWO_PI / period) * xspacing;
  yvalues = new float[w/xspacing];
  //button_light = loadShape("light_black.svg");
  
  tempobar = new HScrollbar(3*width/4+40, height/2+10, 50, 10, 10);
  
  imageMode(CENTER);
  //button left
  left=loadImage("left.png");
  leftX = width-150;
  leftY = height/2;
  
  //button right
  right=loadImage("right.png");
  rightX = width-50;
  rightY = height/2;
  
  //button play
  play=loadImage("play.png");
  pause=loadImage("pause.png");
  playX = width-100;
  playY = height/2;
  
  //button revise
  /*revise=loadImage("revise.png");
  reviseX = width-100;
  reviseY = height/2;*/
  //the icon of start in the left of the window   
  start1=loadImage("start.png");
  startX = 67;
  startY = height/4;
  
  //bezier hand  in the middle of the screen
  lefthand=loadImage("lefthand.png");
  righthand=loadImage("righthand.png");
  A = new PVector();
  B = new PVector();
  C = new PVector();
  D = new PVector(); 
  
  E = new PVector();
  F = new PVector();  
  G = new PVector();
  H = new PVector(); 
}

void draw(){
  background(51);
  //shape(button_light,width/2-10,20,30,30); 

  section=int(8*(timepoint-restarttime-delta)/songlong);
  int songlongpiece=songlong/32;
  
  if(breathornot==true) breathtime[arrayindex]=1;
  else breathtime[arrayindex]=0;

  if(song.length()-song.position()<=110 && currentBeat==1) {
    startornot=true;
    stopornot=true;//when the start audio stoped
  }
  if(stopornot==false) restarttime=millis();

  timepoint=millis();
  timerate=frameRate;
  if(startornot==true){
  if(startorgo==true && xline==80 & upordown==true && firsttrigger==true) {    
    starttime=millis();
    println("start!");
    clearArrayinterval();
    if(currentBeat==1) {high.trigger();firsttrigger=false;}
  }
   
   xline=(16*w*(timepoint-restarttime-delta)/songlong)%960+80;
   if(xline-prexline>0) movespeed=xline-prexline;
   prexline=xline;
   
   if((xline-startx)%(w/2)<pre){
    
      if(currentBeat % beatsPerBar == 0) {
        high.trigger();}
      else {
        low.trigger();}      
        currentBeat +=1;    
        pre=0;
      }    
   if(startornot==true) pre=(xline-startx)%(w/2);   
   tickSize = (fRate * 60)/tempo; 
  }
  
  //judge if the timepoint is in the upper screen of the downward screen
  //println(upordown," ",(timepoint-restarttime-delta)%(songlong/2)," ",pretime);
  if( (timepoint-restarttime-delta)%(songlong/2)<pretime && startornot==true){
    if(upordown==true) 
      upordown=false;
    else {
      upordown=true;
      arrayindex=0;
    }
    pretime=0;
  }
  
  if(startornot==true) pretime=(timepoint-restarttime-delta)%(songlong/2);
  //draw the breath circle in the middle of the screen
 
  if(startornot==true){     
     if(circle.on==true) circle.grow();
     else if(circle.on==false) circle.contract(movespeed);  

     if(xline>=(startx+7*w/2) && xline<=(startx+31*w/8)) circle.on=true;
     if(xline>=(startx+15*w/2) && xline<=(startx+63*w/8)) circle.on=true;
  }
     
  circle.display();  
  getf();  
  //println("breathornot=",breathornot);
  circleport=circle.diameter/circle.max; 
     
  writer.println(f);
  if(startornot){
    writer.flush();
    writer.close();
  }
  
  //draw rainbow notes and bar lines
  draw_noteline();
  
  //draw pitch lines
    
  inputtime=millis();
  
  int delaymax=11;
  //if(note.breathinorout==true) println("breath in");
  //else println("breath out");
   
  for(int i=0;i<arrayindex-1;i++){                  
     strokeWeight(3);
     stroke(255,255,255,level[i]+40);

     if(inputpitchX[i+1]>inputpitchX[i])
       //line(inputpitchX[i],inputpitchY[i],inputpitchX[i+1],inputpitchY[i+1]);

      for(int j=1;j<=notecount;j++){
       if(inputpitchX[i]>=eachnote[j].x && inputpitchX[i]<=eachnote[j].x+eachnote[j].notelong*w/2 && inputpitchY[i]>=eachnote[j].y && inputpitchY[i]<=eachnote[j].y+eachnote[j].r)
       {                           
           eachnote[j].setNoteColor();
           colortime[i]=eachnote[j].c;
           stroke(colortime[i],level[i]);      
           line(inputpitchX[i],eachnote[j].y,inputpitchX[i],eachnote[j].y+eachnote[j].r);            
       }  
           
       if(eachnote[j].nextbreathornot==1 &&sendtime==0 && xline>=eachnote[j].startbreathx && xline<=eachnote[j].xmax && ((inputpitchY[i]<=height/2 && eachnote[j].y<=height/2)||(inputpitchY[i]>height/2 && eachnote[j].y>height/2))) 
       {              
         sendornot[i]=true;  
         sendtime+=1;
       } 
       else sendornot[i]=false;
             
       if(i>5 && inputpitchX[i]>=eachnote[j].x && inputpitchX[i]<=eachnote[j].xmax ) 
       {           
           colortime[i]=color(10);           
           noStroke();
           fill(colortime[i],200);        
           
           if(breathtime[i]==1  && ((inputpitchY[i]<=height/2 && eachnote[j].y<=height/2)||(inputpitchY[i]>height/2 && eachnote[j].y>height/2))){
             rect(inputpitchX[i]-8,eachnote[j].y,5,eachnote[j].r);}  
       }   
     }    
  }
  
  
//if(arrayindex>5) println(arrayindex,"sendornot=",sendornot[arrayindex]);
//println(sendtime,"sendornot=",sendornot);  
if(sendornot[arrayindex]){
  sendtime=0;
}


  int delaytime;
  delaytime=millis()-inputtime;
  if(delaytime<delaymax) delay(delaymax-delaytime);
  
  
    if(startornot==true)
  {
    inputpitchX[arrayindex]=xline;
    level[arrayindex]=AS.GetLevel()*1600+40;
      if( level[arrayindex]>255) level[arrayindex]=255;
    if(upordown==true) {
      inputpitchY[arrayindex]=height/2-f/2+10;    
      if(arrayindex>=1 && (inputpitchY[arrayindex]<=0||inputpitchY[arrayindex+1]-inputpitchY[arrayindex]>=80)) inputpitchY[arrayindex]=inputpitchY[arrayindex-1];
      if(f<100) inputpitchY[arrayindex]=height/2;      
    }
    
    else {
    inputpitchY[arrayindex]=height-f/2-20;
    if(arrayindex>=1 && (inputpitchY[arrayindex]<=height/2||inputpitchY[arrayindex+1]-inputpitchY[arrayindex]>=80)) inputpitchY[arrayindex]=inputpitchY[arrayindex-1];
    if(f<100) inputpitchY[arrayindex]=height-20;
    }    
  }
  
  strokeWeight(4);
  stroke(240,200);
  if(breathornot==false)line(inputpitchX[arrayindex]-5,inputpitchY[arrayindex],inputpitchX[arrayindex],inputpitchY[arrayindex]);
  
  //println(arrayindex," ",inputpitchX[arrayindex]," ",inputpitchY[arrayindex]);
  //if(arrayindex>2*(width-100)/movespeed) arrayindex-=2*(width-100)/movespeed;
  if(startornot==true) {
    arrayindex+=1;
    
    if(section>=0)arrayinterval[section]+=1;
  }
  if (timepoint%(width)<=5) 
  changepoint=xline;
  
  //draw the time stick
  draw_timestick(xline);
  
  //show the tempo button
  tempobar.update();
  tempobar.display(); 
  
  if(tempobar.over==true && mousePressed==true){
    timerevise=timepoint;
    circle.on=true;
    score=0;
    circle.diameter=50;
    startorgo=true;
    upordown=true;
  }
  
  textFont(tempo_font,15);
  fill(155,200);
  textAlign(CENTER, CENTER);
  text("Tempo", 3*width/4+65, height/2-10); 
  
  //show the left, right and revise buttons
  updateL(leftX,leftY);
  updateR(rightX,rightY);
  updatePl(playX,playY);
 
  if (leftOver) {
     tint(0,200);
  } else {
      tint(155,200);}  
  left.resize(40,40);
  image(left,leftX,leftY);
  tint(155,200);
  
  if (rightOver) {
     tint(0,200);
  } else {
      tint(155,200);} 
  right.resize(40,40);
  image(right,rightX,rightY);
  tint(155,200);
  
  if (playOver) {
     tint(0,200);
  } else {
      tint(155,200);} 
  if(pauseornot==true){
    pause.resize(40,40);
    image(pause,playX,playY);
    tint(155,200);
  }
  else{    
    play.resize(40,40);
    image(play,playX,playY);
    tint(155,200);
  }
  
  
  /*if (reviseOver) {
     tint(0,200);
  } else {
      tint(155,200);} 
  revise.resize(30,30);
  image(revise,reviseX,reviseY);
  tint(155,200);*/
  
  start1.resize(30,30);
  image(start1,startX,startY);
  textFont(tempo_font,15);
  fill(155,200);
  textAlign(CENTER, CENTER);
  text("Start", startX-30, startY); 
  float dex=0.0083;//dex=2*movespeed/w
  //set the two bezier lines
  curve1 = new BezierCurve(A, B, C, D);
  curve2 = new BezierCurve(E, F, G, H);

  lefthand.resize(40,40);
  tint(155,100);
  righthand.resize(40,40);
  tint(155,100);
  int xplus=-10;
  int yplus=40;
  
  int curvexmax=260;
  int curvexmid=200;
  int curvexmin=150;
  
  int curveymax=50;
  int curveymin=-100;

  A.set( width/2-curvexmax+xplus, height/2+yplus);//
  B.set( width/2-curvexmid+xplus, height/2+curveymax+yplus);//
  C.set( width/2-curvexmid+xplus, height/2+curveymin+yplus);//
  D.set( width/2-curvexmin+xplus, height/2+yplus);//
  E.set( width/2+curvexmax+xplus, height/2+yplus);//
  F.set( width/2+curvexmid+xplus, height/2+curveymax+yplus);//
  G.set( width/2+curvexmid+xplus, height/2+curveymin+yplus);//
  H.set( width/2+curvexmin+xplus, height/2+yplus);//
    
  // draw the two curves and show the two hands
  strokeWeight(2);
  //tStep=tempobar.getPos();
  
   
  pushMatrix();
  translate(borderSize, -50);    
  
  circleStyle();
  PVector pos1 = curve1.pointAtFraction(tCurve);
  PVector pos2 = curve2.pointAtFraction(tCurve);
  float pos1y=0;
  float pos2y=0;
  float deltax=0;
  float deltay=0;
  
  
  tCurve -= tStep;
  if(tCurve<0) tCurve+=2;
  
  if(startornot==true){
    tStep=2*movespeed/w;//2*movespeed/w=1/30~~0.03333
  }
  else{
    tStep=0;
  }
  
  if(tCurve>=0.0 && tCurve<1.0 && pos1.x<370){
    
    image(lefthand,pos1.x+80*(2-circleport),pos1.y);
    pos1y=pos1.y-deltax;
    image(righthand,pos2.x-80*(2-circleport),pos2.y);
    pos2y=pos2.y+deltay;
  }
  if(tCurve>=1.0 && tCurve<2.0){
     pos1=curve1.pointAtFraction(2-tCurve);
     pos2=curve2.pointAtFraction(2-tCurve);
     
     image(lefthand,pos1.x+80*(2-circleport),height+2*yplus-pos1.y);
     pos1y=height+2*yplus-pos1.y;
     image(righthand,pos2.x-80*(2-circleport),height+2*yplus-pos2.y);
     pos2y=height+2*yplus-pos2.y;
  }
  
  popMatrix();
}


void getf(){
  f = (int)PD.GetFrequency();//
  println();
  f2midi=note.fre2midi(f);
  //TG.SetFrequency(f);
  //TG.SetLevel(level * 10.0);
  //avg_level = level;
  pitchline[int(millis()/100%10)]=int(f);
  //println(f);
}
  float score=0;
  float all=0;
  int ix;
   
void draw_noteline(){
  int w=(width-100)/8;
  ix=1;
  int endy=50;
  int starty=height-endy;  
  int roll1[]={10,10,9,7, 10,9,7, 10,10,12,7, 6,5,3};
  
//upper BG lines
  stroke(200,10);
  strokeWeight(2);    
  for(int i=1;i<=15; i+=1){
    line(startx+w*i/2,0,startx+w*i/2,height/2-30);
  }
  
  
  for(int i=0;i<=8;i+=2){
    stroke(200,50);
    strokeWeight(4);
    if(i==0||i==8)line(startx+i*w,0,startx+i*w,height/2-30);
    if(i==4) line(startx+i*w,0,startx+i*w,height/2-165);
    if(i==2||i==6){
     stroke(200,15);
     strokeWeight(4);
     line(startx+i*w,0,startx+i*w,height/2-30);
    }   
  }

  
//lower BG lines  
  stroke(200,10);
  strokeWeight(2);
  for(float i=1;i<=15; i+=1){
    line(startx+w*i/2,height/2+30,startx+w*i/2,height);
  }
 
  for(int i=0;i<=8;i+=2){
    stroke(200,50);
    strokeWeight(4);
    if(i==0||i==8)line(startx+i*w,height/2+30,startx+i*w,height);
    if(i==4) line(startx+i*w,height/2+178,startx+i*w,height);
    if(i==2||i==6){
     stroke(200,15);
     strokeWeight(4);
     line(startx+i*w,height/2+30,startx+i*w,height);
    }   
  }

  boolean noteposition=true;

if(width-xline<=10 && upordown==false && page<=2) {
  page=2;
}

for(int i=1;i<=notecount;i++){ 
  eachnote[i].setNoteColor();
  eachnote[i].drawEachNote();//i
}

}

int re=0;
void draw_timestick(float a) {
  noStroke();
  fill(255);
  // A simple way to draw the wave with an ellipse at each location
    stroke(115);
    strokeWeight(3);

 if(upordown==true) line(a, height/4+150,a-xspacing, height/4-150);  
 else if(upordown==false) line(a, height*3/4+150,a-xspacing, height*3/4-150);
}

int i=255;
void emoji(){
  img = loadImage("excellent.png");
  imageMode(CENTER);
    
  tint(255,i);
  image(img, 80+(width-100)/2, height/2);
  
  if(i>0)i=i-1;
  else i=0;
}

void updateL(int x,int y) {
  if ( overButton(x, y, buttonSize) ) {
    leftOver = true;
  } else {
    leftOver = false;
  }
}
void updateR(int x,int y) {
  if ( overButton(x, y, buttonSize) ) {
    rightOver = true;
  } else {
    rightOver = false;
  }
}

void updatePl(int x,int y) {
  if ( overButton(x, y, buttonSize) ) {
    playOver = true;
  } else {
    playOver = false;
  }
} 

float songframe,songstart,songstop;
void mouseDragged(){
  if(leftOver){
    delta+=(timepoint-restarttime-delta);
    section=0;
    pretime=(timepoint-restarttime-delta)%(songlong/2);
    currentBeat=0;
    arrayindex=0;
    startorgo=true;
    firsttrigger=true;
    upordown=true;
    clearArrayinterval();
  }

}

void mousePressed() {
  
  if(leftOver){
    
    delta+=(timepoint-restarttime-delta)-section*songlong/8;
    pretime=(timepoint-restarttime-delta)%(songlong/2);
    currentBeat=section*4;
    arrayindex-=arrayinterval[section];
    clearArrayinterval();
    
  }
  
  if(rightOver){
    delta-=(section+1)*songlong/8-(timepoint-restarttime-delta);
    pre=(xline-startx)%(w/2);
    currentBeat=section*4;
    clearArrayinterval();

  }

  if(playOver){  
   if(pauseornot==false){//from play to pause
      pauseornot=true;
      if(stopornot==true) delta+=millis();
      }
   else {//from pause to play
     pauseornot=false;//icon show pause or play
     pausetime=millis();
     delta-=pausetime;
   }

   
   startorgo=true;
   if(song.length()-song.position()>110)
   {
     if (song.isPlaying()) {
      song.pause();
      startornot=false;}     
     else {
     songstart=timepoint;
     song.play();}
   }
   else{songstop=timepoint;
     if(startornot==false){
       startornot=true;       
     }else{startornot=false;}     
   }
  }
}

void stop() {
  if (song != null) song.close();
  minim.stop();
  super.stop();
}

boolean overButton(int x, int y, int diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

void circleStyle() {
  noStroke();
  fill(0);
}

void clearArrayinterval(){
  for(int i=section;i<=8;i++){
    arrayinterval[i]=0;
  }

}
