/* R2D2 Pitch Processing
 * 
 * Audio analysis for pitch extraction 
 * 
 * Looks for FFT bin with highest energy. Quite naive...
 *
 * L. Anton-Canalis (info@luisanton.es) 
 */

class PitchDetectorFFT implements AudioListener { 
  float sample_rate = 0;
  float last_period = 0;

  float current_frequency = 0;
  long t;
  boolean breathon=false;
  
  FFT fft;
  
  final float F0min = 50;
  final float F0max = 400;
   
   
  PitchDetectorFFT () {
  }
  
  void ConfigureFFT (int bufferSize, float s) {
    
       fft = new FFT(bufferSize, s); 
       fft.window(FFT.HAMMING);
       SetSampleRate(s);
       
  }
  
  synchronized void StoreFrequency(float f) {
    current_frequency = f;
  }
  
  synchronized float GetFrequency() {
    return current_frequency;
  }
  
  void SetSampleRate(float s) {
     sample_rate = s;
     t = 0;
  }
  
  synchronized void samples(float[] samp) {
    float before=millis();
    FFT(samp);
  }
  
  synchronized void samples(float[] sampL, float[] sampR) {
    FFT(sampL);
  }
  
  synchronized long GetTime() {
    return t;
  }
  
  synchronized boolean getBreath() {
    return breathon;
  }
 
  
  void FFT (float []audio) {
    t++;
    float highest = 0;
    
    int highest_bin = 0;
    fft.forward(audio);
    int max_bin =  fft.freqToIndex(10000.0f);
    int[] binWindow = {12,13,14,15,16,17,18,19,20,21,22,23};
    float[] scaleAmplitude = {0,0,0,0,0,0,0,0,0,0,0,0};
    float[] LRMatrix = {0.55124856, -0.40552919, -0.34893279, -0.06809437, -0.10580507, -0.41337233, -0.41829723, -0.3208804, -0.1407501, 0.00948004, -0.01170007, 0.12686666, -0.1003831};
    float test_value=0;
    //calculate f0
    for (int n = 0; n < max_bin; n++) {       
       if (fft.getBand(n) > highest) {
         highest = fft.getBand(n);
         highest_bin = n;  
       }
    }  
    float mean=0;
    float var=0;
    
    //calculate chroma
    for(int i=0;i<12;i++){  
      if(i==0) ave_amplitude=0;
      for(int j=1;j<=5;j++){
        int nbin=binWindow[i]*j;
        scaleAmplitude[i]+=fft.getBand(nbin); 
      } 
      mean+=scaleAmplitude[i];      
      ave_amplitude+=scaleAmplitude[i]*scaleAmplitude[i];
    }
    mean/=12;
    ave_amplitude=pow(ave_amplitude,0.5);
    
    //nomal var
    for(int i=0;i<12;i++){
      var+=(scaleAmplitude[i]-mean)*(scaleAmplitude[i]-mean);
    }
    var/=12;
    var=pow(var,1/2);
    float volume=AS.GetLevel()*100;
    
    for(int i=0;i<12;i++){
      
      scaleAmplitude[i]=(scaleAmplitude[i]-mean)/var;
      test_value+=LRMatrix[i]*scaleAmplitude[i];
    }
    //sigmoid    
    test_value=1.0/(1+1/exp(test_value));
     
    if(test_value<0.4 ||test_value>=0.8) 
      breath[arrayindex]=false;
    else {
      breath[arrayindex]=true;
      //println("volume=",volume);
      }
    float breathnum=0;
    if(arrayindex>5){
      for(int i=arrayindex-5;i<arrayindex;i++){
        if(breath[i]==true) breathnum++;
      }
     // println("ave_amplitude=",ave_amplitude," breath=",breathnum/5.0);
      if(breathnum/5.0>0.36 && (f <150||f>1000) && ave_amplitude>5.5) {
        breathornot=true;
        for(int i=arrayindex-5;i<arrayindex;i++){
          breath[i]=true;
        }
      }
      else breathornot=false;
    }
    //println(breathornot);
    float freq = fft.indexToFreq(highest_bin); //highest_bin * sample_rate / float(audio.length);  
    StoreFrequency(freq);
        
  }
};
