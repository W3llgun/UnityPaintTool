Shader "Unlit/SimpleGridShader"
{
    Properties
    {
		_Size("Grid Size", Float) = 1
        _MainTex ("Texture", 2D) = "white" {}
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Size;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                // sample the texture
                //fixed4 col = 0;//tex2D(_MainTex, i.uv);
                //if(i.uv.x % _Size == 2)
                //{
                //    col.x = 1;
                //}
                //else
                //{
                //    col.y = 1;
                //}

                float2 steppedUV = i.uv;
                steppedUV /= _Size;
                steppedUV = round(steppedUV);
                steppedUV *= _Size;

                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return tex2D(_MainTex, steppedUV);
            }
            ENDCG
        }
    }
}
