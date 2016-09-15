// Default vertex shader
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    // The order of operations matters when doing matrix multiplication.
    return transform_projection * vertex_position;
}

// Default fragment shader
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(texture, texture_coords);
    if (texturecolor.w == 0) {
        return texturecolor * color;
    }
    else {
        return color;
    }
}
