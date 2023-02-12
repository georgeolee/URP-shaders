# UV Map Texture

A shader for generating UV to \[*insert mesh attribute here*\] map textures from a mesh:
- position
- normal
- tangent
- bitangent
- UV

All values are in object space.

Has a toggle for rendering the mesh normally (using vertex position * MVP matrix instead of UV as output location). For debugging stuff. 

(That also the only reason UV is up there as an input option – I'm not sure why anyone would ever need a UV to UV map.)

## Input Range

The material properties `_min_XYZ` and `_max_XYZ` control determine what values map to 0 and 1 in the shader output.

When mapping position, `_min_XYZ` and `_max_XYZ` should be set to the min and max extents of the mesh's AABB in object space. In Unity you can get these numbers with `Mesh.bounds.min` and `Mesh.bounds.max`.

For normal/tangent/bitangent `_min_XYZ` and `_max_XYZ` should stay at -1 and 1 unless the input vectors are non-unit length for some reason.

UV mode ignores these values altogether since the input is already in 0 to 1 range.