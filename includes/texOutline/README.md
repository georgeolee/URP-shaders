# texOutline.hlsl

Defines two macros, `TEX_OUTLINE4` and `TEX_OUTLINE8`, for generating crisp texel outlines around a texture. Outlines are identified by comparing alpha values between neighboring points.

```
half TEX_OUTLINE4(Texture2D tex, half2 uv, half alphaCutoff, half texels)
```

Output will be `1` if both of the following are true:
- alpha value of `tex` at `uv` is &lt; `alphaCutoff`
- alpha value of `tex` at one or more neighboring points `texels` away is &ge; `alphaCutoff`

If either is false, output will be `0`.

`TEX_OUTLINE4` compares orthogonal neighbors only (up/down/left/right), while `TEX_OUTLINE8` compares both orthogonal and diagonal neighbors. Otherwise the two are identical.

![outline-none](https://user-images.githubusercontent.com/62530485/223929767-10219e1a-caff-4cb7-b47c-99b0f7d3f2c2.png)\
**base texture - no outline**

![outline-4](https://user-images.githubusercontent.com/62530485/223929797-e33d2fba-133d-4845-9511-6ad3af4aab7d.png)\
`TEX_OUTLINE4`

![outline-8](https://user-images.githubusercontent.com/62530485/223929815-b0258855-199a-4344-ac76-30d62e595b14.png)\
`TEX_OUTLINE8`

![outline-subtexel-2](https://user-images.githubusercontent.com/62530485/223930904-36298307-3ac1-45cf-8993-f91bccea7c9f.png)\
`texels` &lt; 1




## Notes

The target texture should have at least `texels` worth of empty padding around its border or else the outline will be cut off.

Not made with thick outlines in mind! YMMV for `texels` &gt; 1.

Both macros assume the existence of a sampler that follows Unity's naming convention of "sampler" + *TextureName* — a sampler called `sampler_MainTex` for a texture called `_MainTex`, for example. 

The underlying functions `TexOutline4` and `TexOutline8` don't make this assumption and instead take an additional sampler argument. `TexOutline4` and `TexOutline8` also take a `half2` value for outline thickness in UV units instead of a scalar texel quantity.
