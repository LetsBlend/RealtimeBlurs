Shader "Hidden/PPBokehBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Strength("Strength", float) = 1
        _StarStrength("Star Blur Strength", float) = 1
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // Circular Kernel from GPU Zen 'Practical Gather-based Bokeh Depth of Field' by Wojciech Sterna
            static const float2 roundOffsets[] =
            {
                2.0f * float2(1.000000f, 0.000000f),
                2.0f * float2(0.707107f, 0.707107f),
                2.0f * float2(-0.000000f, 1.000000f),
                2.0f * float2(-0.707107f, 0.707107f),
                2.0f * float2(-1.000000f, -0.000000f),
                2.0f * float2(-0.707106f, -0.707107f),
                2.0f * float2(0.000000f, -1.000000f),
                2.0f * float2(0.707107f, -0.707107f),
                
                4.0f * float2(1.000000f, 0.000000f),
                4.0f * float2(0.923880f, 0.382683f),
                4.0f * float2(0.707107f, 0.707107f),
                4.0f * float2(0.382683f, 0.923880f),
                4.0f * float2(-0.000000f, 1.000000f),
                4.0f * float2(-0.382684f, 0.923879f),
                4.0f * float2(-0.707107f, 0.707107f),
                4.0f * float2(-0.923880f, 0.382683f),
                4.0f * float2(-1.000000f, -0.000000f),
                4.0f * float2(-0.923879f, -0.382684f),
                4.0f * float2(-0.707106f, -0.707107f),
                4.0f * float2(-0.382683f, -0.923880f),
                4.0f * float2(0.000000f, -1.000000f),
                4.0f * float2(0.382684f, -0.923879f),
                4.0f * float2(0.707107f, -0.707107f),
                4.0f * float2(0.923880f, -0.382683f),

                6.0f * float2(1.000000f, 0.000000f),
                6.0f * float2(0.965926f, 0.258819f),
                6.0f * float2(0.866025f, 0.500000f),
                6.0f * float2(0.707107f, 0.707107f),
                6.0f * float2(0.500000f, 0.866026f),
                6.0f * float2(0.258819f, 0.965926f),
                6.0f * float2(-0.000000f, 1.000000f),
                6.0f * float2(-0.258819f, 0.965926f),
                6.0f * float2(-0.500000f, 0.866025f),
                6.0f * float2(-0.707107f, 0.707107f),
                6.0f * float2(-0.866026f, 0.500000f),
                6.0f * float2(-0.965926f, 0.258819f),
                6.0f * float2(-1.000000f, -0.000000f),
                6.0f * float2(-0.965926f, -0.258820f),
                6.0f * float2(-0.866025f, -0.500000f),
                6.0f * float2(-0.707106f, -0.707107f),
                6.0f * float2(-0.499999f, -0.866026f),
                6.0f * float2(-0.258819f, -0.965926f),
                6.0f * float2(0.000000f, -1.000000f),
                6.0f * float2(0.258819f, -0.965926f),
                6.0f * float2(0.500000f, -0.866025f),
                6.0f * float2(0.707107f, -0.707107f),
                6.0f * float2(0.866026f, -0.499999f),
                6.0f * float2(0.965926f, -0.258818f),
            };

            static const float2 triangleOffsets[] =
            {
                2 *float2(0.0,   0.4  ), 
                2 *float2( 0.15,  0.37), 
                2 *float2( 0.29,  0.29), 
                2 *float2(-0.37,  0.15), 
                2 *float2( 0.40,  0.0 ), 
                2 *float2( 0.37, -0.15), 
                2 *float2( 0.29, -0.29), 
                2 *float2(-0.15, -0.37), 
                2 *float2( 0.0,  -0.4 ), 
                2 *float2(-0.15,  0.37), 
                2 *float2(-0.29,  0.29), 
                2 *float2( 0.37,  0.15), 
                2 *float2(-0.4,   0.0 ), 
                2 *float2(-0.37, -0.15), 
                2 *float2(-0.29, -0.29), 
                2 *float2( 0.15, -0.37), 

                4 *float2( 0.15,  0.37), 
                4 *float2(-0.37,  0.15), 
                4 *float2( 0.37, -0.15), 
                4 *float2(-0.15, -0.37), 
                4 *float2(-0.15,  0.37), 
                4 *float2( 0.37,  0.15), 
                4 *float2(-0.37, -0.15), 
                4 *float2( 0.15, -0.37), 

                6 *float2( 0.29,  0.29), 
                6 *float2( 0.40,  0.0 ), 
                6 *float2( 0.29, -0.29), 
                6 *float2( 0.0,  -0.4 ), 
                6 *float2(-0.29,  0.29), 
                6 *float2(-0.4,   0.0 ), 
                6 *float2(-0.29, -0.29), 
                6 *float2( 0.0,   0.4 ), 
                
                8 *float2(0.29,  0.29 ),
                8 *float2( 0.4,   0.0 ), 
                8 *float2( 0.29, -0.29), 
                8 *float2( 0.0,  -0.4 ), 
                8 *float2(-0.29,  0.29), 
                8 *float2(-0.4,   0.0 ), 
                8 *float2(-0.29, -0.29), 
                8 *float2( 0.0,   0.4 )
            };

            sampler2D _MainTex;
            float _Strength;
            float _StarStrength;
            int _BokehType;

            fixed4 frag (v2f i) : SV_Target
            {
                float4 color = tex2D(_MainTex, i.uv);
                int size = _BokehType == 1 ? 39 : 40;
                [unroll]
                for(int j = 0; j < size; j++)
                {
                    float2 offset = (_BokehType == 1 ? triangleOffsets[j] : roundOffsets[j]) * _ScreenParams.yx / _ScreenParams.x;
                    color += tex2D(_MainTex, i.uv + offset / (_BokehType == 1 ? _StarStrength : _Strength));
                }
                fixed4 finalColor = color / size;
                return finalColor;  
            }
            ENDCG
        }
    }
}
