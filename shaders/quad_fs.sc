$input v_texcoord0

#include "include/common.sh"

SAMPLER2D(texture0, 0);
//uniform vec4 u_color;

void main()                                
{
// texture2D(texture0, v_texcoord0) * u_color;
  gl_FragColor.xyz = texture2D(texture0, v_texcoord0);
  gl_FragColor.w = 1.0;
}                                          
