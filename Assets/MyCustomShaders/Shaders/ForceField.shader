Shader "Unlit/ForceField"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)


		_Transparency("Transparency", Range(0, 5)) = 2
	}
		SubShader
		{
			Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
			LOD 100

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float4 clipSpacePosition : SV_POSITION;
					float2 uv : TEXCOORD0;
					float3 normal : TEXCOORD1;
					float3 worldPos : TEXCOORD2;
				};

				sampler2D _MainTex;

				float4 _Color;
				float _Transparency;

				v2f vert(appdata v)
				{
					v2f o;
					o.uv = v.uv;
					o.normal = v.normal;
					o.worldPos = mul(unity_ObjectToWorld, v.vertex);
					o.clipSpacePosition = UnityObjectToClipPos(v.vertex);
					return o;
				}

				fixed4 frag(v2f o) : SV_Target
				{
					// sample the texture
					fixed4 col = tex2D(_MainTex, o.uv) + _Color;

					float3 normal = normalize(o.normal); // o.normal interpolited
					float3 worldPos = o.worldPos;

					float3 camPos = _WorldSpaceCameraPos;
					float3 fragToCam = camPos - worldPos;
					float3 viewDir = normalize(fragToCam);

					float viewDotNormal = max(0, dot(viewDir, normal));

					//return float4(viewDotNormal.xxx, 1);

					col.a = max(0, 1 - viewDotNormal * _Transparency);

					return col;
				}
				ENDCG
			}
		}
}
