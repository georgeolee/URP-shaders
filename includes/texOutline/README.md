# texOutline.hlsl

Defines two macros, `TEX_OUTLINE4` and `TEX_OUTLINE8`, for generating crisp texel outlines around a texture based on an alpha cutoff value.

```
half TEX_OUTLINE4(Texture2D tex, half2 uv, half alphaCutoff, half texels)
```

Output will be `1` if both of the following are true:
- alpha value of `tex` at `uv` is &lt; `alphaCutoff`
- alpha value of `tex` at at least one neighboring point  `texels` distance away is &ge; `alphaCutoff`

If either is false, output will be `0`.

`TEX_OUTLINE4` compares orthogonal neighbors only (up/down/left/right), while `TEX_OUTLINE8` compares both orthogonal and diagonal neighbors. Otherwise the two are identical.

## Notes

The target texture should have at least `texels` worth of empty padding around its border or else the outline will appear cut off.

Both macros assume the existence of a sampler that follows Unity's naming convention of "sampler" + *TextureName* — `sampler_MainTex` for a texture called `_MainTex`, for example. 

The underlying functions `TexOutline4` and `TexOutline8` don't make this assumption and instead take an additional sampler argument.

For outline thickness, `TexOutline4` and `TexOutline8` take a `half2` value in UV units instead of a `half` value in texels.