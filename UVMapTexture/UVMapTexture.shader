//Unity URP shader for generating object space map textures
Shader "Custom/UVMapTexture"
{
    Properties
    {
        //Object space min and max input values (per-component) for whichever quantity is being mapped. For scaling the output to 0..1 range        
        //For normal / tangent / bitangent output the default values should be correct
        
        //For position, min/max xyz should be set according to the local bounding volume of the mesh. In Unity you can get this with mesh.bounds.min and mesh.bounds.max
        _min_XYZ("object min XYZ", vector) = (-1,-1,-1,-1)
        _max_XYZ("object max XYZ", vector) = (1,1,1,1)

        //which mesh attribute to map
        [KeywordEnum(position_os, normal_os, tangent_os, bitangent_os, uv)] _output("output value", float) = 0

        //output a flat map in UV space or render the model normally according to the MVP matrix
        [KeywordEnum(uv_map, mvp)] _output_mode("output mode", float) = 0
        
        //check this if you don't need tangent handedness and want to force an opaque alpha channel. everything else should come out opaque anyway
        [Toggle(_FLATTEN_ALPHA)] _flatten_alpha("flatten alpha", float) = 0

    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque"
            }

        cull off //don't skip back faces
                
        
        HLSLINCLUDE
            #pragma multi_compile _ _OUTPUT_POSITION_OS _OUTPUT_NORMAL_OS _OUTPUT_TANGENT_OS _OUTPUT_BITANGENT_OS _OUTPUT_UV

            #pragma shader_feature _OUTPUT_MODE_UV_MAP _OUTPUT_MODE_MVP
            #pragma shader_feature _FLATTEN_ALPHA

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _min_XYZ;
                float4 _max_XYZ;
            CBUFFER_END


            //map vector from input range to output range (unclamped)
            float4 mapFromToRange(float4 val, float4 fromMin, float4 fromMax, float4 toMin, float4 toMax){
                return (val - fromMin) * (toMax - toMin) / (fromMax - fromMin) + toMin;
            }

        ENDHLSL
        Pass
        {
            Name "MapTexture"            
            HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                struct attributes{
                    float4 positionOS: POSITION;
                    float2 uv: TEXCOORD0;
                    float4 normalOS: NORMAL;
                    float4 tangentOS: TANGENT;
                };

                struct varyings{
                    float4 positionCS: SV_POSITION;
                    float2 uv: TEXCOORD0;
                    float4 positionOS: TEXCOORD1;
                    float4 normalOS: TEXCOORD2;
                    float4 tangentOS: TEXCOORD3;
                    float4 bitangentOS: TEXCOORD4;
                };

                varyings vert(attributes IN){
                    varyings OUT;
                    OUT.positionOS = IN.positionOS;
                    OUT.normalOS = IN.normalOS;
                    OUT.tangentOS = IN.tangentOS;
                    OUT.bitangentOS = float4(cross(IN.normalOS.xyz, IN.tangentOS.xyz) * IN.tangentOS.w, 1);

                    OUT.uv = IN.uv;

                    #ifdef _OUTPUT_MODE_MVP
                        OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                    #else
                        //output the result in UV space
                        OUT.positionCS = float4(IN.uv * 2 - 1, 0, 1);
                    #endif                                                        

                    return OUT;
                }

                float4 frag(varyings IN):SV_TARGET{                                                             

                    #ifdef _OUTPUT_POSITION_OS
                        #define MAPPED_VALUE IN.positionOS
                    #elif defined(_OUTPUT_NORMAL_OS)
                        #define MAPPED_VALUE IN.normalOS
                    #elif defined(_OUTPUT_TANGENT_OS)
                        #define MAPPED_VALUE IN.tangentOS
                    #elif defined(_OUTPUT_BITANGENT_OS)
                        #define MAPPED_VALUE IN.bitangentOS
                    #elif defined(_OUTPUT_UV)
                        #define MAPPED_VALUE 0
                        return float4(IN.uv,0,1); //UVs already in 0..1 range, so we can just return them here
                    #else
                        #define MAPPED_VALUE 0
                        return float4(1,0,1,1); // magenta error
                    #endif

                    float4 OUT = mapFromToRange(MAPPED_VALUE, _min_XYZ, _max_XYZ, 0, 1);

                    #ifdef _FLATTEN_ALPHA
                        OUT.a = 1;
                    #endif

                    return OUT;
                }
            ENDHLSL
        }
    }
}
