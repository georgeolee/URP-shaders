# Sprite Billboard

A shader for drawing camera-facing billboard sprites with URP's forward renderer. Billboards can be cylindrical or spherical.

Has some basic support for 3D lighting and shadows. Not intended for use with 2D renderer.


|feature|support|
|-|-|
|Lighting|ambient + main light|
|Shadows - receiver|yes|
|Shadows - caster|partial\*|
|Depth Write|yes|
|Transparency|yes (alpha clipped)|
|Partial Transparency|no|

\* *Only works with cylindrical billboards at the moment. Strong tendency to self-shadow if casting and receiving are both enabled.*

