extends HBoxContainer

var g_range200 = [] 
var g_range0 = [] 
var g_data200 = [] 
var g_data0 = [] 

# comprsssion of data
# this made ONLY for this single case
# for "res://16bit_stereo_0.1sec_midi_.wav"

# you need to analyze your data - ranges and compress it
# this 16bit_stereo_0.1sec_midi_.wav - has only 0-10 and 220-255 range of sound
# this how it compressed


# get_note is decompression from ranges
# print_img_data is compression
# reimplement this manually that fit your data

# this compression for "res://16bit_stereo_0.1sec_midi_.wav"
# that is Drumset - Bass drum new from https://signalmidi.app/edit


const rec_time_texture = 0.1


func get_note(range200, range0, data200, data0, p):
  if(p<356):
    return 0
  var sa:int = 0
  for a in range200:
    if(p>=a.x&&p<a.x+a.y):
      var tsa = sa+int(p-a.x)
      if(tsa/8>=data200.size()):
        break
      var tcv = (data200[tsa/8]>>(((tsa%8))*4))&0xf
      return int(255-tcv)
    sa+=int(a.y)
  sa = 0
  for a in range0:
    if(p>=a.x&&p<a.x+a.y):
      var tsa = sa+int(p-a.x)
      if(tsa/8>=data0.size()):
        break
      var tcv = (data0[tsa/8]>>(((tsa%8))*4))&0xf
      return int(tcv)
    sa+=int(a.y)
  return 0

func print_ranges(img:PoolByteArray):
  var last200=-100
  var last0=-100
  var ctr200=0
  var ctr0=0
  var ranges200 = []
  var ranges0 = []
  for a in img.size():
    var ta = img[a]
    if ta>200:
      if(last200+1==a):
        ctr200+=1
      last200=a
      if(last0>=0):
        ranges0.push_back(Vector2(last0-ctr0,ctr0+1))
        last0=-100
        ctr0=0
    else:
      if(ta<200 and ta>0):
        if(last0+1==a):
          ctr0+=1
        last0=a
      if((ta<200 and ta>0)||ta==0):
        if(last200>=0):
          #print(str(a)+" "+str(last200-ctr200))
          ranges200.push_back(Vector2(last200-ctr200,ctr200+1))
          last200=-100
          ctr200=0
      if(ta==0):
        if(last0>=0):
          ranges0.push_back(Vector2(last0-ctr0,ctr0+1))
          last0=-100
          ctr0=0
  if(last200>=0):
    #print(str(a)+" "+str(last200-ctr200))
    ranges200.push_back(Vector2(last200-ctr200,ctr200+1))
    last200=-100
    ctr200=0
  if(last0>=0):
    ranges0.push_back(Vector2(last0-ctr0,ctr0+1))
    last0=-100
    ctr0=0
  var text = ""
  text += "ranges - is pixel ID where data is this range\n"
  text += "ranges200\n"
  text+=str(ranges200)
  text+="\n"
  text+="\n"
  text += "ranges0\n"
  text+=str(ranges0)
  text+="\n"
  text+="\n"
  return [text,ranges200,ranges0]

func print_img_data():
  var img:PoolByteArray = $"../tabs/texture".texture.get_data().get_data()
  var data200t = []
  var data0t = []
  for a in range(img.size()):
    var ta = img[a]
    if ta>200:
      data200t.push_back(255-ta)
    else:
      if(ta<200 and ta>0):
        data0t.push_back(ta)
  var data200 = []
  var data0 = []
  for a in range(data200t.size()/8+1):
    var ta = []
    for b in range(8):
      if(a*8+b<data200t.size()):
        ta.push_back(data200t[a*8+b])
    var tx = 0
    for b in range(ta.size()):
      tx+=ta[b]<<(b*4)
    data200.push_back(tx)
  for a in range(data0t.size()/8+1):
    var ta = []
    for b in range(8):
      if(a*8+b<data0t.size()):
        ta.push_back(data0t[a*8+b])
    var tx = 0
    for b in range(ta.size()):
      tx+=ta[b]<<(b*4)
    data0.push_back(tx)
  var tpr= ""
  tpr+="\n"
  tpr+="\n"
  tpr+="data is 4-bits data compressed\n"
  tpr+="data200\n"
  tpr+=str(data200)
  tpr+="\n"
  tpr+="\n"
  tpr+="\n"
  tpr+="data0\n"
  tpr+=str(data0)
  tpr+="\n"
  var range_dat = print_ranges(img)
  $"../tabs/arrays_as_text".text=range_dat[0]
  $"../tabs/arrays_as_text".text+=tpr
  return [range_dat[1],range_dat[2],data200,data0]


const shader_text = """
// this compression for \"res://16bit_stereo_0.1sec_midi_.wav\"
// that is Drumset - Bass drum new from https://signalmidi.app/edit

int get_note(int p){
  if(p<356)return 0;
  if(p>=int(rec_time_texture*11025.0))return 0;
  int sa = 0;
  for(int i=0;i<range200.length();i++){
    ivec2 a = range200[i];
    if(p>=a.x&&p<a.x+a.y){
      int tsa = sa+(p-a.x);
      if(tsa/8>=data200.length())break;
      int tcv = (data200[tsa/8]>>(((tsa%8))*4))&0xf;
      return 255-tcv;
    }
    sa+=int(a.y);
  }
  sa = 0;
  for(int i=0;i<range0.length();i++){
    ivec2 a = range0[i];
    if(p>=a.x&&p<a.x+a.y){
      int tsa = sa+(p-a.x);
      if(tsa/8>=data0.length())break;
      int tcv = (data0[tsa/8]>>(((tsa%8))*4))&0xf;
      return tcv;
    }
    sa+=int(a.y);
  }
  return 0;
}
vec2 mainSound( int samp, float time )
{
    float timer = (time);
    int frame = int(timer * 11025.0);
    vec3 samplex = vec3(0.);
    samplex = vec3(float(get_note(frame-1))/255.0,float(get_note(frame))/255.0,float(get_note(frame+1))/255.0);
    samplex = (clamp(samplex,0.0,1.0))*2.0-1.0;
    samplex = sign(samplex)*(1.0-abs(samplex));
    
    float ta = fract(timer * 11025.0)-0.5;
    ivec2 tb = ivec2(1,2);
    float samplea = 0.;
    if(ta<0.){ta=abs(ta);tb=ivec2(0,1);}
    samplea = mix(samplex[tb.x],samplex[tb.y],ta);
    
    return vec2(samplea); // interpolated
    //return vec2(samplex.y); // no interpolation
}

"""

func print_shader(range200,range0,data200,data0):
  $"../tabs/code_text".text=""
  
  var ttxt = ""
  ttxt+="//Copy to Shadertoy audio shader\n\n"
  ttxt += "ivec2 range200["+str(range200.size())+"] = ivec2["+str(range200.size())+"](\n"
  var ctr = 0
  for a in range200:
    if((ctr)!=0 and (ctr%3)==0):
      ttxt+="\n"
    ttxt+="ivec2("+str(a.x)+", "+str(a.y)+"), "
    ctr+=1
  ttxt.erase(ttxt.length()-2,2)
  ttxt+="\n"
  ttxt+=");"
  ttxt+="\n"
  ttxt+="\n"
  
  ttxt += "ivec2 range0["+str(range0.size())+"] = ivec2["+str(range0.size())+"](\n"
  ctr = 0
  for a in range0:
    if((ctr)!=0 and (ctr%3)==0):
      ttxt+="\n"
    ttxt+="ivec2("+str(a.x)+", "+str(a.y)+"), "
    ctr+=1
  ttxt.erase(ttxt.length()-2,2)
  ttxt+="\n"
  ttxt+=");"
  ttxt+="\n"
  ttxt+="\n"
  
  ttxt += "int data200["+str(data200.size())+"] = int["+str(data200.size())+"](\n"
  ctr = 0
  for a in data200:
    if((ctr)!=0 and (ctr%4)==0):
      ttxt+="\n"
    ttxt+=String("0x%08x" % a)+", "
    ctr+=1
  ttxt.erase(ttxt.length()-2,2)
  ttxt+="\n"
  ttxt+=");"
  ttxt+="\n"
  ttxt+="\n"
  
  ttxt += "int data0["+str(data0.size())+"] = int["+str(data0.size())+"](\n"
  ctr = 0
  for a in data0:
    if((ctr)!=0 and (ctr%4)==0):
      ttxt+="\n"
    ttxt+=String("0x%08x" % a)+", "
    ctr+=1
  ttxt.erase(ttxt.length()-2,2)
  ttxt+="\n"
  ttxt+=");"
  ttxt+="\n"
  ttxt+="\n"
  
  ttxt+="const float rec_time_texture = "+str(rec_time_texture)+";"
  ttxt+="\n"
  ttxt+="\n"
  
  $"../tabs/code_text".text+=ttxt
  
  $"../tabs/code_text".text+=shader_text


func _ready():
  pass


func _on_process_texture_pressed():
  
  var data20_0 = print_img_data()
  print_shader(data20_0[0],data20_0[1],data20_0[2],data20_0[3])
  g_range200 = data20_0[0]
  g_range0 = data20_0[1]
  g_data200 = data20_0[2]
  g_data0 = data20_0[3]
















