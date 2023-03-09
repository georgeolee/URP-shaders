#ifndef TEXOUTLINE_INCLUDED
#define TEXOUTLINE_INCLUDED

//offset up/down/left/right
#define DIRECTION_ORTHO \
    half2(-1,0),\
    half2(0,1),\
    half2(1,0),\
    half2(0,-1)

//offset diagonals
#define DIRECTION_DIAG \
    half2(-1,-1),\
    half2(-1,1),\
    half2(1,-1),\
    half2(1,1)

//convenience macro - assumes sampler follows unity naming convention (texture name prepended with "sampler", eg _MainTex -> sampler_MainTex)
//unlike the underlying TexOutline function, macro takes a scalar value (# of texels) for outline thickness
#define TEX_OUTLINE4(tex, uv, alphaCutoff, texels) (TexOutline4(tex, sampler##tex, uv, alphaCutoff, tex##_TexelSize.xy * texels))
#define TEX_OUTLINE8(tex, uv, alphaCutoff, texels) (TexOutline8(tex, sampler##tex, uv, alphaCutoff, tex##_TexelSize.xy * texels))


half TexOutline4(Texture2D tex, sampler samp, half2 uv, half alphaCutoff, half2 uvOffsetDist){
    
    static const half2 direction[] = {
        DIRECTION_ORTHO
    };

    half2 uvOffset;
    half4 texOffset;

    half empty = step(SAMPLE_TEXTURE2D(tex, samp, uv).a, alphaCutoff);
    half solidNeighbors = 0;

    [unroll(4)]
    for(int n = 0; n < 4; n++){
        uvOffset = uv + direction[n] * uvOffsetDist;
        texOffset = SAMPLE_TEXTURE2D(tex, samp, uvOffset);

        half isSolid = step(alphaCutoff, texOffset.a);
        solidNeighbors += isSolid;
    }

    return step(0.5, empty * solidNeighbors);
}

half TexOutline8(Texture2D tex, sampler samp, half2 uv, half alphaCutoff, half2 uvOffsetDist){
    
    static const half2 direction[] = {
        DIRECTION_ORTHO,
        DIRECTION_DIAG
    };

    half2 uvOffset;
    half4 texOffset;

    half empty = step(SAMPLE_TEXTURE2D(tex, samp, uv).a, alphaCutoff);
    half solidNeighbors = 0;

    [unroll(8)]
    for(int n = 0; n < 8; n++){
        uvOffset = uv + direction[n] * uvOffsetDist;
        texOffset = SAMPLE_TEXTURE2D(tex, samp, uvOffset);

        half isSolid = step(alphaCutoff, texOffset.a);
        solidNeighbors += isSolid;
    }
    
    return step(0.5, empty * solidNeighbors);
}

#endif