#[compute]
#version 450


// Flat buffer of triangle vertex triplets
layout(set = 0, binding = 0, std430) restrict writeonly buffer TrianglesBuffer {
    vec2 data[];
}
triangle_buffer;

// Triangulation array of arrays in order of configuration number
layout(set = 0, binding = 1, std430) restrict readonly buffer TriangulationBuffer {
    vec2 data[16][9]; // TODO: How to ensure always 9 - deal with nulls?
}
triangulation_buffer;

// Points weights buffer
layout(set = 0, binding = 2, std430) restrict readonly buffer PointsWeights {
    float data[];
}
points_weights;

layout(set = 0, binding = 3, std430) restrict readonly buffer StepSize {
    uint data;
}
step_size; // 20

layout(set = 0, binding = 4, std430) restrict readonly buffer GridSize {
    uint data;
}
grid_size; // 100

// TODO: How can we pass grid_size here when Godot compiles?
layout(local_size_x = 99, local_size_y = 99, local_size_z = 1) in;

void main() {
	// for y in range(0, self.grid_size - 1):
	// 	for x in range(0, self.grid_size - 1):
	// 		var points_weights = [%Points.points_weights[(y*self.grid_size) + x],
	// 		%Points.points_weights[(y*self.grid_size) + x + 1],
	// 		%Points.points_weights[((y+1)*self.grid_size) + x],
	// 		%Points.points_weights[((y+1)*self.grid_size) + x + 1]]
	// 		var points_bools = points_weights.map(func(k): return k >= self.threshold)
	// 		var square = Vector4(points_bools[0], points_bools[1], points_bools[2], points_bools[3])
	// 		var triangle_list = PackedVector2Array()
	// 		for tri in triangulation_dict[square]:
	// 			var interpolated_tri = midpoint_tri_to_interpolation(tri, points_weights)
	// 			indices.append(index_count)
	// 			index_count += 1
	// 			var new_tri = (interpolated_tri * self.grid_step) + Vector2(x * self.grid_step, y * self.grid_step)
	// 			triangle_list.append(new_tri)
	// 		all_triangles.append_array(triangle_list)
    //    
    field_buffer.data[(gl_GlobalInvocationID.y * grid_size.data) + gl_GlobalInvocationID.x] = vec2(0.0);
   for(int i=0;i<int(body_position_buffer.data.length());i++)
  {
    vec2 pos = vec2(float(gl_GlobalInvocationID.x * step_size.data), float(gl_GlobalInvocationID.y * step_size.data));
    pos = pos - body_position_buffer.data[i];
    float f = body_mass_buffer.data[i] / dot(pos, pos);
    field_buffer.data[(gl_GlobalInvocationID.y * grid_size.data) + gl_GlobalInvocationID.x] += f * normalize(pos);
  }	
}
            