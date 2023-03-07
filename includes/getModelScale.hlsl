#ifndef GETMODELSCALE_INCLUDED
#define GETMODELSCALE_INCLUDED
half3 getModelScale(float4x4 modelMatrix){
    half3 scale = half3(
        length(modelMatrix._m00_m10_m20),   // x axis scale
        length(modelMatrix._m01_m11_m21),   // y axis scale
        length(modelMatrix._m02_m12_m22)    // z axis scale
    );
    return scale;
}

float3 getModelScale(float4x4 modelMatrix){
    float3 scale = float3(
        length(modelMatrix._m00_m10_m20),   // x axis scale
        length(modelMatrix._m01_m11_m21),   // y axis scale
        length(modelMatrix._m02_m12_m22)    // z axis scale
    );
    return scale;
}
#endif