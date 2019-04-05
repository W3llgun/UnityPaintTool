// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PixelUnlitAmplify"
{
	Properties
	{
		_Texture0("Texture 0", 2D) = "white" {}
		_Float2("Float 2", Range( 0 , 1)) = 0.3663589
		_Vector0("Vector 0", Vector) = (0,0,0,0)
		_Int1("Int 1", Int) = 10
		[Toggle]_ToggleSwitch0("Toggle Switch0", Float) = 0
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
		LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
			};

			uniform float _ToggleSwitch0;
			uniform sampler2D _Texture0;
			uniform float2 _Vector0;
			uniform int _Int1;
			uniform float _Float2;
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				float3 vertexValue =  float3(0,0,0) ;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				fixed4 finalColor;
				float2 uv4 = i.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult34 = (float2(( uv4.x + _Vector0.x ) , ( uv4.y + _Vector0.y )));
				float pixelWidth5 =  1.0f / (float)_Int1;
				float pixelHeight5 = 1.0f / (float)_Int1;
				half2 pixelateduv5 = half2((int)(appendResult34.x / pixelWidth5) * pixelWidth5, (int)(appendResult34.y / pixelHeight5) * pixelHeight5);
				float4 tex2DNode21 = tex2D( _Texture0, pixelateduv5 );
				float grayscale22 = Luminance(tex2DNode21.rgb);
				float4 color27 = IsGammaSpace() ? float4(0,0.7215686,0,0) : float4(0,0.4793201,0,0);
				float4 color26 = IsGammaSpace() ? float4(1,0,0,0) : float4(1,0,0,0);
				
				
				finalColor = lerp(tex2DNode21,(( grayscale22 >= _Float2 ) ? color27 :  color26 ),_ToggleSwitch0);
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16301
2028;41;1906;975;1986.716;772.0382;1.678724;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-921.3907,-412.9084;Float;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;41;-1033.041,-140.1455;Float;False;Property;_Vector0;Vector 0;2;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-566.7816,-77.59137;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-570.9818,-241.5912;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;34;-399.6816,-164.1913;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.IntNode;43;-774.3984,224.7155;Float;False;Property;_Int1;Int 1;3;0;Create;True;0;0;False;0;10;1000;0;1;INT;0
Node;AmplifyShaderEditor.TexturePropertyNode;12;-855.1777,-634.1823;Float;True;Property;_Texture0;Texture 0;0;0;Create;True;0;0;False;0;d01457b88b1c5174ea4235d140b5fab8;bb1073e522b018b4e83ea5bca6df8079;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TFHCPixelate;5;-276.3196,88.5;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;21;3.200783,-658.6417;Float;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;27;449.1454,-196.4692;Float;False;Constant;_Color1;Color 1;3;0;Create;True;0;0;False;0;0,0.7215686,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCGrayscale;22;495.3008,-529.2473;Float;True;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;26;456.2967,-9.453153;Float;False;Constant;_Color0;Color 0;3;0;Create;True;0;0;False;0;1,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;24;368.2969,-294.8223;Float;False;Property;_Float2;Float 2;1;0;Create;True;0;0;False;0;0.3663589;0.668;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareGreaterEqual;42;733.959,-488.7455;Float;False;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;46;954.8251,-686.7181;Float;False;Property;_ToggleSwitch0;Toggle Switch0;4;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;1261.766,-619.7501;Float;False;True;2;Float;ASEMaterialInspector;0;1;PixelUnlitAmplify;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;True;0;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;35;0;4;2
WireConnection;35;1;41;2
WireConnection;32;0;4;1
WireConnection;32;1;41;1
WireConnection;34;0;32;0
WireConnection;34;1;35;0
WireConnection;5;0;34;0
WireConnection;5;1;43;0
WireConnection;5;2;43;0
WireConnection;21;0;12;0
WireConnection;21;1;5;0
WireConnection;22;0;21;0
WireConnection;42;0;22;0
WireConnection;42;1;24;0
WireConnection;42;2;27;0
WireConnection;42;3;26;0
WireConnection;46;0;21;0
WireConnection;46;1;42;0
WireConnection;3;0;46;0
ASEEND*/
//CHKSM=7EEA7ABA66B6BCB7F210D950B82F064BC48D8D98