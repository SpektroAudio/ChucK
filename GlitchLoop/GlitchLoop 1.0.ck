// GL1TCH L00P
// Written by Icaro Ferre / Spektro Audio
// http://spektroaudio.com/

// Prepare buffers

SndBuf Hihat => dac;
me.dir() + "/audio/hihat_01.wav" => Hihat.read; //Read Sample
Hihat.samples() => Hihat.pos; //Set playhead to end
SndBuf Kick => dac;
me.dir() + "/audio/kick_01.wav" => Kick.read; //Read Sample
Kick.samples() => Kick.pos; //Set playhead to end
SndBuf Snare => dac;
me.dir() + "/audio/snare_01.wav" => Snare.read; //Read Sample
Snare.samples() => Snare.pos; //Set playhead to end
ModalBar Perc => dac;



//Set BPM
140  => int bpm;
//BPM to MS
60000/bpm => float beattime; 

Math.random2(0,1) => int maybeHit; // this variable can be used to add variation to the patterns

//Kick Pattern
[1,0,0,0,0,0,0,0,1,0,maybeHit,1,0,0,0,0] @=> int kickPattrn[];

//Snare Pattern
[0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0] @=> int snarePattrn[];

//Perc Pattern
[1,maybeHit,0,1,0,0,1,0,0,1,0,0,1,0,maybeHit,1] @=> int percPattrn[];
[60, 63, 65, 67, 68, 70] @=> int percNotes[];

//ModalBar Initial Parameters
8 => Perc.preset;
1.5 => Perc.gain;
0.9 => Perc.strikePosition;


//Functions
fun void hihatsec (int repmax) {
    Math.random2 (1, repmax) => int repeats;    
    beattime/repeats => float repeattime;
    2. / repmax => float rategrain;
    (1-rategrain) + (rategrain * repeats) => float rate;
    repeat (repeats) {
        Math.random2(0,1) => int mode;
        if (mode==0) {
            Math.random2f(0.4, 0.7) => Hihat.gain;
            rate  + (Math.random2(1,9)*rategrain) => Hihat.rate;
            0 => Hihat.pos;
        }
        else if (mode==1)        { 
            -1  => Hihat.rate;
            Hihat.samples()/4 => Hihat.pos;
        }
        repeattime::ms => now;
    }
}

fun void hihats() {
    while (true) {
        hihatsec (8); //set number of max repetitions for each section
        hihatsec (2);
        hihatsec (4);
        hihatsec (2);
    }
}

fun void Kicks() {
    0 => int counter;
    beattime/2 => float timer;
    while (true) {    
        counter % 16 => int beat; 
        if (beat==0) {
            Math.random2(0,1) => int maybeHit;
        } 
        if (kickPattrn[beat]==1) {
            Math.random2f(0.9, 1.1) => Kick.rate;
            0 => Kick.pos; //Triggers the Kick
        }
        if (snarePattrn[beat]==1) {
            0 => Snare.pos; //Triggers the Snare
        }
        if (percPattrn[beat]==1) {
            Std.mtof(percNotes[Math.random2(0, (percNotes.cap()-1))]) => Perc.freq; //Sets the Perc freq  by randomly selecting one of the notes in the percNotes array
            1 => Perc.strike; //Trigger the Perc
        }
        counter++;
        timer::ms => now;
        
    }    
}


// MAIN PROGRAM
spork ~hihats(); //Starts generating Hihat patterns
beattime*4::ms => now;
spork ~Kicks(); //Starts the Kick, Snare and Perc patterns.

while (true) 1::second => now; // Infinite Loop
