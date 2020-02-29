$input v_texcoord0

#include "common.sh"

SAMPLER2D(s_texColor,  0);
//uniform vec4 u_color;

void main()                                
{
// texture2D(s_texColor, v_texcoord0) * u_color;
  gl_FragColor.xyz = texture2D(s_texColor, v_texcoord0);
  gl_FragColor.w = 1.0;
}                                          
