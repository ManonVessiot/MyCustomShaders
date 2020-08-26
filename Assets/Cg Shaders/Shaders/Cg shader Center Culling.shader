Shader "Cg shader Center Culling" { // defines the name of the shader
	Properties{
		_DistanceNear("Distance", Float) = 5.0
		_FrontColor("Front Color", Color) = (0.3, 0.3, 0.3, 1.0)
		_BackColorIntensity("Back Color Intensity", Range(0.0, 1.0)) = 0.5
		_AlphaForHole("Alpha for the hole", Range(0.0, 1.0)) = 0.5
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
			
			float _DistanceNear;
			float4 _FrontColor;

			struct vertexInput {
				float4 vertex : POSITION;
			};
			struct vertexOutput {
				float4 position : SV_POSITION;
				float4 posObj : TEXCOORD0;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				output.position = UnityObjectToClipPos(input.vertex);
				output.posObj = input.vertex;
				return output;
			}

			float4 frag(vertexOutput input) : SV_Target
			{
				float dist = length(input.posObj);

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

			float _DistanceNear;
			float _BackColorIntensity;

			struct vertexInput {
				float4 vertex : POSITION;
			};
			struct vertexOutput {
				float4 position : SV_POSITION;
				float4 posObj : TEXCOORD0;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				output.position = UnityObjectToClipPos(input.vertex);
				output.posObj = input.vertex;
				return output;
			}

			float4 frag(vertexOutput input) : SV_Target
			{
				float dist = length(input.posObj);

				if (dist < _DistanceNear) {
					discard;
				}

				float4 color = clamp((dist - _DistanceNear) * 100, 0.0, 1.0) * input.posObj;

				float toAdd = _BackColorIntensity - max(max(color.x, color.y), color.z);

				return clamp(color + toAdd, 0.0, 1.0);
			}
			ENDCG
		}
		
		Tags { "Queue" = "Transparent" }
		// draw after all opaque geometry has been drawn
		
        Pass
        {
			Cull Back

			ZWrite Off // don't write to depth buffer 
			// in order not to occlude other objects
			
			Blend SrcAlpha OneMinusSrcAlpha // use alpha blending
			
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

			float _DistanceNear;
			float _AlphaForHole;

			struct vertexInput {
				float4 vertex : POSITION;
			};
			struct vertexOutput {
				float4 position : SV_POSITION;
				float4 posObj : TEXCOORD0;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				output.position = UnityObjectToClipPos(input.vertex);
				output.posObj = input.vertex;
				return output;
			}

			float4 frag(vertexOutput input) : SV_Target
			{
				float dist = length(input.posObj);

				if (dist >= _DistanceNear) {
					discard;
				}
				return float4(1.0, 1.0, 1.0, _AlphaForHole);
				 // the fourth component (alpha) is important: 
				 // this is semitransparent green
			}
            ENDCG
        }
	}
}