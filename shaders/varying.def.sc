vec4 v_color0    : COLOR0    = vec4(1.0, 0.0, 0.0, 1.0);
vec4 v_color1    : COLOR1    = vec4(0.0, 1.0, 0.0, 1.0);
vec4 fogColor   : COLOR2    = vec4(0.0, 0.0, 1.0, 1.0);
vec2 v_texcoord0 : TEXCOORD0 = vec2(0.0, 0.0);
vec2 v_texcoord1 : TEXCOORD1 = vec2(0.0, 0.0);
vec3 v_normal    : NORMAL0 = vec3(0.0, 1.0, 0.0);
vec4 v_position_eyespace : POSITION1 = vec4(0.0, 0.0, 0.0, 1.0);
vec3 viewDir : POSITION2 = vec3(0.0, 0.0, 1.0);
vec3 viewXY  : POSITION3 = vec3(0.0, 0.0, 1.0);
float classicDepth : FLOAT0;
float FDxLOG2E : FLOAT1;


vec3 a_position  : POSITION;
vec3 a_normal    : NORMAL0;
vec4 a_color0    : COLOR0;
vec4 a_color1    : COLOR1;
vec2 a_texcoord0 : TEXCOORD0;
