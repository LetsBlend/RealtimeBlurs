Shader "Hidden/PPRadialBlur"
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
                float2 vel = (float2(.5f, .5f) - i.uv) / _Strength;
                float2 uv = i.uv + vel;

                [unroll(_NumSamples)]
                for(int i = 0; i < _NumSamples; i++, uv += vel){
                    color += tex2D(_MainTex, uv);
                }
                fixed4 finalColor = color / _NumSamples;
                return finalColor;
            }
            ENDCG
        }
    }
}
