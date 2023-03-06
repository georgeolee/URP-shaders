# UV Map Texture

A shader for generating UV to \[*insert mesh attribute here*\] map textures from a mesh:
- position
- normal
- tangent
- bitangent
- UV

All values are in object space.

Has a keyword toggle for rendering the mesh normally (using vertex position * MVP matrix) instead of as a UV map for debugging stuff. 

## Input Range

The material properties `_min_XYZ` and `_max_XYZ` determine which values map to 0 and 1 respectively in the shader output, with one exception. When mesh UVs are used as the input attribute, values are assumed to be in 0 to 1 range and `_min_XYZ` and `_max_XYZ` are ignored.

For position, `_min_XYZ` and `_max_XYZ` should be set to the min and max extents of the mesh's AABB in object space (leave W component alone). In Unity you can get these values with `Mesh.bounds.min` and `Mesh.bounds.max`.

For normal/tangent/bitangent `_min_XYZ` and `_max_XYZ` should stay at -1 and 1 unless the input vectors are non-unit length for some reason.


