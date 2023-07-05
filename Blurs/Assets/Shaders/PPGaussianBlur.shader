Shader "Hidden/PPGaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NumSamples("Sample Count", int) = 10
        _Strength("Strength", float) = 600
        _StandartDev("StandartDeviation", Range(0, .1)) = .02
        _DifferenceGaussians("Difference of Gaussians", int) = 0
        _DiffStrength("Strength", float) = 6000
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

            #define PI 3.14159265359
            #define E 2.71828182846

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
            float _StandartDev;
            int _DifferenceGaussians;
            float _DiffStrength;

            fixed4 frag (v2f i) : SV_Target
            {
                float strength = _DifferenceGaussians >= 1 ? _DiffStrength : _Strength;
                float4 col = tex2D(_MainTex, i.uv);
                float4 color = tex2D(_MainTex, i.uv);
                float sum = 0;

                for(int s = -_NumSamples; s <= _NumSamples; s++)
                {
                    for(int j = -_NumSamples; j <= _NumSamples; j++)
                    {
                        float2 offset = float2(s, j) / strength;

                        float stDevSquared = _StandartDev * _StandartDev;
                        float gauss = (1 / sqrt(2 * PI * stDevSquared)) * pow(E, -(length(offset * offset)/(2 * stDevSquared)));

                        sum += gauss;
                        color += tex2D(_MainTex, i.uv + offset) * gauss;
                    }
                }
                fixed4 finalColor = color / sum;
                if(_DifferenceGaussians < 1)
                return finalColor;

                color = tex2D(_MainTex, i.uv);
                sum = 0;

                for(int s = -_NumSamples; s <= _NumSamples; s++)
                {
                    for(int j = -_NumSamples; j <= _NumSamples; j++)
                    {
                        float2 offset = float2(s, j) / (strength * 1.01f);

                        float stDevSquared = _StandartDev * _StandartDev;
                        float gauss = (1 / sqrt(2 * PI * stDevSquared)) * pow(E, -((offset * offset)/(2 * stDevSquared)));

                        sum += gauss;
                        color += tex2D(_MainTex, i.uv + offset) * gauss;
                    }
                }
                fixed4 finalColor1 = color / sum;
                
                return col - (finalColor - finalColor1) * 300;
            }
            ENDCG
        }
    }
}
