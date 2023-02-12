//square distance between vectors
#ifndef SQDIST_FUNC_INCLUDED
    #define SQDIST_FUNC_INCLUDED
    float sqDist(float4 P, float4 Q){        
        float4 diff = P - Q;        
        return diff.x*diff.x + diff.y*diff.y + diff.z*diff.z + diff.w*diff.w;
    }

    float sqDist(float3 P, float3 Q){        
        float3 diff = P - Q;        
        return diff.x*diff.x + diff.y*diff.y + diff.z*diff.z;
    }

    float sqDist(float2 P, float2 Q){        
        float3 diff = P - Q;        
        return diff.x*diff.x + diff.y*diff.y;
    }    
#endif