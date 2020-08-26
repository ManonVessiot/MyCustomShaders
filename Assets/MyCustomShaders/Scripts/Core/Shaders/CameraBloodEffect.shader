Shader "Custom/CameraBloodEffect"
{
    Properties
    {
		_MainTex("Texture", 2D) = "white" {}
		_ColorMask("Color Mask", Color) = (1, 1, 1, 1)

		_CircleDistance("Circle Distance", Float) = 0.1
		_HeightOfLife("Height Of Life", Range(0, 1)) = 0.1
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
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

			sampler2D _MainTex;
			float4 _ColorMask;

			int _displayMaskCamera;
			float _CircleDistance;

			float _percentOfLife;
			float _HeightOfLife;


            float4 frag (v2f i) : SV_Target
            {
				float4 col = tex2D(_MainTex, i.uv);


				if (i.vertex.x * 100 / _ScreenParams.x < _percentOfLife && i.vertex.y > _ScreenParams.y * (1- _HeightOfLife)) {
					col = _ColorMask;
				}
				else {
					float distance = length(i.vertex.xy - _ScreenParams.xy / 2) / length(_ScreenParams.xy);
					distance -= _CircleDistance;

					col = tex2D(_MainTex, i.uv) + _displayMaskCamera * _ColorMask * distance;
				}
				

                return col;
            }
            ENDCG
        }
    }
}
