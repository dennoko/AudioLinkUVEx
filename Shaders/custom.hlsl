//----------------------------------------------------------------------------------------------------------------------
// Macro

// Custom variables
#define LIL_CUSTOM_PROPERTIES \
    float4  _Pivot;           \
    float4  _PivotOffset;     \
    float   _MinAngle;        \
    float   _MaxAngle;        \
    float   _AngleOffset;     \
    float   _AudioLinkBand;   \
    float   _AudioLinkDelay;  \
    float   _RedZoneThreshold;\
    float4  _RedZoneColor;

// Custom textures
#define LIL_CUSTOM_TEXTURES \
    TEXTURE2D(_NeedleTex);

// Add vertex shader input
//#define LIL_REQUIRE_APP_POSITION
//#define LIL_REQUIRE_APP_TEXCOORD0
//#define LIL_REQUIRE_APP_TEXCOORD1
//#define LIL_REQUIRE_APP_TEXCOORD2
//#define LIL_REQUIRE_APP_TEXCOORD3
//#define LIL_REQUIRE_APP_TEXCOORD4
//#define LIL_REQUIRE_APP_TEXCOORD5
//#define LIL_REQUIRE_APP_TEXCOORD6
//#define LIL_REQUIRE_APP_TEXCOORD7
//#define LIL_REQUIRE_APP_COLOR
//#define LIL_REQUIRE_APP_NORMAL
//#define LIL_REQUIRE_APP_TANGENT
//#define LIL_REQUIRE_APP_VERTEXID

// Add vertex shader output
//#define LIL_V2F_FORCE_TEXCOORD0
//#define LIL_V2F_FORCE_TEXCOORD1
//#define LIL_V2F_FORCE_POSITION_OS
//#define LIL_V2F_FORCE_POSITION_WS
//#define LIL_V2F_FORCE_POSITION_SS
//#define LIL_V2F_FORCE_NORMAL
//#define LIL_V2F_FORCE_TANGENT
//#define LIL_V2F_FORCE_BITANGENT
//#define LIL_CUSTOM_V2F_MEMBER(id0,id1,id2,id3,id4,id5,id6,id7)

// Geometry shader not used for UV-rotation approach
//#define LIL_CUSTOM_VERT_COPY

//#define LIL_CUSTOM_VERTEX_OS
//#define LIL_CUSTOM_VERTEX_WS

//----------------------------------------------------------------------------------------------------------------------
// Pixel shader: UV rotation for needle mask + red zone emission

#ifndef LIL_PI
#define LIL_PI 3.14159265358979
#endif

// Helper macro: compute AudioLink volume for the selected band/delay and apply UV rotation.
// AudioLink texture layout: 128 wide, bands at x=0..3, delay rows at y=0..3.
// UV.x = (band + 0.5) / 128,  UV.y = (delay + 0.5) / 64.
// When LIL_FEATURE_AUDIOLINK is not defined, fall back to a sine wave for preview.

#if defined(LIL_FEATURE_AUDIOLINK)

#define BEFORE_ALPHAMASK \
    { \
        float2 _alUV = float2((_AudioLinkBand + 0.5) / 128.0, (_AudioLinkDelay + 0.5) / 64.0); \
        float _alVol = LIL_SAMPLE_2D(_AudioTexture, sampler_linear_clamp, _alUV).r; \
        float _angleRad = (lerp(_MinAngle, _MaxAngle, _alVol) + _AngleOffset) * (LIL_PI / 180.0); \
        float _sinA, _cosA; \
        sincos(_angleRad, _sinA, _cosA); \
        float2 _effectivePivot = _Pivot.xy + _PivotOffset.xy; \
        float2 _shiftedUV = fd.uvMain - _effectivePivot; \
        float2 _rotUV; \
        _rotUV.x = _shiftedUV.x * _cosA - _shiftedUV.y * _sinA; \
        _rotUV.y = _shiftedUV.x * _sinA + _shiftedUV.y * _cosA; \
        _rotUV += _effectivePivot; \
        fd.col.a *= LIL_SAMPLE_2D(_NeedleTex, sampler_linear_clamp, _rotUV).r; \
    }

#define BEFORE_EMISSION_1ST \
    { \
        float2 _alUV2 = float2((_AudioLinkBand + 0.5) / 128.0, (_AudioLinkDelay + 0.5) / 64.0); \
        float _alVol2 = LIL_SAMPLE_2D(_AudioTexture, sampler_linear_clamp, _alUV2).r; \
        float _redFactor = smoothstep(_RedZoneThreshold, 1.0, _alVol2); \
        fd.emissionColor.rgb += _RedZoneColor.rgb * _redFactor; \
    }

#else

#define BEFORE_ALPHAMASK \
    { \
        float _alVol = 0.5 + 0.5 * sin(_Time.y); \
        float _angleRad = (lerp(_MinAngle, _MaxAngle, _alVol) + _AngleOffset) * (LIL_PI / 180.0); \
        float _sinA, _cosA; \
        sincos(_angleRad, _sinA, _cosA); \
        float2 _effectivePivot = _Pivot.xy + _PivotOffset.xy; \
        float2 _shiftedUV = fd.uvMain - _effectivePivot; \
        float2 _rotUV; \
        _rotUV.x = _shiftedUV.x * _cosA - _shiftedUV.y * _sinA; \
        _rotUV.y = _shiftedUV.x * _sinA + _shiftedUV.y * _cosA; \
        _rotUV += _effectivePivot; \
        fd.col.a *= LIL_SAMPLE_2D(_NeedleTex, sampler_linear_clamp, _rotUV).r; \
    }

#define BEFORE_EMISSION_1ST \
    { \
        float _alVol2 = 0.5 + 0.5 * sin(_Time.y); \
        float _redFactor = smoothstep(_RedZoneThreshold, 1.0, _alVol2); \
        fd.emissionColor.rgb += _RedZoneColor.rgb * _redFactor; \
    }

#endif

//----------------------------------------------------------------------------------------------------------------------
// Information about variables
//----------------------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// Vertex shader inputs (appdata structure)
//
// Type     Name                    Description
// -------- ----------------------- --------------------------------------------------------------------
// float4   input.positionOS        POSITION
// float2   input.uv0               TEXCOORD0
// float2   input.uv1               TEXCOORD1
// float2   input.uv2               TEXCOORD2
// float2   input.uv3               TEXCOORD3
// float2   input.uv4               TEXCOORD4
// float2   input.uv5               TEXCOORD5
// float2   input.uv6               TEXCOORD6
// float2   input.uv7               TEXCOORD7
// float4   input.color             COLOR
// float3   input.normalOS          NORMAL
// float4   input.tangentOS         TANGENT
// uint     vertexID                SV_VertexID

//----------------------------------------------------------------------------------------------------------------------
// Vertex shader outputs or pixel shader inputs (v2f structure)
//
// The structure depends on the pass.
// Please check lil_pass_xx.hlsl for details.
//
// Type     Name                    Description
// -------- ----------------------- --------------------------------------------------------------------
// float4   output.positionCS       SV_POSITION
// float2   output.uv01             TEXCOORD0 TEXCOORD1
// float2   output.uv23             TEXCOORD2 TEXCOORD3
// float3   output.positionOS       object space position
// float3   output.positionWS       world space position
// float3   output.normalWS         world space normal
// float4   output.tangentWS        world space tangent

//----------------------------------------------------------------------------------------------------------------------
// Variables commonly used in the forward pass
//
// These are members of `lilFragData fd`
//
// Type     Name                    Description
// -------- ----------------------- --------------------------------------------------------------------
// float4   col                     lit color
// float3   albedo                  unlit color
// float3   emissionColor           color of emission
// -------- ----------------------- --------------------------------------------------------------------
// float3   lightColor              color of light
// float3   indLightColor           color of indirectional light
// float3   addLightColor           color of additional light
// float    attenuation             attenuation of light
// float3   invLighting             saturate((1.0 - lightColor) * sqrt(lightColor));
// -------- ----------------------- --------------------------------------------------------------------
// float2   uv0                     TEXCOORD0
// float2   uv1                     TEXCOORD1
// float2   uv2                     TEXCOORD2
// float2   uv3                     TEXCOORD3
// float2   uvMain                  Main UV
// float2   uvMat                   MatCap UV
// float2   uvRim                   Rim Light UV
// float2   uvPanorama              Panorama UV
// float2   uvScn                   Screen UV
// bool     isRightHand             input.tangentWS.w > 0.0;
// -------- ----------------------- --------------------------------------------------------------------
// float3   positionOS              object space position
// float3   positionWS              world space position
// float4   positionCS              clip space position
// float4   positionSS              screen space position
// float    depth                   distance from camera
// -------- ----------------------- --------------------------------------------------------------------
// float3x3 TBN                     tangent / bitangent / normal matrix
// float3   T                       tangent direction
// float3   B                       bitangent direction
// float3   N                       normal direction
// float3   V                       view direction
// float3   L                       light direction
// float3   origN                   normal direction without normal map
// float3   origL                   light direction without sh light
// float3   headV                   middle view direction of 2 cameras
// float3   reflectionN             normal direction for reflection
// float3   matcapN                 normal direction for reflection for MatCap
// float3   matcap2ndN              normal direction for reflection for MatCap 2nd
// float    facing                  VFACE
// -------- ----------------------- --------------------------------------------------------------------
// float    vl                      dot(viewDirection, lightDirection);
// float    hl                      dot(headDirection, lightDirection);
// float    ln                      dot(lightDirection, normalDirection);
// float    nv                      saturate(dot(normalDirection, viewDirection));
// float    nvabs                   abs(dot(normalDirection, viewDirection));
// -------- ----------------------- --------------------------------------------------------------------
// float4   triMask                 TriMask (for lite version)
// float3   parallaxViewDirection   mul(tbnWS, viewDirection);
// float2   parallaxOffset          parallaxViewDirection.xy / (parallaxViewDirection.z+0.5);
// float    anisotropy              strength of anisotropy
// float    smoothness              smoothness
// float    roughness               roughness
// float    perceptualRoughness     perceptual roughness
// float    shadowmix               this variable is 0 in the shadow area
// float    audioLinkValue          volume acquired by AudioLink
// -------- ----------------------- --------------------------------------------------------------------
// uint     renderingLayers         light layer of object (for URP / HDRP)
// uint     featureFlags            feature flags (for HDRP)
// uint2    tileIndex               tile index (for HDRP)
