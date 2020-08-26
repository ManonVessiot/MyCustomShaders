Shader "Cg shader Culling" { // defines the name of the shader
	Properties{
		_Point("Point", Vector) = (0.0, 0.0, 0.0, 1.0)
		_DistanceNear("Distance", Float) = 5.0
		_FrontColor("Front Color", Color) = (0.3, 0.3, 0.3, 1.0)
		_BackColorIntensity("Back Color Intensity", Range(0.0, 1.0)) = 0.5
	}
	SubShader{ // Unity chooses the subshader that fits the GPU best
		Pass { // some shaders require multiple passes

			Cull Front  // turn off triangle culling, alternatives are:
			// Cull Back (or nothing): cull only back faces 
			// Cull Front : cull only front faces

			CGPROGRAM // here begins the part in Unity's Cg

			#pragma vertex vert // this specifies the vert function as the vertex shader
			#pragma fragment frag // this specifies the frag function as the fragment shader

			#include "UnityCG.cginc"

			float4 _Point;
			float _DistanceNear;
			float4 _FrontColor;

			struct vertexInput {
				float4 vertex : POSITION;
			};
			struct vertexOutput {
				float4 position : SV_POSITION;
				float4 posObj : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				output.position = UnityObjectToClipPos(input.vertex);
				output.posObj = input.vertex;
				output.posWorld  = mul(unity_ObjectToWorld, input.vertex);
				return output;
			}

			float4 frag(vertexOutput input) : SV_Target
			{
				float dist = length(_Point - input.posWorld);//distance(_Point, input.posWorld);

				if (dist < _DistanceNear) {
					discard;
				}
				return _FrontColor;
			}
				

			ENDCG
		}


		// second pass (is executed after the first pass)
		Pass {
		   Cull Back // cull only back faces

		   CGPROGRAM // here begins the part in Unity's Cg

			#pragma vertex vert // this specifies the vert function as the vertex shader
			#pragma fragment frag // this specifies the frag function as the fragment shader

			#include "UnityCG.cginc"

			float4 _Point;
			float _DistanceNear;
			float _BackColorIntensity;

			struct vertexInput {
				float4 vertex : POSITION;
			};
			struct vertexOutput {
				float4 position : SV_POSITION;
				float4 posObj : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				output.position = UnityObjectToClipPos(input.vertex);
				output.posObj = input.vertex;
				output.posWorld = mul(unity_ObjectToWorld, input.vertex);
				return output;
			}

			float4 frag(vertexOutput input) : SV_Target
			{
				float dist = length(_Point - input.posWorld);

				if (dist < _DistanceNear) {
					discard;
				}

				float4 color = clamp((dist - _DistanceNear) * 100, 0.0, 1.0) * input.posWorld;

				float toAdd = _BackColorIntensity - max(max(color.x, color.y), color.z);

				return clamp(color + toAdd, 0.0, 1.0);
			}


			ENDCG
		}
	}
}