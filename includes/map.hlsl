//map a value from an input range to an output range
#ifndef MAP_FUNC_INCLUDED
    #define MAP_FUNC_INCLUDED    
    float4 map(float4 val, float4 fromMin, float4 fromMax, float4 toMin, float4 toMax){
        return (val - fromMin) * (toMax - toMin) / (fromMax - fromMin) + toMin;
    }

    float3 map(float3 val, float3 fromMin, float3 fromMax, float3 toMin, float3 toMax){
        return (val - fromMin) * (toMax - toMin) / (fromMax - fromMin) + toMin;
    }

    float2 map(float2 val, float2 fromMin, float2 fromMax, float2 toMin, float2 toMax){
        return (val - fromMin) * (toMax - toMin) / (fromMax - fromMin) + toMin;
    }

    float map(float val, float fromMin, float fromMax, float toMin, float toMax){
        return (val - fromMin) * (toMax - toMin) / (fromMax - fromMin) + toMin;
    }
#endif