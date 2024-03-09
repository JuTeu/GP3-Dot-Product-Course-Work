Shader "Custom/Skybox" {
    Properties {
        _Tint ("Tint Color", Color) = (.5, .5, .5, .5)
        [Gamma] _Exposure ("Exposure", Range(0, 8)) = 1.0
        _Rotation ("Rotation", Range(0, 360)) = 0
        [NoScaleOffset] _MainTex ("Spherical  (HDR)", 2D) = "grey" {}
        [KeywordEnum(6 Frames Layout, Latitude Longitude Layout)] _Mapping("Mapping", Float) = 1
        [Enum(360 Degrees, 0, 180 Degrees, 1)] _ImageType("Image Type", Float) = 0
        [Toggle] _MirrorOnBack("Mirror on Back", Float) = 0
        [Enum(None, 0, Side by Side, 1, Over Under, 2)] _Layout("3D Layout", Float) = 0
    }
    
    SubShader {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
        Cull Off ZWrite Off
    
        Pass {
    
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
    
            #include "UnityCG.cginc"
    
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            half4 _MainTex_HDR;
            half4 _Tint;
            half _Exposure;
            float _Rotation;
    
            float3 RotateAroundYInDegrees (float3 vertex, float degrees)
            {
                float alpha = degrees * UNITY_PI / 180.0;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
                return float3(mul(m, vertex.xz), vertex.y).xzy;
            }
    
            struct appdata_t {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
    
            struct v2f {
                float4 vertex : SV_POSITION;
                float3 texcoord : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };
    
            v2f vert (appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                float3 rotated = RotateAroundYInDegrees(v.vertex, _Rotation);
                o.vertex = UnityObjectToClipPos(rotated);
                o.texcoord = v.vertex.xyz;
                return o;
            }
    
            fixed4 frag (v2f i) : SV_Target
            {
                float wave = 0.1 * sin(i.texcoord.x * 10) * sin(_Time.y);
                float warble = sin(-i.texcoord.z * i.texcoord.x * 7 + _Time.x);
                float warble2 = cos((i.texcoord.y + wave) * 10) * 0.4f;
                float plasma = sin(i.texcoord.x * 10 + _Time.z + warble2);
                plasma += sin((i.texcoord.y + wave) * 5 + _Time.y - warble);
                plasma += warble2;
                plasma += sin(-(i.texcoord.y + wave) * 10 + _Time.y + warble2 + 10);
                plasma += 0.3 * cos(i.texcoord.x - i.texcoord.y - _Time.z);
                float4 col = float4(-plasma, sin(plasma + _Time.y * 0.543) * 1.2, cos(plasma + _Time.w * 0.1234) + 0.8, 1);
                return col;
            }
            ENDCG
        }
    }
    
    
    CustomEditor "SkyboxPanoramicShaderGUI"
    Fallback Off
    
    }