$input v_color0, v_texcoord0, v_texcoord1, viewXY, viewDir, fogColor, v_position_eyespace, classicDepth, FDxLOG2E, v_normal

#include "include/common.sh"

SAMPLER2D(texture0,  0);

uniform float pulsate;
uniform float wobble;
uniform float glow;
uniform float flare;
uniform float selfLuminosity;
uniform vec4 mediaPlane;

void main()
{
    vec3 texCoords = vec3(v_texcoord0.xy, 0.0);
    vec3 normXY = normalize(viewXY);
    texCoords += vec3(normXY.y * -pulsate, normXY.x * pulsate, 0.0);
    texCoords += vec3(normXY.y * -wobble * texCoords.y, wobble * texCoords.y, 0.0);
    float mlFactor = clamp(selfLuminosity + flare - classicDepth, 0.0, 1.0);
    // more realistic: replace classicDepth with (length(viewDir)/8192.0)
    vec3 intensity;
    if (v_color0.r > mlFactor) {
        intensity = v_color0.rgb + (mlFactor * 0.5); }
    else {
        intensity = (v_color0.rgb * 0.5) + mlFactor; }
    intensity = clamp(intensity, glow, 1.0);
//#ifdef GAMMA_CORRECTED_BLENDING
//    intensity = intensity * intensity; // approximation of pow(intensity, 2.2)
//#endif
    vec4 color = texture2D(texture0, texCoords.xy);
    float fogFactor = clamp(exp2(FDxLOG2E * length(viewDir)), 0.0, 1.0);
    fogFactor=clamp( length(viewDir), 0.0, 1.0); //dcw shit test. ok... maybe we need this...
    gl_FragColor = vec4(mix(fogColor.rgb, color.rgb * intensity, fogFactor), v_color0.a * color.a);

}
