extends VBoxContainer


#Usage:
#  - convert VERY SHORT 0.1 sec audio like notes for MIDI 
#  - first - convert your audio to 16 bit stereo 11025 hz
#  ffmpeg command:
#    ffmpeg -i test.wav -ar 11025 -c:a pcm_s16le midi_note_test.wav



# IMPLEMENTATION
# NOTICE coment - search
# # NOT mainSound
# for some reason some wav audio need to be flipped with
# sample = sign(sample)*(1.0-abs(sample)) 
# I have no idea why
# if you have horrible noise playing texture - comment this line

###############

# unused here - but can be used to analyze real time audio in Godot
onready var spectrum=AudioServer.get_bus_effect_instance(AudioServer.get_bus_index("Master"),0)

var audio_player: AudioStreamPlayer
var audio_stream: AudioStreamGenerator
var playback: AudioStreamGeneratorPlayback
var play_time: float = 0.0

var is_play_texture = false
var is_play_mainSound = false


const rec_time_texture = 0.1

# this is image width = texture_sample_rate/fps_textur
const texture_width_multiplier = 10.0


## SAMPLE RATE MUST BE SAME AS IN WAV FILE

# this script support only 11025
const texture_sample_rate = 11025.0
#const texture_sample_rate = 16000.0
#const texture_sample_rate = 22050.0
#const texture_sample_rate = 32000.0
#const texture_sample_rate = 44100.0

###############


var push_buffer_idx:int = -1
var push_buffer_tar = []



# mainSound
###############

# equal to shadertoy code
#
#vec2 mainSound( int samp, float time )
#{
#    // A 440 Hz wave that attenuates quickly overt time
#    return vec2( sin(6.2831*440.0*fract(time))*exp(-3.0*fract(time)) );
#}


func fract(a):
  var ta = abs(a)
  return sign(a)*(ta-floor(ta))

func mainSound(time):
  var value = sin(PI*2.0*440.0*fract(time))*exp(-3.0*fract(time))
  return clamp(value,-1.0,1.0)
  
###############




# texture
###############

func refresh_texture(texture ,img_width, img_heigh):
  $tabs/texture.texture = texture
  var tinfo = ""
  tinfo += "img_width " + str(img_width)
  tinfo += " img_heigh " + str(img_heigh)
  $wav_texture_code/texture/textureinfo/textureinfo.text=tinfo

func init_texture():
  var img_width:int = ceil(texture_sample_rate/texture_width_multiplier)
  var rec_time = rec_time_texture
  var img_heigh:int = ceil(rec_time*texture_width_multiplier)

  var byte_array: PoolByteArray = []
  for a in range(img_heigh):
    for b in range(img_width):
      byte_array.push_back(int((b/float(img_width))*255.0))
  
  var img = Image.new()
  img.create_from_data(img_width, img_heigh, false, Image.FORMAT_R8, byte_array)
  var texture = ImageTexture.new()
  texture.create_from_image(img, 0)
  refresh_texture(texture ,img_width, img_heigh)


func gen_audio_tex():
  var img_width:int = ceil(texture_sample_rate/texture_width_multiplier)
  var img_heigh:int = ceil(rec_time_texture*texture_width_multiplier)
  
  var frames_to_generate = img_width*img_heigh
  var time = 0.0
  var byte_array: PoolByteArray = []

  for i in range(frames_to_generate):
    var sample = mainSound(time)
    sample=clamp((sample+1.0)/2.0,0.0,1.0)
    byte_array.push_back(int(sample*255))
    time += 1.0 / texture_sample_rate
  var img = Image.new()
  img.create_from_data(img_width, img_heigh, false, Image.FORMAT_R8, byte_array)
  var texture = ImageTexture.new()
  texture.create_from_image(img, 0)
  refresh_texture(texture ,img_width, img_heigh)
  
# audio_data 16 bit to 8 bit
func gen_audio_byte_arr(audio_data:PoolByteArray):
  var img_width:int = ceil(texture_sample_rate/texture_width_multiplier)
  var img_heigh:int = ceil(rec_time_texture*texture_width_multiplier)
  
  var frames_to_generate = img_width*img_heigh
  var time = 0.0
  var byte_array: PoolByteArray = []
      
  for i in range(frames_to_generate):
    var tval = 0
    if(i*4+0<audio_data.size() and i*4+1<audio_data.size()):
      tval = int((((audio_data[i*4+1]<<8)+(audio_data[i*4+0]))/float(0xffff))*0xff)
    byte_array.push_back(tval)

    time += 1.0 / texture_sample_rate
  return byte_array

func gen_audio_tex_from_samples(soundsamples):
  var img_width:int = ceil(texture_sample_rate/texture_width_multiplier)
  var img_heigh:int = ceil(rec_time_texture*texture_width_multiplier)
  var frames_to_generate = img_width*img_heigh
  var time = 0.0
  var byte_array: PoolByteArray = []

  for i in range(frames_to_generate):
    byte_array.push_back(soundsamples[i])
    time += 1.0 / texture_sample_rate
  var img = Image.new()
  img.create_from_data(img_width, img_heigh, false, Image.FORMAT_R8, byte_array)
  var texture = ImageTexture.new()
  texture.create_from_image(img, 0)
  refresh_texture(texture ,img_width, img_heigh)
  
  #$main/TabContainer/texture.texture.get_data().save_png("sound.png")

###############






# init
###############

func _ready():
  $mainSound/HBoxContainer/mss.text = str(rec_time_texture)
  init_texture()
  
  audio_stream = AudioStreamGenerator.new()
  audio_stream.mix_rate = texture_sample_rate
  
  audio_player = AudioStreamPlayer.new()
  audio_player.stream = audio_stream
  add_child(audio_player)

  playback = audio_player.get_stream_playback()
  audio_player.play()
  

###############




###############

func _process(delta):
  if is_play_texture:
    var img:PoolByteArray = $tabs/texture.texture.get_data().get_data()
    var frames_to_generate = int(delta * texture_sample_rate)
    for i in range(frames_to_generate):
      #mainSound
      var sample = (img[int(play_time*texture_sample_rate)])/255.0
      sample = (clamp(sample,0.0,1.0))*2.0-1.0 
      
      # NOT mainSound
      sample = sign(sample)*(1.0-abs(sample)) 
      
      playback.push_frame(Vector2((sample), (sample)))  # Stereo (L, R)
      play_time += 1.0 / texture_sample_rate
      
      if play_time>=rec_time_texture:
        break

    
  if is_play_mainSound:
    var frames_to_generate = int(delta * texture_sample_rate)

    for i in range(frames_to_generate):
      var sample = mainSound(play_time)
      playback.push_frame(Vector2(sample, sample))
      play_time += 1.0 / texture_sample_rate
      
      if play_time>=rec_time_texture:
        break
  if play_time>=rec_time_texture:
    is_play_texture=false
    is_play_mainSound=false
    play_time = 0.0
  
  
  if(push_buffer_idx>=0):
    if(push_buffer_idx<push_buffer_tar.size()):
      var frames_to_generate = int(delta * texture_sample_rate)
      if(playback.can_push_buffer(frames_to_generate)):
        var tbuf = PoolVector2Array(push_buffer_tar.slice(push_buffer_idx,push_buffer_idx+frames_to_generate))
        playback.push_buffer(tbuf)
        push_buffer_idx+=tbuf.size()
    else:
      push_buffer_idx = -1

###############









func _on_playMS_pressed():
  is_play_mainSound = true
  play_time=0.0


func _on_platMS_buff_pressed():
  var frames_to_generate = int(rec_time_texture * texture_sample_rate)
  push_buffer_tar.clear()
  #playback.clear_buffer()
  var time = 0.0
  for i in range(frames_to_generate):
    #mainSound
    var sample = mainSound(time)
    sample = clamp((sample+1.0)/2.0,0.0,1.0)
    sample = clamp(sample,0.0,1.0)*2.0-1.0 

    # NOT mainSound
    #sample = sign(sample)*(1.0-abs(sample)) 
    
    push_buffer_tar.push_back(Vector2((sample), (sample)))
    time += 1.0 / texture_sample_rate
    
    if time>=rec_time_texture:
      break
  push_buffer_idx = -1
  var tbuf = PoolVector2Array(push_buffer_tar)
  if(playback.can_push_buffer(tbuf.size())):
    playback.push_buffer(tbuf)
  else:
    push_buffer_idx = 0


func _on_MS2texture_pressed():
  gen_audio_tex()


func _on_playwav_pressed():
  if($"../test_play".playing):
    $"../test_play".stop()
    return
  var loaded_stream22:AudioStreamSample
  #loaded_stream22 = load("res://16bit_stereo_1sec_mainSound_gen_C.wav")
  loaded_stream22 = load("res://16bit_stereo_0.1sec_midi_.wav")
  print("audio 16bit_stereo_0.1sec_midi_.wav")
  print("mix_rate "+str(loaded_stream22.mix_rate))
  if(loaded_stream22.format==AudioStreamSample.FORMAT_8_BITS):
    print("AudioStreamSample.FORMAT_8_BITS")
  if(loaded_stream22.format==AudioStreamSample.FORMAT_16_BITS):
    print("AudioStreamSample.FORMAT_16_BITS")
  print("stereo "+str(loaded_stream22.stereo))
  print()
  $"../test_play".stream=loaded_stream22
  $"../test_play".play()


func _on_wav2text_pressed():
  var loaded_stream:AudioStreamSample
  #loaded_stream = load("res://16bit_stereo_1sec_mainSound_gen_C.wav")
  loaded_stream = load("res://16bit_stereo_0.1sec_midi_.wav")
  #loaded_stream=$test_play.stream
  var audio_data:PoolByteArray  = loaded_stream.get_data()
  var sample_rate = loaded_stream.mix_rate
  print("sample_rate "+str(sample_rate))
  if(loaded_stream.format==AudioStreamSample.FORMAT_8_BITS):
    print("AudioStreamSample.FORMAT_8_BITS")
    print("NOT IMPLEMENTED return")
    return
  if(loaded_stream.format==AudioStreamSample.FORMAT_16_BITS):
    print("AudioStreamSample.FORMAT_16_BITS")
    
  print("audio_data size "+str(audio_data.size()))
  
  var cdata =  gen_audio_byte_arr(audio_data)
  print("cdata size "+str(cdata.size()))
  gen_audio_tex_from_samples(cdata)
  


func _on_playtexture_pressed():
  is_play_texture = true
  play_time=0.0


func _on_playtexture_buffer_pressed():
  var img:PoolByteArray = $tabs/texture.texture.get_data().get_data()
  push_buffer_tar.clear()
  #playback.clear_buffer()
  var frames_to_generate = int(rec_time_texture * texture_sample_rate)
  var lpt = 0.0
  var lsample = 0.0
  var llsample = 0.0
  for i in range(frames_to_generate):
    #mainSound
    var sample = 0.0

    sample = (img[int(lpt*texture_sample_rate)])/255.0
    sample = (clamp(sample,0.0,1.0))*2.0-1.0 
    
    # NOT mainSound
    sample = sign(sample)*(1.0-abs(sample)) 
    
    push_buffer_tar.push_back(Vector2((sample), (sample)))  # Stereo (L, R)
    lpt += 1.0 / texture_sample_rate
    
    if lpt>=rec_time_texture:
      break
  push_buffer_idx = -1
  var tbuf = PoolVector2Array(push_buffer_tar)
  if(playback.can_push_buffer(tbuf.size())):
    playback.push_buffer(tbuf)
  else:
    push_buffer_idx = 0




func _on_process_texture2_pressed():
  if not ($wav_texture_code.g_range200.empty()):
    push_buffer_tar.clear()
    var img:PoolByteArray = []
    var img_width:int = ceil(texture_sample_rate/texture_width_multiplier)
    var img_heigh:int = ceil(rec_time_texture*texture_width_multiplier)
    var frames_to_generate = img_width*img_heigh
    for a in range(frames_to_generate):
      img.push_back($wav_texture_code.get_note($wav_texture_code.g_range200, $wav_texture_code.g_range0, $wav_texture_code.g_data200, $wav_texture_code.g_data0, a))
    var lpt = 0.0
    for i in range(frames_to_generate):
      #mainSound
      var sample = 0.0

      sample = (img[int(lpt*texture_sample_rate)])/255.0
      sample = (clamp(sample,0.0,1.0))*2.0-1.0 

      # NOT mainSound
      sample = sign(sample)*(1.0-abs(sample)) 

      push_buffer_tar.push_back(Vector2((sample), (sample)))
      lpt += 1.0 / texture_sample_rate

      if lpt>=rec_time_texture:
        break
  push_buffer_idx = -1
  var tbuf = PoolVector2Array(push_buffer_tar)
  if(playback.can_push_buffer(tbuf.size())):
    playback.push_buffer(tbuf)
  else:
    push_buffer_idx = 0
  pass


func _on_save_img_pressed():
  #$tabs/texture.texture.get_data().save_png("/home/danil/sound2.png")
  pass








