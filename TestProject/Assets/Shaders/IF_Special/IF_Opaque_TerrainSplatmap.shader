// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Immersive Factory/Opaque/Splat Terrain"
{
	Properties
	{
		_SplatMap("SplatMap", 2D) = "white" {}
		_FieldScale("Field Scale", Range( 0 , 0.03)) = 0
		[Toggle(_WORLDPOSITION_ON)] _WorldPosition("World Position", Float) = 0
		_WorldPosOffset("World Pos Offset", Vector) = (0,0,0,0)
		_TexturesTiling("Textures Tiling", Range( 0 , 1)) = 0
		_MetalnessMultiplier("Metalness Multiplier", Range( 0 , 1)) = 0
		[KeywordEnum(Layer1,Layer2,Layer3,Layer4)] _BaseLayerMaterial("Base Layer Material", Float) = 3
		_BaseLayerColorVariation("Base Layer Color Variation", Color) = (1,1,1,1)
		_Layer1AlbedoR("Layer 1 Albedo (R)", 2D) = "black" {}
		_Layer2AlbedoG("Layer 2 Albedo (G)", 2D) = "black" {}
		_Layer3AlbedoB("Layer 3 Albedo (B)", 2D) = "black" {}
		_Layer4AlbedoAlpha("Layer 4 Albedo (Alpha)", 2D) = "black" {}
		_BaseSmoothness("Base Smoothness", Range( 0 , 1)) = 0
		_Layer1SmoothnessR("Layer 1 Smoothness (R)", Range( 0 , 1)) = 0
		_Layer2SmoothnessG("Layer 2 Smoothness (G)", Range( 0 , 1)) = 0
		_Layer3SmoothnessB("Layer 3 Smoothness (B)", Range( 0 , 1)) = 0
		_Layer4SmoothnessAlpha("Layer 4 Smoothness (Alpha)", Range( 0 , 1)) = 0
		[Toggle(_NORMALMAPS_ON)] _NormalMaps("Normal Maps", Float) = 1
		_Layer1NormalR("Layer 1 Normal (R)", 2D) = "bump" {}
		_Layer2NormalG("Layer 2 Normal (G)", 2D) = "bump" {}
		_Layer3NormalB("Layer 3 Normal (B)", 2D) = "bump" {}
		_Layer4NormalA("Layer 4 Normal (A)", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0.1 , 10)) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 4.6
		#pragma shader_feature _NORMALMAPS_ON
		#pragma shader_feature _WORLDPOSITION_ON
		#pragma shader_feature _BASELAYERMATERIAL_LAYER1 _BASELAYERMATERIAL_LAYER2 _BASELAYERMATERIAL_LAYER3 _BASELAYERMATERIAL_LAYER4
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			half2 uv_texcoord;
			float3 worldPos;
		};

		uniform sampler2D _SplatMap;
		uniform half _FieldScale;
		uniform half2 _WorldPosOffset;
		uniform half _NormalScale;
		uniform sampler2D _Layer1NormalR;
		uniform half _TexturesTiling;
		uniform sampler2D _Layer2NormalG;
		uniform sampler2D _Layer3NormalB;
		uniform sampler2D _Layer4NormalA;
		uniform sampler2D _Layer1AlbedoR;
		uniform sampler2D _Layer2AlbedoG;
		uniform sampler2D _Layer3AlbedoB;
		uniform sampler2D _Layer4AlbedoAlpha;
		uniform half4 _BaseLayerColorVariation;
		uniform half _MetalnessMultiplier;
		uniform half _BaseSmoothness;
		uniform half _Layer1SmoothnessR;
		uniform half _Layer2SmoothnessG;
		uniform half _Layer3SmoothnessB;
		uniform half _Layer4SmoothnessAlpha;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float2 appendResult26 = (half2(ase_worldPos.x , ase_worldPos.z));
			#ifdef _WORLDPOSITION_ON
				float2 staticSwitch45 = ( _WorldPosOffset + appendResult26 );
			#else
				float2 staticSwitch45 = i.uv_texcoord;
			#endif
			half4 tex2DNode47 = tex2D( _SplatMap, ( _FieldScale * staticSwitch45 ) );
			half4 _Vector1 = half4(1,2,3,4);
			#if defined(_BASELAYERMATERIAL_LAYER1)
				float staticSwitch161 = _Vector1.x;
			#elif defined(_BASELAYERMATERIAL_LAYER2)
				float staticSwitch161 = _Vector1.y;
			#elif defined(_BASELAYERMATERIAL_LAYER3)
				float staticSwitch161 = _Vector1.z;
			#elif defined(_BASELAYERMATERIAL_LAYER4)
				float staticSwitch161 = _Vector1.w;
			#else
				float staticSwitch161 = _Vector1.w;
			#endif
			float2 temp_output_40_0 = ( staticSwitch45 * _TexturesTiling );
			half3 tex2DNode65 = UnpackScaleNormal( tex2D( _Layer1NormalR, temp_output_40_0 ), _NormalScale );
			half3 tex2DNode66 = UnpackScaleNormal( tex2D( _Layer2NormalG, temp_output_40_0 ), _NormalScale );
			half3 tex2DNode67 = UnpackScaleNormal( tex2D( _Layer3NormalB, temp_output_40_0 ), _NormalScale );
			half3 tex2DNode140 = UnpackScaleNormal( tex2D( _Layer4NormalA, temp_output_40_0 ), _NormalScale );
			float4 layeredBlendVar93 = tex2DNode47;
			float3 layeredBlend93 = ( lerp( lerp( lerp( lerp( (( staticSwitch161 == 1.0 ) ? tex2DNode65 :  (( staticSwitch161 == 2.0 ) ? tex2DNode66 :  (( staticSwitch161 == 3.0 ) ? tex2DNode67 :  (( staticSwitch161 == 4.0 ) ? tex2DNode140 :  float3( 0,0,0 ) ) ) ) ) , tex2DNode65 , layeredBlendVar93.x ) , tex2DNode66 , layeredBlendVar93.y ) , tex2DNode67 , layeredBlendVar93.z ) , tex2DNode140 , layeredBlendVar93.w ) );
			#ifdef _NORMALMAPS_ON
				float3 staticSwitch80 = layeredBlend93;
			#else
				float3 staticSwitch80 = half3(0,0,1);
			#endif
			o.Normal = staticSwitch80;
			half4 tex2DNode48 = tex2D( _Layer1AlbedoR, temp_output_40_0 );
			half4 tex2DNode50 = tex2D( _Layer2AlbedoG, temp_output_40_0 );
			half4 tex2DNode51 = tex2D( _Layer3AlbedoB, temp_output_40_0 );
			half4 tex2DNode139 = tex2D( _Layer4AlbedoAlpha, temp_output_40_0 );
			float4 layeredBlendVar92 = tex2DNode47;
			float4 layeredBlend92 = ( lerp( lerp( lerp( lerp( ( (( staticSwitch161 == 1.0 ) ? tex2DNode48 :  (( staticSwitch161 == 2.0 ) ? tex2DNode50 :  (( staticSwitch161 == 3.0 ) ? tex2DNode51 :  (( staticSwitch161 == 4.0 ) ? tex2DNode139 :  float4( 0,0,0,0 ) ) ) ) ) * _BaseLayerColorVariation ) , tex2DNode48 , layeredBlendVar92.x ) , tex2DNode50 , layeredBlendVar92.y ) , tex2DNode51 , layeredBlendVar92.z ) , tex2DNode139 , layeredBlendVar92.w ) );
			o.Albedo = layeredBlend92.rgb;
			o.Metallic = ( layeredBlend92.a * _MetalnessMultiplier );
			float4 layeredBlendVar109 = tex2DNode47;
			float layeredBlend109 = ( lerp( lerp( lerp( lerp( _BaseSmoothness , _Layer1SmoothnessR , layeredBlendVar109.x ) , _Layer2SmoothnessG , layeredBlendVar109.y ) , _Layer3SmoothnessB , layeredBlendVar109.z ) , _Layer4SmoothnessAlpha , layeredBlendVar109.w ) );
			o.Smoothness = layeredBlend109;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16200
-1913;1;1906;1010;2345.846;2819.547;1.883793;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;10;-2365.851,-1655.035;Float;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;26;-2029.897,-1617.027;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;87;-2141.096,-1933.505;Half;False;Property;_WorldPosOffset;World Pos Offset;3;0;Create;True;0;0;False;0;0,0;0,15;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-1868.901,-2018.857;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-1830.095,-1699.455;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;45;-1592.124,-1822.801;Float;False;Property;_WorldPosition;World Position;2;0;Create;True;0;0;False;0;0;0;1;True;;Toggle;2;Key0;Key1;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1545.075,-1663.018;Half;False;Property;_TexturesTiling;Textures Tiling;4;0;Create;True;0;0;False;0;0;0.06;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-1110.21,-1886.876;Float;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;162;-390.5706,-1524.151;Half;False;Constant;_Vector1;Vector 1;26;0;Create;True;0;0;False;0;1,2,3,4;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;161;-301.4504,-1719.097;Float;False;Property;_BaseLayerMaterial;Base Layer Material;6;0;Create;True;0;0;False;0;0;3;0;True;;KeywordEnum;4;Layer1;Layer2;Layer3;Layer4;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;139;-659.198,-1821.868;Float;True;Property;_Layer4AlbedoAlpha;Layer 4 Albedo (Alpha);11;0;Create;True;0;0;False;0;None;383bfc4b88f62004cb59dbd4cf4d07c8;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;149;-1192.291,-1290.506;Half;False;Property;_NormalScale;Normal Scale;22;0;Create;True;0;0;False;0;2;3;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;51;-653.0493,-2017.375;Float;True;Property;_Layer3AlbedoB;Layer 3 Albedo (B);10;0;Create;True;0;0;False;0;None;b847a8c0323a4ca42936cc44397378e6;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCCompareEqual;169;34.18276,-1794.104;Float;False;4;0;FLOAT;0;False;1;FLOAT;4;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;50;-659.02,-2220.19;Float;True;Property;_Layer2AlbedoG;Layer 2 Albedo (G);9;0;Create;True;0;0;False;0;None;39be29e15117b0742be9a71a274c7bb9;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;140;-675.1454,-994.805;Float;True;Property;_Layer4NormalA;Layer 4 Normal (A);21;0;Create;True;0;0;False;0;None;5d7b97e09ee5d5e4f9a195007ae3ef0c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCCompareEqual;168;31.5134,-1934.827;Float;False;4;0;FLOAT;0;False;1;FLOAT;3;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;67;-676.792,-1213.807;Float;True;Property;_Layer3NormalB;Layer 3 Normal (B);20;0;Create;True;0;0;False;0;None;5553f3b308edb564ea66009323ea8e95;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCCompareEqual;167;31.88636,-2081.616;Float;False;4;0;FLOAT;0;False;1;FLOAT;2;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-1544.682,-2212.531;Half;False;Property;_FieldScale;Field Scale;1;0;Create;True;0;0;False;0;0;0.0005;0;0.03;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;48;-663.3834,-2430.907;Float;True;Property;_Layer1AlbedoR;Layer 1 Albedo (R);8;0;Create;True;0;0;False;0;None;2f50f50fbb1b3044f9af5d52b7b9e45e;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCCompareEqual;164;32.38081,-1208.258;Float;False;4;0;FLOAT;0;False;1;FLOAT;4;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-1120.551,-2334.472;Float;True;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;145;89.71717,-2477.324;Half;False;Property;_BaseLayerColorVariation;Base Layer Color Variation;7;0;Create;True;0;0;False;0;1,1,1,1;0.5918031,0.8773585,0.5957753,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCCompareEqual;166;34.58019,-2231.096;Float;False;4;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;66;-677.8933,-1409.509;Float;True;Property;_Layer2NormalG;Layer 2 Normal (G);19;0;Create;True;0;0;False;0;None;703db2d3a79fd3542964f07f1fde4dff;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCCompareEqual;165;29.71141,-1358.398;Float;False;4;0;FLOAT;0;False;1;FLOAT;3;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;410.6792,-2383.136;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;47;-653.7686,-2639.77;Float;True;Property;_SplatMap;SplatMap;0;0;Create;True;0;0;False;0;75c401d9b4283304597c0858003ae346;60cc8b951fc2e084db317a1f5ce8c469;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;65;-672.0313,-1611.113;Float;True;Property;_Layer1NormalR;Layer 1 Normal (R);18;0;Create;True;0;0;False;0;None;ffb0d93a25dda234897be1d9b9e94d37;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCCompareEqual;163;30.08437,-1501.422;Float;False;4;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LayeredBlendNode;92;783.1509,-2361.633;Float;False;6;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCCompareEqual;158;34.22092,-1646.329;Float;False;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;105;411.833,-1378.903;Half;False;Property;_BaseSmoothness;Base Smoothness;12;0;Create;True;0;0;False;0;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;407.3438,-1282.033;Half;False;Property;_Layer1SmoothnessR;Layer 1 Smoothness (R);13;0;Create;True;0;0;False;0;0;0.069;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;110;906.8135,-2009.899;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;138;383.825,-1049.613;Half;False;Property;_Layer4SmoothnessAlpha;Layer 4 Smoothness (Alpha);16;0;Create;True;0;0;False;0;0;0.071;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LayeredBlendNode;93;461.1427,-1655.479;Float;False;6;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;104;831.5778,-1692.962;Half;False;Property;_MetalnessMultiplier;Metalness Multiplier;5;0;Create;True;0;0;False;0;0;0.313;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;91;547.7943,-1983.927;Half;False;Constant;_Vector0;Vector 0;14;0;Create;True;0;0;False;0;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;136;404.5768,-1205.943;Half;False;Property;_Layer2SmoothnessG;Layer 2 Smoothness (G);14;0;Create;True;0;0;False;0;0;0.232;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;137;403.1935,-1127.085;Half;False;Property;_Layer3SmoothnessB;Layer 3 Smoothness (B);15;0;Create;True;0;0;False;0;0;0.267;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;80;789.6734,-1827.838;Float;False;Property;_NormalMaps;Normal Maps;17;0;Create;True;0;0;False;0;0;1;1;True;;Toggle;2;Key0;Key1;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LayeredBlendNode;109;897.2285,-1518.219;Float;False;6;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;1342.085,-2147.323;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1880.468,-2106.083;Half;False;True;6;Half;ASEMaterialInspector;0;0;Standard;Immersive Factory/Opaque/Splat Terrain;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;1;32;100;100;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;26;0;10;1
WireConnection;26;1;10;3
WireConnection;90;0;87;0
WireConnection;90;1;26;0
WireConnection;45;1;46;0
WireConnection;45;0;90;0
WireConnection;40;0;45;0
WireConnection;40;1;41;0
WireConnection;161;1;162;1
WireConnection;161;0;162;2
WireConnection;161;2;162;3
WireConnection;161;3;162;4
WireConnection;139;1;40;0
WireConnection;51;1;40;0
WireConnection;169;0;161;0
WireConnection;169;2;139;0
WireConnection;50;1;40;0
WireConnection;140;1;40;0
WireConnection;140;5;149;0
WireConnection;168;0;161;0
WireConnection;168;2;51;0
WireConnection;168;3;169;0
WireConnection;67;1;40;0
WireConnection;67;5;149;0
WireConnection;167;0;161;0
WireConnection;167;2;50;0
WireConnection;167;3;168;0
WireConnection;48;1;40;0
WireConnection;164;0;161;0
WireConnection;164;2;140;0
WireConnection;78;0;77;0
WireConnection;78;1;45;0
WireConnection;166;0;161;0
WireConnection;166;2;48;0
WireConnection;166;3;167;0
WireConnection;66;1;40;0
WireConnection;66;5;149;0
WireConnection;165;0;161;0
WireConnection;165;2;67;0
WireConnection;165;3;164;0
WireConnection;146;0;166;0
WireConnection;146;1;145;0
WireConnection;47;1;78;0
WireConnection;65;1;40;0
WireConnection;65;5;149;0
WireConnection;163;0;161;0
WireConnection;163;2;66;0
WireConnection;163;3;165;0
WireConnection;92;0;47;0
WireConnection;92;1;146;0
WireConnection;92;2;48;0
WireConnection;92;3;50;0
WireConnection;92;4;51;0
WireConnection;92;5;139;0
WireConnection;158;0;161;0
WireConnection;158;2;65;0
WireConnection;158;3;163;0
WireConnection;110;0;92;0
WireConnection;93;0;47;0
WireConnection;93;1;158;0
WireConnection;93;2;65;0
WireConnection;93;3;66;0
WireConnection;93;4;67;0
WireConnection;93;5;140;0
WireConnection;80;1;91;0
WireConnection;80;0;93;0
WireConnection;109;0;47;0
WireConnection;109;1;105;0
WireConnection;109;2;135;0
WireConnection;109;3;136;0
WireConnection;109;4;137;0
WireConnection;109;5;138;0
WireConnection;131;0;110;3
WireConnection;131;1;104;0
WireConnection;0;0;92;0
WireConnection;0;1;80;0
WireConnection;0;3;131;0
WireConnection;0;4;109;0
ASEEND*/
//CHKSM=FD56D04837AB5C94380B2CFF3E377C8BA57A2D03