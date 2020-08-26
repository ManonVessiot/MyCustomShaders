Shader "Unlit/TrackMouse"
{
	Properties
	{
		_Color("Color", Color) = (1, 1, 1, 0)
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			// Mesh data : position, normal, UV, tangents, colors
			struct VertexInput
			{
				float4 vertex : POSITION;
			};

			struct VertexOutput
			{
				float4 clipSpacePosition : SV_POSITION;
				float3 worldPos : TEXCOORD2;
			};

			uniform float4 _MousePos;

			// Vertex Shader
			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.clipSpacePosition = UnityObjectToClipPos(v.vertex);
				return o;
			}

			float4 frag(VertexOutput o) : SV_Target
			{
				float dist = distance(_MousePos, o.worldPos);
				float glow = saturate(1 - dist);

				return glow;
			}
			ENDCG
		}
	}
}
