Shader "Unlit/ShieldShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Blend One One
		ZWrite Off
		Cull Off

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
				float2 screenuv : TEXCOORD1;
				float depth : TEXCOORD2;
				
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			sampler2D _CameraDepthNormalsTexture;
			
			v2f vert (appdata v)
			{
			
			    v2f o;
			    o.vertex = UnityObjectToClipPos (v.vertex);
			    o.uv = 

			    o.screenuv = ((o.vertex.xy / o.vertex.w) + 1) / 2;
			    o.screenuv.y = 1 - o.screenuv.y;
			    
			    o.depth = -mul(UNITY_MATRIX_MV, v.vertex).z * _ProjectionParams.w;
			   
			    return o;
				
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

                float3 normalValues;
                float screenDepth;

			    // unpack the depth from the depth texture
			    DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.screenuv), screenDepth, normalValues);

			    // find the distance between screen depth and fragment depth
			    float diff = screenDepth - i.depth;
			    
			    float intersect = 0;
			    
			    if (diff > 0) {
			        // _ProjectionParams.w = 1 / far plane
			        intersect = 1 - smoothstep(0, _ProjectionParams.w * 0.3, diff);
			    }
                
                fixed4 sweetColor = fixed4(lerp(_Color.rgb, fixed3(1,1,1), pow(intersect, 2)), 1);

			    fixed4 col = sweetColor * _Color.a + intersect;
				return col;
				
			}
			ENDCG
		}
	}
}
