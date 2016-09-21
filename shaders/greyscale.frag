vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 pixel = Texel(texture, texture_coords);

    vec3 c = vec3(pixel);

    // NTSC greyscale conversion, takes human luminance perception into account
    float grey = dot(c, vec3(0.299, 0.587, 0.114));

    return vec4(grey, grey, grey, pixel.a);
}
