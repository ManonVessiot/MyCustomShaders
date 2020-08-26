Shader "Unlit/Cg shader using blending"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_ColorFront("Front Color", Color) = (0.5, 0.5, 0.5, 0.5)
		_ColorBack("Back Color", Color) = (0.5, 0.5, 0.5, 0.5)
    }
    SubShader
    {
		Tags { "Queue" = "Transparent" }
		// draw after all opaque geometry has been drawn
		
        Pass
        {
			Cull Front // first pass renders only back faces 
			 // (the "inside")

			ZWrite Off // don't write to depth buffer 
			// in order not to occlude other objects
			
			Blend SrcAlpha OneMinusSrcAlpha // use alpha blending
			
			
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

			float4 _ColorFront;

			float4 vert(float4 vertexPos : POSITION) : SV_POSITION
			{
				return UnityObjectToClipPos(vertexPos);
			}

			float4 frag(void) : COLOR
			{
				return _ColorFront;
			}
            ENDCG
        }
		Pass
		{
			Cull Back  // first pass renders only back faces 
			 // (the "inside")

			ZWrite Off // don't write to depth buffer 
			// in order not to occlude other objects

			Blend SrcAlpha OneMinusSrcAlpha // use alpha blending


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			
			float4 _ColorBack;

			float4 vert(float4 vertexPos : POSITION) : SV_POSITION
			{
				return UnityObjectToClipPos(vertexPos);
			}

			float4 frag(void) : COLOR
			{
				return _ColorBack;
			}
			ENDCG
		}
    }
}
