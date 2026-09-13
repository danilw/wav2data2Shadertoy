# wav2data2Shadertoy

**What is it** - tool made in Godot for wav data analyze.

**This is Godot 3.6 project - download Godot 3.6 and open this**

*Sharing it mostly as notes to myself how to work with procedural audio in Godot*

___

- result in `sound_shader_result.glsl`
- this is result only for `16bit_stereo_0.1sec_midi_.wav` this specific audio
- data analyze is - to display wav as texture - and as numbers in Array tab - then do "hand compression" visually analyzing data
- script `code_compress.gd` with compress code
- script `main.gd` with all godot audio to data and back to audio functions

Usage - convert short segments like "sound of note" for MIDI like sound shaders.

___

*it is part of this project and audio shader* https://www.shadertoy.com/view/WctcWf

**Screenshot**:

<img width="1026" height="638" alt="scr" src="https://github.com/user-attachments/assets/771f878e-dd14-4b15-8710-a7d28d1ee3bb" />
