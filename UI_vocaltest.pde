
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
int page=0;

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

Button pretrain, exercise, report;
Button p1,e1,r1;
import processing.serial.*;
Serial myPort;  // Create object from Serial class
String myString;
float myVal;

float[] abNorBreath;
float[] wlNorBreath;
float[] wrNorBreath;
float[] llNorBreath;
float[] lrNorBreath;
float[] waNorBreath;
float[] luNorBreath;

int[] abMaxBreath;
int[] wlMaxBreath;
int[] wrMaxBreath;
int[] llMaxBreath;
int[] lrMaxBreath;

int[] abSingBreath;
int[] wlSingBreath;
int[] wrSingBreath;
int[] llSingBreath;
int[] lrSingBreath;

int indexNorPage=0;
int indexMaxPage=0;
int indexSingPage=0;

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
  
  //port
  String portName = Serial.list()[10];
  myPort = new Serial(this, portName, 9600); 
  myPort.clear();  // function from serial library that throws out the first reading, in case we started reading in the middle of a string from Arduino
  myString = myPort.readStringUntil(10);
  
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
  //lyrics_font = loadFont("FuturaLT-Light-48.vlw");
  
  //pitch
  minim = new Minim(this);
  minim.debugOn();
  inputpitchX=new float[width*4];
  inputpitchY=new float[width*4];
  breath=new boolean[width*4];
  level = new float[width*4];
  arrayinterval = new int[width];
  sendornot = new boolean[width*4];

  abNorBreath = new float[width*2];
  wlNorBreath = new float[width*2];
  wrNorBreath = new float[width*2];
  llNorBreath = new float[width*2];
  lrNorBreath = new float[width*2];
  waNorBreath = new float[width*2];
  luNorBreath = new float[width*2];

  abMaxBreath = new int[width*2];
  wlMaxBreath = new int[width*2];
  wrMaxBreath = new int[width*2];
  llMaxBreath = new int[width*2];
  lrMaxBreath = new int[width*2];

  abSingBreath = new int[width*4];
  wlSingBreath = new int[width*4];
  wrSingBreath = new int[width*4];
  llSingBreath = new int[width*4];
  lrSingBreath = new int[width*4];
  
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

  pretrain= new Button("Normal", width/4, 2*height/3,"r");
  exercise = new Button("Maxmium", width/2, 2*height/3,"r");
  report = new Button("Singing", 3*width/4, 2*height/3,"r");
  
  p1= new Button("P", 100, height/2,"c");
  e1 = new Button("E", 150, height/2,"c");
  r1 = new Button("R", 200, height/2,"c");
}

void draw(){
  background(51);
  //shape(button_light,width/2-10,20,30,30); 
  if(page==0) {
    pretrain.display();
    exercise.display();
    report.display();
    textAlign(CENTER);
    lyrics_font = createFont("Arial Bold", 18);
    textFont(lyrics_font);textSize(50);
    fill(255, 255, 255,160);
    text("SING ALONG WITH ME", width/2, height/2-50); 
  }  
  else{
    p1.display();
    e1.display();
    r1.display();
  }
  
  pageSelector();  
  while (myPort.available () > 0) { //as long as there is data coming from serial port, read it and store it 
    myString = myPort.readStringUntil(10);
  }
  processInputData(myPort); 
}

void pageSelector()
{
  if (page==0) beginpage();
  else if (page==1) norpage();
  else if (page==2) maxpage();
  else if (page==3) singingpage();
}

void getf(){
  f = (int)PD.GetFrequency();//
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
}

void drawNoteScore(){
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
  
  if(pretrain.isInside()) {
    page=1;
    pageSelector();
  }
  
  if(exercise.isInside()) {
    page=2;
    pageSelector();
  }
  
  if(report.isInside()) {
    page=3;
    pageSelector();
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
int serialCount = 0;     // A count of how many bytes we receive

//Returns true when valid data is available
void processInputData(Serial myP) {

 if (myString != null) {  //if the string is not empty, print the following

    /*  Note: the split function used below is not necessary if sending only a single variable. However, it is useful for parsing (separating) messages when
     reading from multiple inputs in Arduino.
     */
    String[] a = split(myString, ' ');  // a new array (called 'a') that stores values into separate cells (separated by commas specified in your Arduino program)
    //println(a[0]," ",a[1]," ",a[2]," ",a[3]," ",a[4]);    
 }
}
