Shader "Unlit/SimpleShader"
{
    Properties
    {
		_Color("Color", Color) = (1, 1, 1, 0)
		_Gloss("Gloss", Float) = 1
		_Cartoon("Cartoon", Range(0, 1)) = 1

		//_MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			// Mesh data : position, normal, UV, tangents, colors
            struct VertexInput
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv0 : TEXCOORD0;

				// float4 color : COLOR;
				// float4 tangent : TANGENT;
            };

            struct VertexOutput
            {
                float4 clipSpacePosition : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
            };

            // sampler2D _MainTex;
            // float4 _MainTex_ST;

			float4 _Color;
			float _Gloss;
			bool _Cartoon;

			uniform float4 _MousePos;

			// Vertex Shader
			VertexOutput vert (VertexInput v)
            {
				VertexOutput o;
				o.uv0 = v.uv0;
				o.normal = v.normal;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.clipSpacePosition = UnityObjectToClipPos(v.vertex);
                return o;
            }

			// value = lerp(a, b, t)
			float3 MyLerp(float3 a, float3 b, float t) {
				return t * b + (1 - t) * a;
			}

			// t = invLerp(a, b, value)
			float MyInvLerp(float a, float b, float value) {
				return (value - a)/(b - a);
			}

			float Posterize(float steps, float value) {
				return floor(value * steps) / steps;
			}

			float4 frag (VertexOutput o) : SV_Target
            {

				float dist = distance(_MousePos, o.worldPos);


				//return dist;



				float3 normal = normalize(o.normal); // o.normal interpolited
				float3 worldPos = o.worldPos;


				// Lighting
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 lightColor = _LightColor0.rgb;

				// Direct diffuse light
				float lightFallOff = max(0, dot(lightDir, normal));
				if (_Cartoon)
					lightFallOff = step(0.1, lightFallOff); // Posterize(3, lightFallOff); // cartoon style

				float3 directDiffuseLight = lightColor * lightFallOff;

				// Ambient light
				float3 ambientLight = float3(0.2, 0.35, 0.4);

				// Direct specular light
				float3 camPos = _WorldSpaceCameraPos;
				float3 fragToCam = camPos - worldPos;
				float3 viewDir = normalize(fragToCam);
				float3 viewReflect = reflect(-viewDir, normal);
				float specularFallOff = max(0, dot(viewReflect, lightDir));
				specularFallOff = pow(specularFallOff, _Gloss); // Modify gloss
				if (_Cartoon)
					specularFallOff = step(0.1, specularFallOff); // Posterize(3, specularFallOff); // cartoon style

				float3 directSpecular = specularFallOff * lightColor;


				// Phong
				// Blinn-Phong


				// Composite
				float3 diffuseLight = ambientLight + directDiffuseLight;
				float3 finalSurfaceColor = diffuseLight = diffuseLight * _Color.rgb + directSpecular;



                return float4(finalSurfaceColor, 0);
            }
            ENDCG
        }
    }
}
