
extern float canvasWidth;
extern float canvasHeight;
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    vertex_position = vertex_position + vec4(1, 1, 1, 1) * sin(vertex_position.x);
    vertex_position = vertex_position + vec4(0, 1, 1, 0);

    // The order of operations matters when doing matrix multiplication.
    return transform_projection * vertex_position;
}
