Shader "Hidden/PPBoxBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NumSamples("Sample Count", int) = 1
        _Strength("Strength", float) = 1
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

            sampler2D _MainTex;
            float _NumSamples;
            float _Strength;

            fixed4 frag (v2f i) : SV_Target
            {
                float4 color = tex2D(_MainTex, i.uv);

                for(int s = -_NumSamples; s <= _NumSamples; s++)
                {
                    for(int j = -_NumSamples; j <= _NumSamples; j++)
                    {
                        color += tex2D(_MainTex, i.uv + float2(s, j) / _Strength);
                    }
                }
                fixed4 finalColor = color / pow(_NumSamples * 2 + 1, 2);
                return finalColor;
            }
            ENDCG
        }
    }
}
