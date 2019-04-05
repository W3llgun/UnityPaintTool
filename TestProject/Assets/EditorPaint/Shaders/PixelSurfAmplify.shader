// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PixelSurfAmplify"
{
	Properties
	{
		_mainTexture("mainTexture", 2D) = "white" {}
		_Tolerance("Tolerance", Range( 0 , 1)) = 0.3663589
		[Toggle]_PaintView("PaintView", Float) = 0
		_WorldPosOffset("World Pos Offset", Vector) = (0,0,0,0)
		_TexturesTiling("Textures Tiling", Range( 0 , 10)) = 0
		[Toggle(_WORLDSPACE_ON)] _WorldSpace("WorldSpace", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Overlay+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma shader_feature _WORLDSPACE_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float _PaintView;
		uniform sampler2D _mainTexture;
		uniform float4 _mainTexture_ST;
		uniform half2 _WorldPosOffset;
		uniform half _TexturesTiling;
		uniform float _Tolerance;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_mainTexture = i.uv_texcoord * _mainTexture_ST.xy + _mainTexture_ST.zw;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult30 = (float2(ase_worldPos.x , ase_worldPos.z));
			#ifdef _WORLDSPACE_ON
				float2 staticSwitch68 = appendResult30;
			#else
				float2 staticSwitch68 = uv_mainTexture;
			#endif
			float2 temp_output_40_0 = ( ( staticSwitch68 + _WorldPosOffset ) * _TexturesTiling * 0.001 );
			float4 tex2DNode11 = tex2D( _mainTexture, temp_output_40_0 );
			float grayscale13 = Luminance(tex2DNode11.rgb);
			float4 color12 = IsGammaSpace() ? float4(0,0.7215686,0,0) : float4(0,0.4793201,0,0);
			float4 color14 = IsGammaSpace() ? float4(1,0,0,0) : float4(1,0,0,0);
			o.Emission = lerp(tex2DNode11,(( grayscale13 >= _Tolerance ) ? color12 :  color14 ),_PaintView).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16301
2067;81;1906;960;1448.749;517.5541;1;True;True
Node;AmplifyShaderEditor.TexturePropertyNode;9;-2089.149,-576.274;Float;True;Property;_mainTexture;mainTexture;1;0;Create;True;0;0;False;0;d01457b88b1c5174ea4235d140b5fab8;bb1073e522b018b4e83ea5bca6df8079;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WorldPosInputsNode;29;-1946.517,64.78102;Float;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;30;-1661.655,74.59323;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-1751.576,-443.0412;Float;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;32;-1349.394,57.1586;Half;False;Property;_WorldPosOffset;World Pos Offset;5;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.StaticSwitch;68;-1265.117,-49.65601;Float;False;Property;_WorldSpace;WorldSpace;7;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-876.3101,48.1302;Half;False;Property;_TexturesTiling;Textures Tiling;6;0;Create;True;0;0;False;0;0;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-798.5845,141.9836;Float;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;False;0;0.001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-991.432,-32.80243;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-512.9716,-33.19844;Float;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;11;85.4538,-412.4701;Float;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;272.5628,-47.20356;Float;False;Property;_Tolerance;Tolerance;2;0;Create;True;0;0;False;0;0.3663589;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;14;360.5628,238.1655;Float;False;Constant;_Color0;Color 0;3;0;Create;True;0;0;False;0;1,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;12;353.4114,51.14956;Float;False;Constant;_Color1;Color 1;3;0;Create;True;0;0;False;0;0,0.7215686,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCGrayscale;13;399.5669,-281.6286;Float;True;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareGreaterEqual;16;691.225,-180.1268;Float;False;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;8;-622.6541,258.7816;Float;False;Property;_PixelSize;PixelSize;3;0;Create;True;0;0;False;0;10;30;0;1;INT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;17;822.7186,-509.7045;Float;False;Property;_PaintView;PaintView;4;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCPixelate;10;-205.2654,-44.70751;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;75;1323.845,-422.6399;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;PixelSurfAmplify;False;False;False;False;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;False;Opaque;;Overlay;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;30;0;29;1
WireConnection;30;1;29;3
WireConnection;3;2;9;0
WireConnection;68;1;3;0
WireConnection;68;0;30;0
WireConnection;31;0;68;0
WireConnection;31;1;32;0
WireConnection;40;0;31;0
WireConnection;40;1;39;0
WireConnection;40;2;56;0
WireConnection;11;0;9;0
WireConnection;11;1;40;0
WireConnection;13;0;11;0
WireConnection;16;0;13;0
WireConnection;16;1;15;0
WireConnection;16;2;12;0
WireConnection;16;3;14;0
WireConnection;17;0;11;0
WireConnection;17;1;16;0
WireConnection;10;0;40;0
WireConnection;10;1;8;0
WireConnection;10;2;8;0
WireConnection;75;2;17;0
ASEEND*/
//CHKSM=274AF7BC328CCFA1EA51E46D9EF5C2CC4F598E82