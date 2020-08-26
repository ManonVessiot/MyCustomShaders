Shader "Unlit/Water"
{
	Properties
	{
		_WaveShallow("WaveShallow", Color) = (1, 1, 1, 0)
		_WaveDeep("WaveDeep", Color) = (1, 1, 1, 0)
		_WaveColor("WaveColor", Color) = (1, 1, 1, 0)

		_ShorelineTex("Shoreline", 2D) = "black" {}
		_WaveSize("WaveSize", Range(0, 1)) = 0.04
		_WaveSpeed("WaveSpeed", Float) = 2
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

				// float4 color : COLOR;
				// float4 tangent : TANGENT;
			};

			struct VertexOutput
			{
				float4 clipSpacePosition : SV_POSITION;
				float2 uv0 : TEXCOORD0;
			};

			sampler2D _ShorelineTex;
			float _WaveSize;

			float4 _WaveShallow;
			float4 _WaveDeep;
			float4 _WaveColor;
			float _WaveSpeed;

			// Vertex Shader
			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				o.uv0 = v.uv0;
				o.clipSpacePosition = UnityObjectToClipPos(v.vertex);
				return o;
			}

			float4 frag(VertexOutput o) : SV_Target
			{
				float shoreline = tex2D(_ShorelineTex, o.uv0).x;
				float shape = shoreline;


				float waveAmp = (sin(shape / _WaveSize + _Time.y * _WaveSpeed) + 1) * 0.5;
				waveAmp *= shoreline;

				float3 waterColor = lerp(_WaveDeep, _WaveShallow, shoreline);
				float3 waterWithWaves = lerp(waterColor, _WaveColor, waveAmp);

				return float4(waterWithWaves, 0);
			}
			ENDCG
		}
	}
}
