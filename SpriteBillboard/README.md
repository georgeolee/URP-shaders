# Sprite Billboard

A shader for drawing camera-facing 2D billboards with URP's forward renderer. Billboards can be cylindrical or spherical.

Has some basic support for 3D lighting and shadows. Not intended for use with the 2D renderer.


|feature|support|
|-|-|
|Lighting|ambient + main light|
|Shadows - receiver|yes|
|Shadows - caster|partial\*|
|Depth Write|yes|
|Transparency|yes (alpha clipped)|
|Partial Transparency|no|

\* *Only works with cylindrical billboards at the moment. Has a strong tendency to self-shadow if casting and receiving are both enabled*

\*\* By default, `MeshRenderer` will cast shadows while `SpriteRenderer` will not. To enable / disable shadow casting from a renderer, set its [shadowCastingMode](https://docs.unity3d.com/ScriptReference/Renderer-shadowCastingMode.html) in a C# script.

![billboard-sprites-small](https://user-images.githubusercontent.com/62530485/223568785-4aeb8473-f7b4-49ab-9eae-6fe8e93a9ea9.png)

*Bird billboards with shadows and a depth-based fog effect*
