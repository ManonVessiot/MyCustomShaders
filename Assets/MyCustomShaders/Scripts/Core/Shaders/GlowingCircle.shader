Shader "Custom/GlowingCircle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)

		_RippleDistance("Ripple Distance", Float) = 0
		_RippleWidth("Ripple Width", Float) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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
				float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
			float4 _Color;

			float _RippleDistance;
			float _RippleWidth;

			uniform float4 _RippleOrigin;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

			float4 frag (v2f i) : SV_Target
            {
				float distance = length(i.worldPos.xz - _RippleOrigin.xz) - _RippleDistance;
				float halfWidth = _RippleWidth * 0.5;

				float ringStrength = pow(max(0, (halfWidth - abs(distance)) / halfWidth), 8);

                // sample the texture
				float4 col = tex2D(_MainTex, i.uv) * _Color * ringStrength;

                return col;
            }
            ENDCG
        }
    }
}
