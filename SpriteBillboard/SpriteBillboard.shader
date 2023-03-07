Shader "Custom/SpriteBillboard"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white" {}

        _Cutoff("Alpha Cutoff", range(0,1)) = 0.5

        [KeywordEnum(Cylinder, Sphere, Off)] _Billboard("Billboard Mode", float) = 0        

        [Toggle(_RECEIVE_SHADOWS)] _Receive_Shadows("Receive Shadows", float) = 1
        

        _Tint("Tint", Color) = (1,1,1,1)        

        _shadowDepthBias("Shadow Depth Bias", range(-0.5,0.5)) = 0
    }

    SubShader
    {
        Tags {            
            "DisableBatching"="True"        // draw call batching breaks billboarding bc the batched sprites share a single model matrix (SRP batching is still OK though)
            "Queue" = "AlphaTest" 
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline"             
            }


        Cull Off


        HLSLINCLUDE

            #pragma shader_feature _BILLBOARD_OFF _BILLBOARD_CYLINDER _BILLBOARD_SPHERE            
            #pragma shader_feature _RECEIVE_SHADOWS
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN

            CBUFFER_START(UnityPerMaterial)
                half _Cutoff;
                half _shadowDepthBias;
                float4 _Tint;
                float4 _MainTex_ST;                                        
            CBUFFER_END

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            #ifndef _BILLBOARD_OFF // _BILLBOARD_CYLINDER or _BILLBOARD_SPHERE  

                    // overrides rotation portion of model view matrix (but not scale / translation) to keep billboard pointed at the camera
                    float4x4 GetBillboardMatrix_MV(){
                        half3 scale = half3(
                            length(unity_ObjectToWorld._m00_m10_m20),   // x axis scale
                            length(unity_ObjectToWorld._m01_m11_m21),   // y axis scale
                            length(unity_ObjectToWorld._m02_m12_m22)    // z axis scale
                        );
                        
                        float4x4 mv_matrix = UNITY_MATRIX_MV;
                        mv_matrix._m00_m10_m20 = float3(scale.x,0,0);
                        #ifdef _BILLBOARD_SPHERE
                            mv_matrix._m01_m11_m21 = float3(0,scale.y,0);
                        #endif
                        mv_matrix._m02_m12_m22 = float3(0,0,scale.z);

                        return mv_matrix;
                    }

                    // replacement for TransformObjectToHClip
                    // can multiply the return value with inverse view projection matrix to get WS position of the billboard sprite:
                    //      mul(UNITY_MATRIX_I_VP, TransformObjectToHClip_Billboard(positionOS)).xyz; // positionWS
                    half4 TransformObjectToHClip_Billboard(half3 positionOS){                        
                        float4x4 BILLBOARD_MATRIX_MV = GetBillboardMatrix_MV();                        
                        return mul(mul(UNITY_MATRIX_P, BILLBOARD_MATRIX_MV), half4(positionOS,1));                        
                    }                    
            #endif
        ENDHLSL



        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM                        

            #pragma vertex LitVertex
            #pragma fragment LitFragment

            struct Attributes
            {
                half4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float4  positionCS      : SV_POSITION;
                float2  uv              : TEXCOORD0;
                float3  positionWS      : TEXCOORD1;
            };


            Varyings LitVertex(Attributes IN)
            {
                Varyings OUT = (Varyings)0;
                

                #ifndef _BILLBOARD_OFF //_BILLBOARD_CYLINDER or _BILLBOARD_SPHERE                                                                            
                    OUT.positionCS = TransformObjectToHClip_Billboard(IN.positionOS.xyz);
                #else //_BILLBOARD_OFF
                    OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                #endif

                #ifdef _RECEIVE_SHADOWS
                    // get billboard WS position - for receiving shadows
                    OUT.positionWS = mul(UNITY_MATRIX_I_VP, OUT.positionCS).xyz;
                #endif
                
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            half4 LitFragment(Varyings IN) : SV_Target
            {   
                half4 mainTex = _Tint * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);

                // alpha clipping
                if(mainTex.a < _Cutoff){
                    discard;
                }
                

                //main light. just applied as a flat value since normals don't really contain much lighting info in the case of a billboard sprite
                Light mainLight;
                #ifdef _RECEIVE_SHADOWS
                    float4 shadowCoord;
                    #if SHADOWS_SCREEN
                        shadowCoord = ComputeNormalizedDeviceCoordinatesWithZ(IN.positionCS);
                    #else
                        shadowCoord = TransformWorldToShadowCoord(IN.positionWS);
                    #endif
                    
                    mainLight = GetMainLight(shadowCoord, IN.positionWS, 1);
                #else
                    mainLight = GetMainLight();
                #endif

                // ambient light (from color or skybox defined in unity lighting window)
                // just using L0 SH term (the constant one) instead of fully evaluating L0 L1 L2 with SampleSH and world normal for same reason as above
                half3 ambient = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);

                mainTex.rgb *= (ambient + mainLight.color * mainLight.shadowAttenuation);

                return mainTex;
            }
            ENDHLSL
        }
        
        //note: shadow casting currently only works correctly for cylindrical billboards
        Pass{            
            Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }

            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            

            #ifndef UNIVERSAL_SHADOW_CASTER_PASS_INCLUDED
            #define UNIVERSAL_SHADOW_CASTER_PASS_INCLUDED

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
            #if defined(LOD_FADE_CROSSFADE)
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

            // Shadow Casting Light geometric parameters. These variables are used when applying the shadow Normal Bias and are set by UnityEngine.Rendering.Universal.ShadowUtils.SetupShadowCasterConstantBuffer in com.unity.render-pipelines.universal/Runtime/ShadowUtils.cs
            // For Directional lights, _LightDirection is used when applying shadow Normal Bias.
            // For Spot lights and Point lights, _LightPosition is used to compute the actual light direction because it is different at each shadow caster geometry vertex.
            float3 _LightDirection;
            float3 _LightPosition;

            struct Attributes
            {
                half3 positionOS    : POSITION;
                half3 normalOS        : NORMAL;
                half2 uv            : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
                float2 uv           : TEXCOORD0;
            };

            float4 GetShadowPositionHClip(Attributes input)
            {                

                #ifndef _BILLBOARD_OFF //is _BILLBOARD_CYLINDER or _BILLBOARD_SPHERE                    
                    
                    float4x4 BILLBOARD_MATRIX_MV = GetBillboardMatrix_MV();
                    float3 positionWS = mul(UNITY_MATRIX_I_V,mul(BILLBOARD_MATRIX_MV, half4(input.positionOS,1)));
                    half3 normalWS = mul(UNITY_MATRIX_I_V,mul(BILLBOARD_MATRIX_MV, half4(input.normalOS,1)));

                #else
                    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                    half3 normalWS = TransformObjectToWorldNormal(input.normalOS);
                #endif                            

                #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                    float3 lightDirectionWS = normalize(_LightPosition - positionWS);
                #else
                    float3 lightDirectionWS = _LightDirection;
                #endif

                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

                #if UNITY_REVERSED_Z
                    positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
                #else
                    positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
                #endif

                return positionCS;
            }

            Varyings ShadowPassVertex(Attributes input)
            {                
                Varyings output = (Varyings)0;
                

                output.uv = TRANSFORM_TEX(input.uv, _MainTex);                

                output.positionCS = GetShadowPositionHClip(input);
                output.positionCS.z += _shadowDepthBias;
                return output;
            }

            half4 ShadowPassFragment(Varyings input) : SV_TARGET
            {

                //alpha clipping
                if((SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv)).a < _Cutoff){
                    discard;
                }
                return 0;
            }

            #endif

            ENDHLSL
            
        }
    
    }
}
