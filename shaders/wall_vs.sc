$input a_position, a_texcoord0, a_normal
$output v_color0, v_texcoord0, v_texcoord1, viewXY, viewDir, fogColor, v_position_eyespace, classicDepth, FDxLOG2E, v_normal

#include "include/common.sh"

uniform mat4 MS_ModelViewProjectionMatrix;
uniform mat4 MS_ModelViewMatrix;
uniform mat4 MS_ModelViewMatrixInverse;
uniform mat4 MS_TextureMatrix;
uniform vec4 vColor;
uniform vec4 vFogColor;
uniform vec4 vTexCoord4;
uniform float depth;

void main()
{
    gl_Position = mul(MS_ModelViewProjectionMatrix, vec4(a_position, 1.0));
    gl_Position.xyz /= gl_Position.w;
    gl_Position.w = 1.0;

    
    gl_Position.z = gl_Position.z + depth*gl_Position.z/65536.0;
    classicDepth = gl_Position.z / 8192.0;
    v_position_eyespace = mul(MS_ModelViewMatrix, vec4(a_position, 1.0));
    v_position_eyespace.xyz /= v_position_eyespace.w;
    
    vec4 UV4 = vec4(a_texcoord0.x, a_texcoord0.y, 0.0, 1.0);           //DCW shitty attempt to stuff texUV into a vec4
    mat3 normalMatrix = mat3(transpose(MS_ModelViewMatrixInverse));           //DCW shitty replacement for gl_NormalMatrix
    v_texcoord0 = (MS_TextureMatrix * UV4).xy;
    /* SETUP TBN MATRIX in normal matrix coords, a_texcoord04 = tangent vector */
    vec3 n = normalize(normalMatrix * a_normal);
    vec3 t = normalize(normalMatrix * vTexCoord4.xyz);
    vec3 b = normalize(cross(n, t) * vTexCoord4.w);
    /* (column wise) */
    mat3 tbnMatrix = mat3(t.x, b.x, n.x, t.y, b.y, n.y, t.z, b.z, n.z);
    
    /* SETUP VIEW DIRECTION in unprojected local coords */
    viewDir = tbnMatrix * (MS_ModelViewMatrix * vec4(a_position, 1.0)).xyz;
    viewXY = -(MS_TextureMatrix * vec4(viewDir.xyz, 1.0)).xyz;
    viewDir = -viewDir;
    v_color0 = vColor;
    FDxLOG2E = -(1.0-vFogColor.a) * 1.442695; //dcw that 1- may be wrong.
    fogColor = vFogColor;
}
