Shader "Hidden/PPMotionBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NumSamples("NumSamples", float) = 1
        _Speed("Speed (More is less blur!!!)", float) = 1
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
                float3 viewVector : TEXCOORD1;
                float3 prevViewVector : TEXCOORD2;
            };
            float4x4 _PreviousViewProjection;
            float4x4 _PreviousInvProjection;
            float4x4 _PreviousCameraToWorld;
            float4x4 _ViewProjection;
            float4x4 _InvViewProjection;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                float3 viewVector = mul(unity_CameraInvProjection, float4(v.uv * 2 - 1, 0, -1));
                o.viewVector = mul(unity_CameraToWorld, float4(viewVector,0));
                float3 prevViewVector = mul(_PreviousInvProjection, float4(v.uv * 2 - 1, 0, -1));
                o.prevViewVector = mul(_PreviousCameraToWorld, float4(prevViewVector,0));
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;

            float3 _PreviousWorldSpaceCameraPos;
            float _NumSamples;
            float _Speed;

            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewVector = normalize(i.viewVector);
                float3 prevViewVector = normalize(i.prevViewVector);
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);

                viewVector /= dot(viewVector, -UNITY_MATRIX_V[2].xyz);

                float3 pos = _WorldSpaceCameraPos + viewVector * depth;
                float3 prevPos = _PreviousWorldSpaceCameraPos + prevViewVector * depth;

                // Current viewport position    
                float3 viewPos = mul(_ViewProjection, float4(pos, 1));
                float3 prevViewPos =  mul(_PreviousViewProjection, float4(pos, 1));
                float2 velocity = viewPos - prevViewPos;
                float2 vel = velocity / _Speed;

                // Get the initial color at this pixel. 
                float2 uv = i.uv;   
                float4 color = tex2D(_MainTex, uv); 
                uv += vel;
                for(int i = 1; i < _NumSamples; i++, uv += vel) 
                {
                    // Sample the color buffer along the velocity vector.    
                    float4 currentColor = tex2D(_MainTex, uv);   
                    // Add the current color to our color sum.   
                    color += currentColor; 
                } 
                // Average all of the samples to get the final blur color.    
                float4 finalColor = color / _NumSamples;
                return finalColor;
            }
            ENDCG
        }
    }
}
