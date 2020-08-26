Shader "Unlit/Degrade"
{
	Properties
	{
		_ColorA("ColorA", Color) = (1, 1, 1, 0)
		_ColorB("ColorB", Color) = (1, 1, 1, 0)

		_InvLerpA("InvLerpA", Range(0, 1)) = 1
		_InvLerpB("InvLerpB", Range(0, 1)) = 1
		_SmoothStep("Smooth Step", Range(0, 1)) = 1

		_Step("Step", Range(0, 1)) = 1
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
				float2 uv0 : TEXCOORD0;
			};

			struct VertexOutput
			{
				float4 clipSpacePosition : SV_POSITION;
				float2 uv0 : TEXCOORD0;
			};

			float4 _ColorA;
			float4 _ColorB;

			float _InvLerpA;
			float _InvLerpB;
			float _SmoothStep;
			float _Step;

			// Vertex Shader
			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				o.uv0 = v.uv0;
				o.clipSpacePosition = UnityObjectToClipPos(v.vertex);
				return o;
			}

			// value = lerp(a, b, t)
			float3 MyLerp(float3 a, float3 b, float t) {
				return t * b + (1 - t) * a;
			}

			// t = invLerp(a, b, value)
			float MyInvLerp(float a, float b, float value) {
				return (value - a) / (b - a);
			}

			float4 frag(VertexOutput o) : SV_Target
			{
				float2 uv = o.uv0;
				float t = uv.y;

				if (_InvLerpA && _InvLerpB) {
					if (_SmoothStep)
						t = smoothstep(_InvLerpA, _InvLerpB, t);
					else
						t = MyInvLerp(_InvLerpA, _InvLerpB, t);
				}
				else if (_Step)
					t = step(_Step, t);

				float3 blend = MyLerp(_ColorA, _ColorB, t);
				

				return float4(blend, 0);
			}
			ENDCG
		}
	}
}
