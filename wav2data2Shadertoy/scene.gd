extends Control

#
#What is this:
#  this is very junk tool to convert audio to data for shadertoy mainSound audio shaders

#Usage:
#  - convert VERY SHORT 0.1 sec audio like notes for MIDI 
#  - first - convert your audio to 16 bit stereo 11025 hz
#  ffmpeg command:
#    ffmpeg -i test.wav -ar 11025 -c:a pcm_s16le midi_note_test.wav

# you suppose "visually" analyze texture-data
# and make short compression for it - because data not large it fast to do

#How it work:
#  this is functional example - just run it:

#  - midi_note_test.wav - is audio recording of single midi note
#    use this file for your notes - replace this 
#    16 bit stereo 11025 hz

#  - shadertoy_audio_test.wav - this is one second of mainSound shadertoy default func audio 
#    16 bit stereo 11025 hz


#- if you have idea to use texture to compress long audio 
#- using texure as input and ML - siren or basic gausian splats
#- ... it wont work for 0.1 sec audio - quality will be absolute garbage
#- ... and result will be same/larger than manual compression
#- especially for midi notes because there huge 0 to 255 jumps per pixel
#- and siren/gradients will smooth it so it destroy audio quality
#- for long - seconds long - yes it will work with garbage audio quality - 
#- look related links for ML context:
#<LINK>


#Why Godot and not just C:
#  because wav has billion "extensions" inclute compression
  
#  as you see - this script support only 16 bit stereo 11025 hz
#  but Godot handle "all audio loading" and you get just nice array of audio data
  
#  too much for simple one day project to do in C
  
#  you can try - this is basic C code to generate wav file from shadertoy mainSound
#  <LINK>
#  make new C code - to load generated file with this format in C - using above as test/template
#  and just print to text file converted data similar way as here...



func _ready():
  pass







