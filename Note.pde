public class Note{
   //[0] kongpai
 // int notearray[]={0,86,96,107,118,129,150,161,172,193,226,247,269,290,322,387};
  color scale[]={color(0),color(159,30,63),color(159,30,63),color(214,100,55),color(214,100,55),color(277,199,14),color(0,138,98),color(0,138,98),color(120,193,255),color(120,193,255),color(0,98,191),color(0,98,191),color(120,79,194)};
  
  String tonic[]={" ","do","#do","ra","#ra","mi","fa","#fa","so","#so","la","#la","ti"};  
  int r=30;  
  PFont doremi;
  boolean breathinorout=true;//the first note of a sentence is breath in, the last are out
  
  public void drawNotecircle(int m,float x,float y,float time,int alpha){
    
    int name=midi2name(m);
    color c=scale[name];
    
    stroke(c,alpha);
    strokeWeight(2);
    noFill();
    
    if(x+w/2*time==startx+4*w || x+w/2*time==startx+8*w)
      breathinorout=true;
      else breathinorout=false;
      
    if(breathinorout==true) {
      line(x,y,x+w/2*time-w/2,y);
      line(x,y+r,x+w/2*time-w/2,y+r);
    }else{
      line(x,y,x+w/2*time,y);
      line(x,y+r,x+w/2*time,y+r);}
    
    doremi = loadFont("AlBayan-Bold-18.vlw");
    textFont(doremi,r/2);
    fill(c,alpha);
    textAlign(CENTER, CENTER);
    text(tonic[name], x+r, y+r/2); 
    
    fill(200*circleport,100);
    noStroke();
    if(breathinorout==true) 
      rect(x+w/2*time-w/2+1,y-1,w/2-2,r+2);


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
