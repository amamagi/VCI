﻿Shader "Effekseer/StandardShader" {

	Properties{
		_ColorTex("Color (RGBA)", 2D) = "white" {}
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendSrc("Blend Src", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 0
		_BlendOp("Blend Op", Float) = 0
		_Cull("Cull", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("ZTest Mode", Float) = 0
		[Toggle]_ZWrite("ZWrite", Float) = 0
	}

	SubShader{

	Blend[_BlendSrc][_BlendDst]
	BlendOp[_BlendOp]
	ZTest[_ZTest]
	ZWrite[_ZWrite]
	Cull[_Cull]

	Pass {

	CGPROGRAM

	#pragma target 5.0
	#pragma vertex vert
	#pragma fragment frag

	#include "UnityCG.cginc"

	#if defined(UNITY_INSTANCING_ENABLED) || defined(UNITY_PROCEDURAL_INSTANCING_ENABLED) || defined(UNITY_STEREO_INSTANCING_ENABLED)
	#define VERTEX_INPUT_INSTANCE_ID UNITY_VERTEX_INPUT_INSTANCE_ID
	#define GET_INSTANCE_ID(input) unity_InstanceID
	#else
	#define VERTEX_INPUT_INSTANCE_ID uint inst : SV_InstanceID;
	#define GET_INSTANCE_ID(input) input.inst
	#endif

	sampler2D _ColorTex;

	struct SimpleVertex
	{
		float3 Pos;
		float2 UV;
		float4 Color;
	};

	StructuredBuffer<SimpleVertex> buf_vertex;
	float buf_offset;

	struct vs_input
	{
		uint id : SV_VertexID;
		VERTEX_INPUT_INSTANCE_ID
	};

	struct ps_input
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		float4 color : COLOR0;
		UNITY_VERTEX_OUTPUT_STEREO
	};

	ps_input vert(vs_input i)
	{
		ps_input o;
		UNITY_SETUP_INSTANCE_ID(i);
		UNITY_INITIALIZE_OUTPUT(ps_input, o);
		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
	
		int qind = (i.id) / 6;
		int vind = (i.id) % 6;

		int v_offset[6];
		v_offset[0] = 2;
		v_offset[1] = 1;
		v_offset[2] = 0;
		v_offset[3] = 1;
		v_offset[4] = 2;
		v_offset[5] = 3;

		SimpleVertex v = buf_vertex[buf_offset + qind * 4 + v_offset[vind]];
		
		float3 worldPos = v.Pos;
		o.pos = mul(UNITY_MATRIX_VP, float4(worldPos,1.0f));
		o.uv = v.UV;
		o.uv.y = 1.0 - o.uv.y;
		o.color = (float4)v.Color;
		return o;
	}

	float4 frag(ps_input i) : COLOR
	{
		float4 color = tex2D(_ColorTex, i.uv) * i.color;

		if (color.w <= 0.0f)
		{
			discard;
		}

		return color;
	}

	ENDCG

	}

	}

	Fallback Off
}