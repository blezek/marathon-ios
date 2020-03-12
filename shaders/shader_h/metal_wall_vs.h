static const uint8_t metal_wall_vs[2914] =
{
	0x56, 0x53, 0x48, 0x06, 0x00, 0x00, 0x00, 0x00, 0x56, 0x2a, 0xf0, 0x9e, 0x08, 0x00, 0x1c, 0x4d, // VSH.....V*.....M
	0x53, 0x5f, 0x4d, 0x6f, 0x64, 0x65, 0x6c, 0x56, 0x69, 0x65, 0x77, 0x50, 0x72, 0x6f, 0x6a, 0x65, // S_ModelViewProje
	0x63, 0x74, 0x69, 0x6f, 0x6e, 0x4d, 0x61, 0x74, 0x72, 0x69, 0x78, 0x04, 0x01, 0x00, 0x00, 0x04, // ctionMatrix.....
	0x00, 0x05, 0x64, 0x65, 0x70, 0x74, 0x68, 0x01, 0x01, 0x30, 0x01, 0x01, 0x00, 0x12, 0x4d, 0x53, // ..depth..0....MS
	0x5f, 0x4d, 0x6f, 0x64, 0x65, 0x6c, 0x56, 0x69, 0x65, 0x77, 0x4d, 0x61, 0x74, 0x72, 0x69, 0x78, // _ModelViewMatrix
	0x04, 0x01, 0x40, 0x00, 0x04, 0x00, 0x19, 0x4d, 0x53, 0x5f, 0x4d, 0x6f, 0x64, 0x65, 0x6c, 0x56, // ..@....MS_ModelV
	0x69, 0x65, 0x77, 0x4d, 0x61, 0x74, 0x72, 0x69, 0x78, 0x49, 0x6e, 0x76, 0x65, 0x72, 0x73, 0x65, // iewMatrixInverse
	0x04, 0x01, 0x80, 0x00, 0x04, 0x00, 0x10, 0x4d, 0x53, 0x5f, 0x54, 0x65, 0x78, 0x74, 0x75, 0x72, // .......MS_Textur
	0x65, 0x4d, 0x61, 0x74, 0x72, 0x69, 0x78, 0x04, 0x01, 0xc0, 0x00, 0x04, 0x00, 0x0a, 0x76, 0x54, // eMatrix.......vT
	0x65, 0x78, 0x43, 0x6f, 0x6f, 0x72, 0x64, 0x34, 0x02, 0x01, 0x20, 0x01, 0x01, 0x00, 0x06, 0x76, // exCoord4.. ....v
	0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x02, 0x01, 0x00, 0x01, 0x01, 0x00, 0x09, 0x76, 0x46, 0x6f, 0x67, // Color.......vFog
	0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x02, 0x01, 0x10, 0x01, 0x01, 0x00, 0x99, 0x0a, 0x00, 0x00, 0x23, // Color..........#
	0x69, 0x6e, 0x63, 0x6c, 0x75, 0x64, 0x65, 0x20, 0x3c, 0x6d, 0x65, 0x74, 0x61, 0x6c, 0x5f, 0x73, // include <metal_s
	0x74, 0x64, 0x6c, 0x69, 0x62, 0x3e, 0x0a, 0x23, 0x69, 0x6e, 0x63, 0x6c, 0x75, 0x64, 0x65, 0x20, // tdlib>.#include 
	0x3c, 0x73, 0x69, 0x6d, 0x64, 0x2f, 0x73, 0x69, 0x6d, 0x64, 0x2e, 0x68, 0x3e, 0x0a, 0x0a, 0x75, // <simd/simd.h>..u
	0x73, 0x69, 0x6e, 0x67, 0x20, 0x6e, 0x61, 0x6d, 0x65, 0x73, 0x70, 0x61, 0x63, 0x65, 0x20, 0x6d, // sing namespace m
	0x65, 0x74, 0x61, 0x6c, 0x3b, 0x0a, 0x0a, 0x73, 0x74, 0x72, 0x75, 0x63, 0x74, 0x20, 0x5f, 0x47, // etal;..struct _G
	0x6c, 0x6f, 0x62, 0x61, 0x6c, 0x0a, 0x7b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, // lobal.{.    floa
	0x74, 0x34, 0x78, 0x34, 0x20, 0x4d, 0x53, 0x5f, 0x4d, 0x6f, 0x64, 0x65, 0x6c, 0x56, 0x69, 0x65, // t4x4 MS_ModelVie
	0x77, 0x50, 0x72, 0x6f, 0x6a, 0x65, 0x63, 0x74, 0x69, 0x6f, 0x6e, 0x4d, 0x61, 0x74, 0x72, 0x69, // wProjectionMatri
	0x78, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x34, 0x78, 0x34, 0x20, // x;.    float4x4 
	0x4d, 0x53, 0x5f, 0x4d, 0x6f, 0x64, 0x65, 0x6c, 0x56, 0x69, 0x65, 0x77, 0x4d, 0x61, 0x74, 0x72, // MS_ModelViewMatr
	0x69, 0x78, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x34, 0x78, 0x34, // ix;.    float4x4
	0x20, 0x4d, 0x53, 0x5f, 0x4d, 0x6f, 0x64, 0x65, 0x6c, 0x56, 0x69, 0x65, 0x77, 0x4d, 0x61, 0x74, //  MS_ModelViewMat
	0x72, 0x69, 0x78, 0x49, 0x6e, 0x76, 0x65, 0x72, 0x73, 0x65, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, // rixInverse;.    
	0x66, 0x6c, 0x6f, 0x61, 0x74, 0x34, 0x78, 0x34, 0x20, 0x4d, 0x53, 0x5f, 0x54, 0x65, 0x78, 0x74, // float4x4 MS_Text
	0x75, 0x72, 0x65, 0x4d, 0x61, 0x74, 0x72, 0x69, 0x78, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, // ureMatrix;.    f
	0x6c, 0x6f, 0x61, 0x74, 0x34, 0x20, 0x76, 0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x3b, 0x0a, 0x20, 0x20, // loat4 vColor;.  
	0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x34, 0x20, 0x76, 0x46, 0x6f, 0x67, 0x43, 0x6f, 0x6c, //   float4 vFogCol
	0x6f, 0x72, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x34, 0x20, 0x76, // or;.    float4 v
	0x54, 0x65, 0x78, 0x43, 0x6f, 0x6f, 0x72, 0x64, 0x34, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, // TexCoord4;.    f
	0x6c, 0x6f, 0x61, 0x74, 0x20, 0x64, 0x65, 0x70, 0x74, 0x68, 0x3b, 0x0a, 0x7d, 0x3b, 0x0a, 0x0a, // loat depth;.};..
	0x73, 0x74, 0x72, 0x75, 0x63, 0x74, 0x20, 0x78, 0x6c, 0x61, 0x74, 0x4d, 0x74, 0x6c, 0x4d, 0x61, // struct xlatMtlMa
	0x69, 0x6e, 0x5f, 0x6f, 0x75, 0x74, 0x0a, 0x7b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, // in_out.{.    flo
	0x61, 0x74, 0x20, 0x5f, 0x65, 0x6e, 0x74, 0x72, 0x79, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x4f, 0x75, // at _entryPointOu
	0x74, 0x70, 0x75, 0x74, 0x5f, 0x46, 0x44, 0x78, 0x4c, 0x4f, 0x47, 0x32, 0x45, 0x20, 0x5b, 0x5b, // tput_FDxLOG2E [[
	0x75, 0x73, 0x65, 0x72, 0x28, 0x6c, 0x6f, 0x63, 0x6e, 0x30, 0x29, 0x5d, 0x5d, 0x3b, 0x0a, 0x20, // user(locn0)]];. 
	0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x20, 0x5f, 0x65, 0x6e, 0x74, 0x72, 0x79, 0x50, //    float _entryP
	0x6f, 0x69, 0x6e, 0x74, 0x4f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x5f, 0x63, 0x6c, 0x61, 0x73, 0x73, // ointOutput_class
	0x69, 0x63, 0x44, 0x65, 0x70, 0x74, 0x68, 0x20, 0x5b, 0x5b, 0x75, 0x73, 0x65, 0x72, 0x28, 0x6c, // icDepth [[user(l
	0x6f, 0x63, 0x6e, 0x31, 0x29, 0x5d, 0x5d, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, // ocn1)]];.    flo
	0x61, 0x74, 0x34, 0x20, 0x5f, 0x65, 0x6e, 0x74, 0x72, 0x79, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x4f, // at4 _entryPointO
	0x75, 0x74, 0x70, 0x75, 0x74, 0x5f, 0x66, 0x6f, 0x67, 0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x20, 0x5b, // utput_fogColor [
	0x5b, 0x75, 0x73, 0x65, 0x72, 0x28, 0x6c, 0x6f, 0x63, 0x6e, 0x32, 0x29, 0x5d, 0x5d, 0x3b, 0x0a, // [user(locn2)]];.
	0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x34, 0x20, 0x5f, 0x65, 0x6e, 0x74, 0x72, //     float4 _entr
	0x79, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x4f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x5f, 0x76, 0x5f, 0x63, // yPointOutput_v_c
	0x6f, 0x6c, 0x6f, 0x72, 0x30, 0x20, 0x5b, 0x5b, 0x75, 0x73, 0x65, 0x72, 0x28, 0x6c, 0x6f, 0x63, // olor0 [[user(loc
	0x6e, 0x33, 0x29, 0x5d, 0x5d, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, // n3)]];.    float
	0x33, 0x20, 0x5f, 0x65, 0x6e, 0x74, 0x72, 0x79, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x4f, 0x75, 0x74, // 3 _entryPointOut
	0x70, 0x75, 0x74, 0x5f, 0x76, 0x5f, 0x6e, 0x6f, 0x72, 0x6d, 0x61, 0x6c, 0x20, 0x5b, 0x5b, 0x75, // put_v_normal [[u
	0x73, 0x65, 0x72, 0x28, 0x6c, 0x6f, 0x63, 0x6e, 0x34, 0x29, 0x5d, 0x5d, 0x3b, 0x0a, 0x20, 0x20, // ser(locn4)]];.  
	0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x34, 0x20, 0x5f, 0x65, 0x6e, 0x74, 0x72, 0x79, 0x50, //   float4 _entryP
	0x6f, 0x69, 0x6e, 0x74, 0x4f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x5f, 0x76, 0x5f, 0x70, 0x6f, 0x73, // ointOutput_v_pos
	0x69, 0x74, 0x69, 0x6f, 0x6e, 0x5f, 0x65, 0x79, 0x65, 0x73, 0x70, 0x61, 0x63, 0x65, 0x20, 0x5b, // ition_eyespace [
	0x5b, 0x75, 0x73, 0x65, 0x72, 0x28, 0x6c, 0x6f, 0x63, 0x6e, 0x35, 0x29, 0x5d, 0x5d, 0x3b, 0x0a, // [user(locn5)]];.
	0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x32, 0x20, 0x5f, 0x65, 0x6e, 0x74, 0x72, //     float2 _entr
	0x79, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x4f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x5f, 0x76, 0x5f, 0x74, // yPointOutput_v_t
	0x65, 0x78, 0x63, 0x6f, 0x6f, 0x72, 0x64, 0x30, 0x20, 0x5b, 0x5b, 0x75, 0x73, 0x65, 0x72, 0x28, // excoord0 [[user(
	0x6c, 0x6f, 0x63, 0x6e, 0x36, 0x29, 0x5d, 0x5d, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, // locn6)]];.    fl
	0x6f, 0x61, 0x74, 0x32, 0x20, 0x5f, 0x65, 0x6e, 0x74, 0x72, 0x79, 0x50, 0x6f, 0x69, 0x6e, 0x74, // oat2 _entryPoint
	0x4f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x5f, 0x76, 0x5f, 0x74, 0x65, 0x78, 0x63, 0x6f, 0x6f, 0x72, // Output_v_texcoor
	0x64, 0x31, 0x20, 0x5b, 0x5b, 0x75, 0x73, 0x65, 0x72, 0x28, 0x6c, 0x6f, 0x63, 0x6e, 0x37, 0x29, // d1 [[user(locn7)
	0x5d, 0x5d, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x33, 0x20, 0x5f, // ]];.    float3 _
	0x65, 0x6e, 0x74, 0x72, 0x79, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x4f, 0x75, 0x74, 0x70, 0x75, 0x74, // entryPointOutput
	0x5f, 0x76, 0x69, 0x65, 0x77, 0x44, 0x69, 0x72, 0x20, 0x5b, 0x5b, 0x75, 0x73, 0x65, 0x72, 0x28, // _viewDir [[user(
	0x6c, 0x6f, 0x63, 0x6e, 0x38, 0x29, 0x5d, 0x5d, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, // locn8)]];.    fl
	0x6f, 0x61, 0x74, 0x33, 0x20, 0x5f, 0x65, 0x6e, 0x74, 0x72, 0x79, 0x50, 0x6f, 0x69, 0x6e, 0x74, // oat3 _entryPoint
	0x4f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x5f, 0x76, 0x69, 0x65, 0x77, 0x58, 0x59, 0x20, 0x5b, 0x5b, // Output_viewXY [[
	0x75, 0x73, 0x65, 0x72, 0x28, 0x6c, 0x6f, 0x63, 0x6e, 0x39, 0x29, 0x5d, 0x5d, 0x3b, 0x0a, 0x20, // user(locn9)]];. 
	0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x34, 0x20, 0x67, 0x6c, 0x5f, 0x50, 0x6f, 0x73, //    float4 gl_Pos
	0x69, 0x74, 0x69, 0x6f, 0x6e, 0x20, 0x5b, 0x5b, 0x70, 0x6f, 0x73, 0x69, 0x74, 0x69, 0x6f, 0x6e, // ition [[position
	0x5d, 0x5d, 0x3b, 0x0a, 0x7d, 0x3b, 0x0a, 0x0a, 0x73, 0x74, 0x72, 0x75, 0x63, 0x74, 0x20, 0x78, // ]];.};..struct x
	0x6c, 0x61, 0x74, 0x4d, 0x74, 0x6c, 0x4d, 0x61, 0x69, 0x6e, 0x5f, 0x69, 0x6e, 0x0a, 0x7b, 0x0a, // latMtlMain_in.{.
	0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x33, 0x20, 0x61, 0x5f, 0x6e, 0x6f, 0x72, //     float3 a_nor
	0x6d, 0x61, 0x6c, 0x20, 0x5b, 0x5b, 0x61, 0x74, 0x74, 0x72, 0x69, 0x62, 0x75, 0x74, 0x65, 0x28, // mal [[attribute(
	0x30, 0x29, 0x5d, 0x5d, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x33, // 0)]];.    float3
	0x20, 0x61, 0x5f, 0x70, 0x6f, 0x73, 0x69, 0x74, 0x69, 0x6f, 0x6e, 0x20, 0x5b, 0x5b, 0x61, 0x74, //  a_position [[at
	0x74, 0x72, 0x69, 0x62, 0x75, 0x74, 0x65, 0x28, 0x31, 0x29, 0x5d, 0x5d, 0x3b, 0x0a, 0x20, 0x20, // tribute(1)]];.  
	0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x32, 0x20, 0x61, 0x5f, 0x74, 0x65, 0x78, 0x63, 0x6f, //   float2 a_texco
	0x6f, 0x72, 0x64, 0x30, 0x20, 0x5b, 0x5b, 0x61, 0x74, 0x74, 0x72, 0x69, 0x62, 0x75, 0x74, 0x65, // ord0 [[attribute
	0x28, 0x32, 0x29, 0x5d, 0x5d, 0x3b, 0x0a, 0x7d, 0x3b, 0x0a, 0x0a, 0x76, 0x65, 0x72, 0x74, 0x65, // (2)]];.};..verte
	0x78, 0x20, 0x78, 0x6c, 0x61, 0x74, 0x4d, 0x74, 0x6c, 0x4d, 0x61, 0x69, 0x6e, 0x5f, 0x6f, 0x75, // x xlatMtlMain_ou
	0x74, 0x20, 0x78, 0x6c, 0x61, 0x74, 0x4d, 0x74, 0x6c, 0x4d, 0x61, 0x69, 0x6e, 0x28, 0x78, 0x6c, // t xlatMtlMain(xl
	0x61, 0x74, 0x4d, 0x74, 0x6c, 0x4d, 0x61, 0x69, 0x6e, 0x5f, 0x69, 0x6e, 0x20, 0x69, 0x6e, 0x20, // atMtlMain_in in 
	0x5b, 0x5b, 0x73, 0x74, 0x61, 0x67, 0x65, 0x5f, 0x69, 0x6e, 0x5d, 0x5d, 0x2c, 0x20, 0x63, 0x6f, // [[stage_in]], co
	0x6e, 0x73, 0x74, 0x61, 0x6e, 0x74, 0x20, 0x5f, 0x47, 0x6c, 0x6f, 0x62, 0x61, 0x6c, 0x26, 0x20, // nstant _Global& 
	0x5f, 0x6d, 0x74, 0x6c, 0x5f, 0x75, 0x20, 0x5b, 0x5b, 0x62, 0x75, 0x66, 0x66, 0x65, 0x72, 0x28, // _mtl_u [[buffer(
	0x30, 0x29, 0x5d, 0x5d, 0x29, 0x0a, 0x7b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x78, 0x6c, 0x61, 0x74, // 0)]]).{.    xlat
	0x4d, 0x74, 0x6c, 0x4d, 0x61, 0x69, 0x6e, 0x5f, 0x6f, 0x75, 0x74, 0x20, 0x6f, 0x75, 0x74, 0x20, // MtlMain_out out 
	0x3d, 0x20, 0x7b, 0x7d, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x34, // = {};.    float4
	0x20, 0x5f, 0x33, 0x30, 0x35, 0x20, 0x3d, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x34, 0x28, 0x69, //  _305 = float4(i
	0x6e, 0x2e, 0x61, 0x5f, 0x70, 0x6f, 0x73, 0x69, 0x74, 0x69, 0x6f, 0x6e, 0x2c, 0x20, 0x31, 0x2e, // n.a_position, 1.
	0x30, 0x29, 0x20, 0x2a, 0x20, 0x5f, 0x6d, 0x74, 0x6c, 0x5f, 0x75, 0x2e, 0x4d, 0x53, 0x5f, 0x4d, // 0) * _mtl_u.MS_M
	0x6f, 0x64, 0x65, 0x6c, 0x56, 0x69, 0x65, 0x77, 0x50, 0x72, 0x6f, 0x6a, 0x65, 0x63, 0x74, 0x69, // odelViewProjecti
	0x6f, 0x6e, 0x4d, 0x61, 0x74, 0x72, 0x69, 0x78, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, // onMatrix;.    fl
	0x6f, 0x61, 0x74, 0x20, 0x5f, 0x33, 0x31, 0x35, 0x20, 0x3d, 0x20, 0x5f, 0x33, 0x30, 0x35, 0x2e, // oat _315 = _305.
	0x7a, 0x20, 0x2b, 0x20, 0x28, 0x28, 0x5f, 0x6d, 0x74, 0x6c, 0x5f, 0x75, 0x2e, 0x64, 0x65, 0x70, // z + ((_mtl_u.dep
	0x74, 0x68, 0x20, 0x2a, 0x20, 0x5f, 0x33, 0x30, 0x35, 0x2e, 0x7a, 0x29, 0x20, 0x2a, 0x20, 0x31, // th * _305.z) * 1
	0x2e, 0x35, 0x32, 0x35, 0x38, 0x37, 0x38, 0x39, 0x30, 0x36, 0x32, 0x35, 0x65, 0x2d, 0x30, 0x35, // .52587890625e-05
	0x29, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x34, 0x20, 0x5f, 0x35, // );.    float4 _5
	0x31, 0x37, 0x20, 0x3d, 0x20, 0x5f, 0x33, 0x30, 0x35, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x5f, // 17 = _305;.    _
	0x35, 0x31, 0x37, 0x2e, 0x7a, 0x20, 0x3d, 0x20, 0x5f, 0x33, 0x31, 0x35, 0x3b, 0x0a, 0x20, 0x20, // 517.z = _315;.  
	0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x34, 0x78, 0x34, 0x20, 0x5f, 0x33, 0x33, 0x37, 0x20, //   float4x4 _337 
	0x3d, 0x20, 0x74, 0x72, 0x61, 0x6e, 0x73, 0x70, 0x6f, 0x73, 0x65, 0x28, 0x74, 0x72, 0x61, 0x6e, // = transpose(tran
	0x73, 0x70, 0x6f, 0x73, 0x65, 0x28, 0x5f, 0x6d, 0x74, 0x6c, 0x5f, 0x75, 0x2e, 0x4d, 0x53, 0x5f, // spose(_mtl_u.MS_
	0x4d, 0x6f, 0x64, 0x65, 0x6c, 0x56, 0x69, 0x65, 0x77, 0x4d, 0x61, 0x74, 0x72, 0x69, 0x78, 0x49, // ModelViewMatrixI
	0x6e, 0x76, 0x65, 0x72, 0x73, 0x65, 0x29, 0x29, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, // nverse));.    fl
	0x6f, 0x61, 0x74, 0x33, 0x78, 0x33, 0x20, 0x5f, 0x33, 0x34, 0x34, 0x20, 0x3d, 0x20, 0x66, 0x6c, // oat3x3 _344 = fl
	0x6f, 0x61, 0x74, 0x33, 0x78, 0x33, 0x28, 0x5f, 0x33, 0x33, 0x37, 0x5b, 0x30, 0x5d, 0x2e, 0x78, // oat3x3(_337[0].x
	0x79, 0x7a, 0x2c, 0x20, 0x5f, 0x33, 0x33, 0x37, 0x5b, 0x31, 0x5d, 0x2e, 0x78, 0x79, 0x7a, 0x2c, // yz, _337[1].xyz,
	0x20, 0x5f, 0x33, 0x33, 0x37, 0x5b, 0x32, 0x5d, 0x2e, 0x78, 0x79, 0x7a, 0x29, 0x3b, 0x0a, 0x20, //  _337[2].xyz);. 
	0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x33, 0x20, 0x5f, 0x33, 0x35, 0x34, 0x20, 0x3d, //    float3 _354 =
	0x20, 0x6e, 0x6f, 0x72, 0x6d, 0x61, 0x6c, 0x69, 0x7a, 0x65, 0x28, 0x5f, 0x33, 0x34, 0x34, 0x20, //  normalize(_344 
	0x2a, 0x20, 0x69, 0x6e, 0x2e, 0x61, 0x5f, 0x6e, 0x6f, 0x72, 0x6d, 0x61, 0x6c, 0x29, 0x3b, 0x0a, // * in.a_normal);.
	0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x33, 0x20, 0x5f, 0x33, 0x36, 0x30, 0x20, //     float3 _360 
	0x3d, 0x20, 0x6e, 0x6f, 0x72, 0x6d, 0x61, 0x6c, 0x69, 0x7a, 0x65, 0x28, 0x5f, 0x33, 0x34, 0x34, // = normalize(_344
	0x20, 0x2a, 0x20, 0x5f, 0x6d, 0x74, 0x6c, 0x5f, 0x75, 0x2e, 0x76, 0x54, 0x65, 0x78, 0x43, 0x6f, //  * _mtl_u.vTexCo
	0x6f, 0x72, 0x64, 0x34, 0x2e, 0x78, 0x79, 0x7a, 0x29, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, // ord4.xyz);.    f
	0x6c, 0x6f, 0x61, 0x74, 0x33, 0x20, 0x5f, 0x33, 0x36, 0x37, 0x20, 0x3d, 0x20, 0x6e, 0x6f, 0x72, // loat3 _367 = nor
	0x6d, 0x61, 0x6c, 0x69, 0x7a, 0x65, 0x28, 0x63, 0x72, 0x6f, 0x73, 0x73, 0x28, 0x5f, 0x33, 0x35, // malize(cross(_35
	0x34, 0x2c, 0x20, 0x5f, 0x33, 0x36, 0x30, 0x29, 0x20, 0x2a, 0x20, 0x5f, 0x6d, 0x74, 0x6c, 0x5f, // 4, _360) * _mtl_
	0x75, 0x2e, 0x76, 0x54, 0x65, 0x78, 0x43, 0x6f, 0x6f, 0x72, 0x64, 0x34, 0x2e, 0x77, 0x29, 0x3b, // u.vTexCoord4.w);
	0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x33, 0x20, 0x5f, 0x34, 0x30, 0x30, // .    float3 _400
	0x20, 0x3d, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x33, 0x78, 0x33, 0x28, 0x66, 0x6c, 0x6f, 0x61, //  = float3x3(floa
	0x74, 0x33, 0x28, 0x5f, 0x33, 0x36, 0x30, 0x2e, 0x78, 0x2c, 0x20, 0x5f, 0x33, 0x36, 0x37, 0x2e, // t3(_360.x, _367.
	0x78, 0x2c, 0x20, 0x5f, 0x33, 0x35, 0x34, 0x2e, 0x78, 0x29, 0x2c, 0x20, 0x66, 0x6c, 0x6f, 0x61, // x, _354.x), floa
	0x74, 0x33, 0x28, 0x5f, 0x33, 0x36, 0x30, 0x2e, 0x79, 0x2c, 0x20, 0x5f, 0x33, 0x36, 0x37, 0x2e, // t3(_360.y, _367.
	0x79, 0x2c, 0x20, 0x5f, 0x33, 0x35, 0x34, 0x2e, 0x79, 0x29, 0x2c, 0x20, 0x66, 0x6c, 0x6f, 0x61, // y, _354.y), floa
	0x74, 0x33, 0x28, 0x5f, 0x33, 0x36, 0x30, 0x2e, 0x7a, 0x2c, 0x20, 0x5f, 0x33, 0x36, 0x37, 0x2e, // t3(_360.z, _367.
	0x7a, 0x2c, 0x20, 0x5f, 0x33, 0x35, 0x34, 0x2e, 0x7a, 0x29, 0x29, 0x20, 0x2a, 0x20, 0x28, 0x66, // z, _354.z)) * (f
	0x6c, 0x6f, 0x61, 0x74, 0x34, 0x28, 0x69, 0x6e, 0x2e, 0x61, 0x5f, 0x70, 0x6f, 0x73, 0x69, 0x74, // loat4(in.a_posit
	0x69, 0x6f, 0x6e, 0x2c, 0x20, 0x31, 0x2e, 0x30, 0x29, 0x20, 0x2a, 0x20, 0x5f, 0x6d, 0x74, 0x6c, // ion, 1.0) * _mtl
	0x5f, 0x75, 0x2e, 0x4d, 0x53, 0x5f, 0x4d, 0x6f, 0x64, 0x65, 0x6c, 0x56, 0x69, 0x65, 0x77, 0x4d, // _u.MS_ModelViewM
	0x61, 0x74, 0x72, 0x69, 0x78, 0x29, 0x2e, 0x78, 0x79, 0x7a, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, // atrix).xyz;.    
	0x6f, 0x75, 0x74, 0x2e, 0x67, 0x6c, 0x5f, 0x50, 0x6f, 0x73, 0x69, 0x74, 0x69, 0x6f, 0x6e, 0x20, // out.gl_Position 
	0x3d, 0x20, 0x5f, 0x35, 0x31, 0x37, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x6f, 0x75, 0x74, 0x2e, // = _517;.    out.
	0x5f, 0x65, 0x6e, 0x74, 0x72, 0x79, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x4f, 0x75, 0x74, 0x70, 0x75, // _entryPointOutpu
	0x74, 0x5f, 0x46, 0x44, 0x78, 0x4c, 0x4f, 0x47, 0x32, 0x45, 0x20, 0x3d, 0x20, 0x28, 0x5f, 0x6d, // t_FDxLOG2E = (_m
	0x74, 0x6c, 0x5f, 0x75, 0x2e, 0x76, 0x46, 0x6f, 0x67, 0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x2e, 0x77, // tl_u.vFogColor.w
	0x20, 0x2d, 0x20, 0x31, 0x2e, 0x30, 0x29, 0x20, 0x2a, 0x20, 0x31, 0x2e, 0x34, 0x34, 0x32, 0x36, //  - 1.0) * 1.4426
	0x39, 0x35, 0x30, 0x32, 0x31, 0x36, 0x32, 0x39, 0x33, 0x33, 0x33, 0x34, 0x39, 0x36, 0x30, 0x39, // 9502162933349609
	0x33, 0x37, 0x35, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x6f, 0x75, 0x74, 0x2e, 0x5f, 0x65, 0x6e, // 375;.    out._en
	0x74, 0x72, 0x79, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x4f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x5f, 0x63, // tryPointOutput_c
	0x6c, 0x61, 0x73, 0x73, 0x69, 0x63, 0x44, 0x65, 0x70, 0x74, 0x68, 0x20, 0x3d, 0x20, 0x5f, 0x33, // lassicDepth = _3
	0x31, 0x35, 0x20, 0x2a, 0x20, 0x30, 0x2e, 0x30, 0x30, 0x30, 0x31, 0x32, 0x32, 0x30, 0x37, 0x30, // 15 * 0.000122070
	0x33, 0x31, 0x32, 0x35, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x6f, 0x75, 0x74, 0x2e, 0x5f, 0x65, // 3125;.    out._e
	0x6e, 0x74, 0x72, 0x79, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x4f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x5f, // ntryPointOutput_
	0x66, 0x6f, 0x67, 0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x20, 0x3d, 0x20, 0x5f, 0x6d, 0x74, 0x6c, 0x5f, // fogColor = _mtl_
	0x75, 0x2e, 0x76, 0x46, 0x6f, 0x67, 0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x3b, 0x0a, 0x20, 0x20, 0x20, // u.vFogColor;.   
	0x20, 0x6f, 0x75, 0x74, 0x2e, 0x5f, 0x65, 0x6e, 0x74, 0x72, 0x79, 0x50, 0x6f, 0x69, 0x6e, 0x74, //  out._entryPoint
	0x4f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x5f, 0x76, 0x5f, 0x63, 0x6f, 0x6c, 0x6f, 0x72, 0x30, 0x20, // Output_v_color0 
	0x3d, 0x20, 0x5f, 0x6d, 0x74, 0x6c, 0x5f, 0x75, 0x2e, 0x76, 0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x3b, // = _mtl_u.vColor;
	0x0a, 0x20, 0x20, 0x20, 0x20, 0x6f, 0x75, 0x74, 0x2e, 0x5f, 0x65, 0x6e, 0x74, 0x72, 0x79, 0x50, // .    out._entryP
	0x6f, 0x69, 0x6e, 0x74, 0x4f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x5f, 0x76, 0x5f, 0x6e, 0x6f, 0x72, // ointOutput_v_nor
	0x6d, 0x61, 0x6c, 0x20, 0x3d, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x33, 0x28, 0x30, 0x2e, 0x30, // mal = float3(0.0
	0x2c, 0x20, 0x31, 0x2e, 0x30, 0x2c, 0x20, 0x30, 0x2e, 0x30, 0x29, 0x3b, 0x0a, 0x20, 0x20, 0x20, // , 1.0, 0.0);.   
	0x20, 0x6f, 0x75, 0x74, 0x2e, 0x5f, 0x65, 0x6e, 0x74, 0x72, 0x79, 0x50, 0x6f, 0x69, 0x6e, 0x74, //  out._entryPoint
	0x4f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x5f, 0x76, 0x5f, 0x70, 0x6f, 0x73, 0x69, 0x74, 0x69, 0x6f, // Output_v_positio
	0x6e, 0x5f, 0x65, 0x79, 0x65, 0x73, 0x70, 0x61, 0x63, 0x65, 0x20, 0x3d, 0x20, 0x66, 0x6c, 0x6f, // n_eyespace = flo
	0x61, 0x74, 0x34, 0x28, 0x69, 0x6e, 0x2e, 0x61, 0x5f, 0x70, 0x6f, 0x73, 0x69, 0x74, 0x69, 0x6f, // at4(in.a_positio
	0x6e, 0x2c, 0x20, 0x31, 0x2e, 0x30, 0x29, 0x20, 0x2a, 0x20, 0x5f, 0x6d, 0x74, 0x6c, 0x5f, 0x75, // n, 1.0) * _mtl_u
	0x2e, 0x4d, 0x53, 0x5f, 0x4d, 0x6f, 0x64, 0x65, 0x6c, 0x56, 0x69, 0x65, 0x77, 0x4d, 0x61, 0x74, // .MS_ModelViewMat
	0x72, 0x69, 0x78, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x6f, 0x75, 0x74, 0x2e, 0x5f, 0x65, 0x6e, // rix;.    out._en
	0x74, 0x72, 0x79, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x4f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x5f, 0x76, // tryPointOutput_v
	0x5f, 0x74, 0x65, 0x78, 0x63, 0x6f, 0x6f, 0x72, 0x64, 0x30, 0x20, 0x3d, 0x20, 0x28, 0x66, 0x6c, // _texcoord0 = (fl
	0x6f, 0x61, 0x74, 0x34, 0x28, 0x69, 0x6e, 0x2e, 0x61, 0x5f, 0x74, 0x65, 0x78, 0x63, 0x6f, 0x6f, // oat4(in.a_texcoo
	0x72, 0x64, 0x30, 0x2c, 0x20, 0x30, 0x2e, 0x30, 0x2c, 0x20, 0x31, 0x2e, 0x30, 0x29, 0x20, 0x2a, // rd0, 0.0, 1.0) *
	0x20, 0x5f, 0x6d, 0x74, 0x6c, 0x5f, 0x75, 0x2e, 0x4d, 0x53, 0x5f, 0x54, 0x65, 0x78, 0x74, 0x75, //  _mtl_u.MS_Textu
	0x72, 0x65, 0x4d, 0x61, 0x74, 0x72, 0x69, 0x78, 0x29, 0x2e, 0x78, 0x79, 0x3b, 0x0a, 0x20, 0x20, // reMatrix).xy;.  
	0x20, 0x20, 0x6f, 0x75, 0x74, 0x2e, 0x5f, 0x65, 0x6e, 0x74, 0x72, 0x79, 0x50, 0x6f, 0x69, 0x6e, //   out._entryPoin
	0x74, 0x4f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x5f, 0x76, 0x5f, 0x74, 0x65, 0x78, 0x63, 0x6f, 0x6f, // tOutput_v_texcoo
	0x72, 0x64, 0x31, 0x20, 0x3d, 0x20, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x32, 0x28, 0x30, 0x2e, 0x30, // rd1 = float2(0.0
	0x29, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x6f, 0x75, 0x74, 0x2e, 0x5f, 0x65, 0x6e, 0x74, 0x72, // );.    out._entr
	0x79, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x4f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x5f, 0x76, 0x69, 0x65, // yPointOutput_vie
	0x77, 0x44, 0x69, 0x72, 0x20, 0x3d, 0x20, 0x2d, 0x5f, 0x34, 0x30, 0x30, 0x3b, 0x0a, 0x20, 0x20, // wDir = -_400;.  
	0x20, 0x20, 0x6f, 0x75, 0x74, 0x2e, 0x5f, 0x65, 0x6e, 0x74, 0x72, 0x79, 0x50, 0x6f, 0x69, 0x6e, //   out._entryPoin
	0x74, 0x4f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x5f, 0x76, 0x69, 0x65, 0x77, 0x58, 0x59, 0x20, 0x3d, // tOutput_viewXY =
	0x20, 0x2d, 0x28, 0x66, 0x6c, 0x6f, 0x61, 0x74, 0x34, 0x28, 0x5f, 0x34, 0x30, 0x30, 0x2c, 0x20, //  -(float4(_400, 
	0x31, 0x2e, 0x30, 0x29, 0x20, 0x2a, 0x20, 0x5f, 0x6d, 0x74, 0x6c, 0x5f, 0x75, 0x2e, 0x4d, 0x53, // 1.0) * _mtl_u.MS
	0x5f, 0x54, 0x65, 0x78, 0x74, 0x75, 0x72, 0x65, 0x4d, 0x61, 0x74, 0x72, 0x69, 0x78, 0x29, 0x2e, // _TextureMatrix).
	0x78, 0x79, 0x7a, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x72, 0x65, 0x74, 0x75, 0x72, 0x6e, 0x20, // xyz;.    return 
	0x6f, 0x75, 0x74, 0x3b, 0x0a, 0x7d, 0x0a, 0x0a, 0x00, 0x03, 0x02, 0x00, 0x01, 0x00, 0x10, 0x00, // out;.}..........
	0x40, 0x01,                                                                                     // @.
};
