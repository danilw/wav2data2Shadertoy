//Copy to Shadertoy audio shader

ivec2 range200[21] = ivec2[21](
ivec2(356, 3), ivec2(363, 1), ivec2(368, 3), 
ivec2(374, 2), ivec2(381, 1), ivec2(383, 1), 
ivec2(388, 1), ivec2(393, 2), ivec2(397, 2), 
ivec2(402, 4), ivec2(408, 2), ivec2(411, 1), 
ivec2(414, 1), ivec2(417, 1), ivec2(420, 1), 
ivec2(460, 57), ivec2(585, 76), ivec2(750, 94), 
ivec2(941, 132), ivec2(1074, 2), ivec2(1077, 1)
);

ivec2 range0[11] = ivec2[11](
ivec2(399, 3), ivec2(406, 2), ivec2(412, 2), 
ivec2(416, 1), ivec2(418, 2), ivec2(421, 36), 
ivec2(458, 2), ivec2(519, 65), ivec2(663, 84), 
ivec2(847, 89), ivec2(1095, 8)
);

int data200[49] = int[49](
0x11100000, 0x22110001, 0x61441555, 0x58614314, 
0xdcdcbaa8, 0xdddddddd, 0xeeeeeeed, 0xfffffeee, 
0xddeeeeee, 0x3456799c, 0x43221122, 0x87775544, 
0xaaaaa999, 0xbbbbbbba, 0xccccccbb, 0xdddccccc, 
0xdddddddd, 0x9abbcccd, 0x66588799, 0x11213545, 
0x43333221, 0x77666545, 0x99988787, 0xaaaaa9a9, 
0xbbbbbbba, 0xcccbbbbb, 0xbbbccccc, 0xabbbbbbb, 
0x899aaaaa, 0x66777888, 0x33444556, 0x11111223, 
0x22222111, 0x33333322, 0x44433333, 0x44444444, 
0x44444444, 0x44444444, 0x44444444, 0x34444444, 
0x33333343, 0x33333333, 0x22323333, 0x22222222, 
0x22222222, 0x21222222, 0x11111211, 0x11111111, 
0x00001111
);

int data0[37] = int[37](
0x54432131, 0x66829395, 0xac88a56b, 0xccaacb88, 
0x75a9baaa, 0x1133454a, 0x65433211, 0xaaa89876, 
0xbbbaaaaa, 0xcccbbbbb, 0xcccccccc, 0xabcccddd, 
0x678889aa, 0x13235555, 0x53332111, 0x88776654, 
0x99999999, 0xaaaaaaaa, 0xbbbbbbba, 0xcbbbbbbb, 
0xabbbbbcc, 0x999aaaaa, 0x56777888, 0x33445556, 
0x11111223, 0x44333222, 0x66655544, 0x87777776, 
0x88888888, 0x88888888, 0x88888888, 0x77777888, 
0x56666677, 0x44445555, 0x22233333, 0x11111122, 
0x00111111
);

const float rec_time_texture = 0.1;


// this compression for "res://16bit_stereo_0.1sec_midi_.wav"
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

