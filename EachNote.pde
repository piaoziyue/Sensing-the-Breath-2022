class EachNote{
  int noteid;
  float notelong;
  int notepitch;
  int notenextpitch;
  int glideornot; //how to connect with next note, glide or directly
  int nextbreathornot; //if to breath after the note 
  int notepage;
  int noterow;
  int sentencelong;
  float startbreathx=0;
 
  
  float x;
  float xmax;
  float y;
  float nexty;
  PFont doremi;
  int r=40;//pitch's fanwei
  float timesumm;
  color scale[]={color(0),color(159,30,63),color(159,30,63),color(214,100,55),color(214,100,55),color(277,199,14),color(0,138,98),color(0,138,98),color(120,193,255),color(120,193,255),color(24,127,224),color(24,127,224),color(120,79,194)};
  String tonic[]={" ","do","#do","ra","#ra","mi","fa","#fa","so","#so","la","#la","ti"};  
  int name;
  color c=color(0);
  
  EachNote(int id,float nl, int np, int nextnp, int glideon, int breathon, int npage, int nrow, int senl){
    noteid=id;
    notelong = nl;
    notepitch = np;
    notenextpitch = nextnp;
    glideornot = glideon;
    nextbreathornot = breathon;
    notepage = npage;//means whether the notepage has changed
    noterow = nrow;
    sentencelong = senl;
  } 
  void setNoteColor(){
    name=midi2name(notepitch);
    c=scale[name];
  }
  
  void getTimeSum(float ts){
    timesumm=ts;
    
    if(timesumm>=16) timesumm-=16;
    println(ts," ",timesumm);
    x=startx+timesumm*w/2;
    xmax=x+notelong*w/2;
    if(noteid==38)println("timesum=",timesumm);
    if(noterow==1){      
      y=starty/2-midi2fre(notepitch)/2+20;
      nexty=starty/2-midi2fre(notenextpitch)/2+20;
    }
    
    else if(noterow==2){
      y=starty-midi2fre(notepitch)/2+20;
      nexty=starty-midi2fre(notenextpitch)/2+20;
    }

  }

  
  void drawEachNote(){

    color gray=color(200,100);
    stroke(c,100);
    int stroke=3;
    float prone=abs(nexty-y)/2;
    strokeWeight(stroke);
    noFill();
    
    if(nextbreathornot==-1){

      stroke(c,100);
      line(x+stroke,y,x+stroke,y+r); 
      
      if(y!=nexty){
      stroke(c,100);
      line(x+stroke,y,x+notelong*w/2-prone/2,y);
      line(x+stroke,y+r,x+notelong*w/2-prone/2,y+r);
      
      stroke(gray,50);
      line(x+notelong*w/2-prone/2+stroke,y,x+notelong*w/2,nexty);
      line(x+notelong*w/2-prone/2+stroke,y+r,x+notelong*w/2,nexty+r);}
      else{
        stroke(c,100);
      line(x+stroke,y,x+notelong*w/2,y);
      line(x+stroke,y+r,x+notelong*w/2,y+r);
      }
    }
    
    if(nextbreathornot==0){
      
      if(y!=nexty){

      stroke(c,100);
      line(x+stroke,y,x+notelong*w/2-prone/2,y);
      line(x+stroke,y+r,x+notelong*w/2-prone/2,y+r);
      
      stroke(gray,50);
      line(x+notelong*w/2-prone/2+stroke,y,x+notelong*w/2,nexty);
      line(x+notelong*w/2-prone/2+stroke,y+r,x+notelong*w/2,nexty+r);}
      else{
        stroke(c,100);
      line(x+stroke,y,x+notelong*w/2,y);
      line(x+stroke,y+r,x+notelong*w/2,y+r);
      }
    }
      
    if(nextbreathornot==1){ 
      stroke(c,100);
      line(x+stroke,y,x+notelong*w/2,y);      
      line(x+stroke,y+r,x+notelong*w/2,y+r);
      line(x+notelong*w/2,y,x+notelong*w/2,y+r);
      
      stroke(gray,50);
      line(x+stroke+notelong*w/2,y,x+notelong*w/2+stroke,y+r);
      
      
      fill(gray);
      noStroke();
      rect(x+stroke+notelong*w/2-(w/8+w/64*sentencelong),y+stroke-1,w/8+w/64*sentencelong,r-stroke);
      startbreathx=x+stroke+notelong*w/2-(w/8+w/64*sentencelong);
      
      stroke(0,120);
      strokeWeight(2);
      line((x+stroke+notelong*w/2-(w/8+w/64*sentencelong))+5,y+10,(x+stroke+notelong*w/2-(w/8+w/64*sentencelong)/2),y+r-10);
      line((x+stroke+notelong*w/2-(w/8+w/64*sentencelong)/2),y+r-10,x+stroke+notelong*w/2-5,y+10);
    }
    
    if(nextbreathornot==-2){
      stroke(c,100);
      line(x+stroke,y,x+notelong*w/2,y);
      line(x+stroke,y+r,x+notelong*w/2,y+r);
      line(x+notelong*w/2,y,x+notelong*w/2,y+r); 
    }
    
    
    doremi = loadFont("AlBayan-Bold-18.vlw");
    textFont(doremi,r*2/5);
    fill(c,100);
    textAlign(CENTER, CENTER);
    if(nextbreathornot!=1) text(tonic[name], (x+2*stroke+x+notelong*w/2-prone/2)/2, y+r/2); 
    else text(tonic[name], (x+2*stroke+x+notelong*w/2-prone/2)/2-notelong*w/8, y+r/2); 
    
    //if(xline>=x && xline<=xmax)println("x=",x,"xmax=",xmax,"startbreathx=",startbreathx);
}
  
  int midi2name(int M)
{
  int a=M%12+1;
  return a;//a is the rank in 12
}

String midi2word(int M)
{
   int m=M;
   int a1=-1;
   int a2;
   String word;
   for(int i=0;i<10;i++)
   {
     if(m-12>=0){m=m-12;a1+=1;}
     else i=11;
   }
   a2=m%12;
   if(a2==0) word="C"+str(a1);
   else if(a2==1) word="#C"+str(a1);
   else if(a2==2) word="D"+str(a1);
   else if(a2==3) word="#D"+str(a1);
   else if(a2==4) word="E"+str(a1);
   else if(a2==5) word="F"+str(a1);
   else if(a2==6) word="#F"+str(a1);
   else if(a2==7) word="G"+str(a1);
   else if(a2==8) word="#G"+str(a1);
   else if(a2==9) word="A"+str(a1);
   else if(a2==10) word="#A"+str(a1);
   else if(a2==11) word="B"+str(a1);
   else word="None up till now";

   return word;
}

float midi2fre(int M)
{
  float a=440*pow(2,(M-69)*0.083333);
  return a;
}

int fre2midi(float f)
{
  float a=log(f/440)/log(2);
  return int(69+12*a);
}

}
