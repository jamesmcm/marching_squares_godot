#[compute]
#version 450


// Flat buffer of triangle vertex triplets
// TODO: Can this be vec2 when run in parallel?
layout(set = 0, binding = 0, std430) restrict buffer TrianglesBuffer {
    vec2 data[];
}
triangle_buffer;

// Triangulation array of arrays in order of configuration number
layout(set = 0, binding = 1, std430) restrict buffer TriangulationBuffer {
    vec2 data[];
}
triangulation_buffer;

// Points weights buffer
layout(set = 0, binding = 2, std430) restrict buffer PointsWeights {
    float data[];
}
points_weights;

layout(set = 0, binding = 3, std430) restrict buffer StepSize {
    uint data;
}
step_size; // 20

layout(set = 0, binding = 4, std430) restrict buffer GridSize {
    uint data;
}
grid_size; // 100

layout(set = 0, binding = 5, std430) restrict buffer Threshold {
    float data;
}
threshold; // 100

layout(set = 0, binding = 6, std430) restrict buffer TriangulationSizesBuffer {
    uint data[16];
}
triangulation_sizes_buffer;


layout(set = 0, binding = 7, std430) restrict buffer TriangulationStartsBuffer {
    uint data[16];
}
triangulation_starts_buffer;

// TODO: How can we pass grid_size here when Godot compiles?
layout(local_size_x = 99, local_size_y = 99, local_size_z = 1) in;

float interpolate(float a, float b){
    if (a > b){
        return (a + b) / 2.0;
    }
    else {
        return 1.0 - ((a + b) / 2.0);
    }
}

vec2 midpoint_tri_to_interpolation(vec2 p, float[4] weights){
    if (p.x == 0.5){
        if (p.y == 0){
            return vec2(interpolate(weights[0], weights[1]), 0.0);
        } else {
            return vec2(interpolate(weights[2], weights[3]), 1.0);
        }
    } else if (p.y == 0.5){
        if (p.x ==0){
            return vec2(0.0, interpolate(weights[0], weights[2]));
        } else {
            return vec2(1.0, interpolate(weights[1], weights[3]));
        }
    } else {
        return p;
    }

}
void main() {
    uint index = (gl_GlobalInvocationID.y * grid_size.data) + gl_GlobalInvocationID.x;
    float neighbour_weights[4];
    neighbour_weights[0] = points_weights.data[index];
    neighbour_weights[1] = points_weights.data[index+1];
    neighbour_weights[2] = points_weights.data[index+grid_size.data];
    neighbour_weights[3] = points_weights.data[index+grid_size.data+1];

    bool neighbour_bools[4];
       for(uint j=0;j<4;j++){
        neighbour_bools[j] = neighbour_weights[j] >= threshold.data;
       }
    uint square_index = (int(neighbour_bools[0])<<3)+(int(neighbour_bools[1])<<2)+(int(neighbour_bools[2])<<1)+int(neighbour_bools[3]);

    uint sz = triangulation_sizes_buffer.data[square_index];
    for(uint i=0;i<sz;i++){
    uint ix = triangulation_starts_buffer.data[square_index];
    vec2 p = triangulation_buffer.data[ix + i];
    
    vec2 p2 = midpoint_tri_to_interpolation(p, neighbour_weights);
    vec2 pfinal = (p2 * float(grid_size.data)) + vec2(float(gl_GlobalInvocationID.x * step_size.data), float(gl_GlobalInvocationID.y * step_size.data));

    triangle_buffer.data[index + ix] = pfinal;
    // // triangle_buffer.data[triangle_buffer.data.length() -1 ] = pfinal; //TODO: Ensure sets of 3 points inserted together
    }

}
