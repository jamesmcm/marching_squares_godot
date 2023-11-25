extends MeshInstance2D

var grid_size = null
var grid_step = null
var triangulation_dict = null
var triangulation_array = []
var triangulation_sizes = []
var triangulation_starts = []
var rd: RenderingDevice
var shader: RID
var owner_id = null
var current_collider_shapes_points = {}
var shape_add_count = 0
var threshold = null


func build_triangulation_dict(): 
	# TODO: Convert this to standard 0-15 lookup
	var triangulation_dict = {
	Vector4(false, false, false, false) : [],
	Vector4(true, false, false, false) : [Vector2(0.0, 0.0), Vector2(0.5, 0.0), Vector2(0.0, 0.5)],
	Vector4(true, true, false, false) : [Vector2(0.0, 0.0), Vector2(1.0, 0.0), Vector2(0.0, 0.5),
		Vector2(1.0, 0.0), Vector2(1.0, 0.5), Vector2(0.0, 0.5),],
	Vector4(true, false, false, true) : [Vector2(0.0, 0.0), Vector2(0.5, 0.0), Vector2(0.0, 0.5),
	Vector2(1.0, 1.0), Vector2(0.5, 1.0), Vector2(1.0, 0.5)],

	
	Vector4(true, true, true, true) : [Vector2(0.0, 0.0), Vector2(1.0, 0.0), Vector2(1.0, 1.0),
		Vector2(0.0, 1.0), Vector2(1.0, 1.0), Vector2(0.0, 0.0),],
		
	Vector4(true, true, true, false) : [Vector2(0.0, 0.0), Vector2(0.0, 1.0), Vector2(0.5, 1.0),
	Vector2(0.0, 0.0), Vector2(1.0, 0.5), Vector2(0.5, 1.0),
	Vector2(0.0, 0.0), Vector2(1.0, 0.0), Vector2(1.0, 0.5),
	]
		}
		
	triangulation_dict[Vector4(false, true, true, true)] = triangulation_dict[Vector4(true, true, true, false)].map(func(pos): return (Vector2(-1,-1)*pos) + Vector2(1,1))
	triangulation_dict[Vector4(true, false, true, true)] = triangulation_dict[Vector4(true, true, true, false)].map(func(pos): return (Vector2(1,-1)*pos) + Vector2(0,1))
	triangulation_dict[Vector4(true, true, false, true)] = triangulation_dict[Vector4(true, true, true, false)].map(func(pos): return (Vector2(-1,1)*pos) + Vector2(1,0))
	triangulation_dict[Vector4(false, false, true, true)] = triangulation_dict[Vector4(true, true, false, false)].map(func(pos): return (Vector2(1,-1)*pos) + Vector2(0,1))
	
	triangulation_dict[Vector4(false, true, false, false)] = triangulation_dict[Vector4(true, false, false, false)].map(func(pos): return (Vector2(-1,1)*pos) + Vector2(1,0))
	triangulation_dict[Vector4(false, false, true, false)] = triangulation_dict[Vector4(true, false, false, false)].map(func(pos): return (Vector2(1,-1)*pos) + Vector2(0,1))
	triangulation_dict[Vector4(false, false, false, true)] = triangulation_dict[Vector4(true, false, false, false)].map(func(pos): return (Vector2(-1,-1)*pos) + Vector2(1,1))
	
	triangulation_dict[Vector4(false, true, true, false)] = triangulation_dict[Vector4(true, false, false, true)].map(func(pos): return (Vector2(-1,1)*pos) + Vector2(1,0))
	
	triangulation_dict[Vector4(true, false, true, false)] = [Vector2(0.0, 0.0), Vector2(0.0, 1.0), Vector2(0.5, 1.0),
		Vector2(0.5, 1.0), Vector2(0.0, 0.0), Vector2(0.5, 0.0),]
		
	triangulation_dict[Vector4(false, true, false, true)] = triangulation_dict[Vector4(true, false, true, false)].map(func(pos): return pos + Vector2(0.5,0))
	triangulation_dict[Vector4(false, false, true, true)] = triangulation_dict[Vector4(true, true, false, false)].map(func(pos): return pos + Vector2(0,0.5))
	self.triangulation_dict = triangulation_dict
	self.triangulation_array.resize(16)
	self.triangulation_sizes.resize(16)
	self.triangulation_starts.resize(16)
	var start_index = 0
	for i in range(16):
		var tri = triangulation_dict[Vector4(bool((i&8)>>3), bool((i&4)>>2), bool((i&2)>>1), bool(i&1))]
		var size = tri.size()
		self.triangulation_sizes[i] = size
		self.triangulation_starts[i] = start_index
		self.triangulation_array[i] = tri
		start_index += size
		# self.triangulation_array[i].resize(9)


# TODO: Iterative generate mesh
# Given modified points and existing mesh, delete and regenerate only affected points
func interpolate(a, b):
	if a > b:
		return (a + b) / 2.0
	else:
		return 1 - ((a + b) / 2.0)


func midpoint_tri_to_interpolation(p, points_weights):
	if p.x == 0.5:
		if p.y == 0:
			return Vector2(interpolate(points_weights[0], points_weights[1]), 0)
		elif p.y == 1:
			return Vector2(interpolate(points_weights[2], points_weights[3]), 1)
	elif p.y == 0.5:
		if p.x == 0:
			return Vector2(0, interpolate(points_weights[0], points_weights[2]))
		elif p.x == 1:
			return Vector2(1, interpolate(points_weights[1], points_weights[3]))
	else:
		return p

func generateTriangleMesh() -> ArrayMesh:
	var index_count = 0
	var indices = PackedInt32Array()
	var all_triangles = []
	for y in range(0, self.grid_size - 1):
		for x in range(0, self.grid_size - 1):
			var points_weights = [%Points.points_weights[(y*self.grid_size) + x],
			%Points.points_weights[(y*self.grid_size) + x + 1],
			%Points.points_weights[((y+1)*self.grid_size) + x],
			%Points.points_weights[((y+1)*self.grid_size) + x + 1]]
			var points_bools = points_weights.map(func(k): return k >= self.threshold)
			# var square = Vector4(points_bools[0], points_bools[1], points_bools[2], points_bools[3])
			var square_index = (int(points_bools[0])<<3)+(int(points_bools[1])<<2)+(int(points_bools[2])<<1)+int(points_bools[3])
			var triangle_list = PackedVector2Array()
			for tri in self.triangulation_array[square_index]: # triangulation_dict[square]:
				var interpolated_tri = midpoint_tri_to_interpolation(tri, points_weights)
				indices.append(index_count)
				index_count += 1
				var new_tri = (interpolated_tri * self.grid_step) + Vector2(x * self.grid_step, y * self.grid_step)
				triangle_list.append(new_tri)
			all_triangles.append_array(triangle_list)
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector2Array()
	if all_triangles.size() == 0:
		return null
	
	# print(all_triangles)
	verts.append_array(all_triangles)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_INDEX] = indices
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return mesh
	
func generateTriangleMeshGpu() -> ArrayMesh:
	var triangles_sized = []
	triangles_sized.resize(self.grid_size * self.grid_size * 9)
	triangles_sized.fill(Vector2(-999.0, -999.0))
	var input_bytes := PackedVector2Array(triangles_sized).to_byte_array()
	var buffer := rd.storage_buffer_create(input_bytes.size(), input_bytes)
	var triangles := RDUniform.new()
	triangles.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	triangles.binding = 0 # this needs to match the "binding" in our shader file
	triangles.add_id(buffer)
	
	# print(triangulation_array)
	var flat_triangulation_array = []
	for i in range(16):
		flat_triangulation_array.append_array(triangulation_array[i])
	# print(flat_triangulation_array)
	var triangulation_bytes := PackedVector2Array(flat_triangulation_array).to_byte_array()
	# print(triangulation_bytes)
	var triangulation_buffer := rd.storage_buffer_create(triangulation_bytes.size(), triangulation_bytes)
	var triangulation := RDUniform.new()
	triangulation.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	triangulation.binding = 1 # this needs to match the "binding" in our shader file
	triangulation.add_id(triangulation_buffer)
	
	var points_weights_bytes := PackedFloat32Array(%Points.points_weights).to_byte_array()
	var points_weights_buffer := rd.storage_buffer_create(points_weights_bytes.size(), points_weights_bytes)
	# print(%Points.points_weights.slice(0,10))
	var points_weights := RDUniform.new()
	points_weights.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	points_weights.binding = 2 # this needs to match the "binding" in our shader file
	points_weights.add_id(points_weights_buffer)
	
	var step_size_uniform := RDUniform.new()
	var step_size_bytes = PackedInt32Array([self.grid_step]).to_byte_array()
	step_size_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	step_size_uniform.binding = 3
	step_size_uniform.add_id(rd.storage_buffer_create(step_size_bytes.size(), step_size_bytes ))
	
	var grid_size_uniform := RDUniform.new()
	var grid_size_bytes = PackedInt32Array([self.grid_size]).to_byte_array()
	grid_size_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	grid_size_uniform.binding = 4
	grid_size_uniform.add_id(rd.storage_buffer_create(grid_size_bytes.size(), grid_size_bytes ))
	
	var threshold_uniform := RDUniform.new()
	var threshold_bytes = PackedFloat32Array([self.threshold]).to_byte_array()
	threshold_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	threshold_uniform.binding = 5
	threshold_uniform.add_id(rd.storage_buffer_create(threshold_bytes.size(), threshold_bytes ))
	
	var triangulation_sizes_bytes := PackedInt32Array(triangulation_sizes).to_byte_array()
	var triangulation_sizes_buffer := rd.storage_buffer_create(triangulation_sizes_bytes.size(), triangulation_sizes_bytes)
	var triangulation_sizes_rd := RDUniform.new()
	triangulation_sizes_rd.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	triangulation_sizes_rd.binding = 6 # this needs to match the "binding" in our shader file
	triangulation_sizes_rd.add_id(triangulation_sizes_buffer)
	
	var triangulation_starts_bytes := PackedInt32Array(triangulation_starts).to_byte_array()
	var triangulation_starts_buffer := rd.storage_buffer_create(triangulation_starts_bytes.size(), triangulation_starts_bytes)
	var triangulation_starts_rd := RDUniform.new()
	triangulation_starts_rd.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	triangulation_starts_rd.binding = 7 # this needs to match the "binding" in our shader file
	triangulation_starts_rd.add_id(triangulation_starts_buffer)
	
	var uniform_set := rd.uniform_set_create([triangles, triangulation, points_weights, step_size_uniform, grid_size_uniform, threshold_uniform, triangulation_sizes_rd, triangulation_starts_rd], shader, 0) # the last parameter (the 0) needs to match the "set" in our shader file
	# print(rd.uniform_set_is_valid(uniform_set))
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, self.grid_size-1, self.grid_size-1, 1)
	rd.compute_list_end()
	rd.submit()
	rd.sync()
	# TODO: Can we get Vector2 array directly ?
	# TODO: Precision issues ? 
	var arr =  rd.buffer_get_data(buffer).to_float32_array()
	# print(arr)a


	var all_triangles = []
	var indices = []
	var ix = 0
	for i in range(arr.size() / 2):
		# print(arr[i])
		if arr[2*i] >= 0 or arr[(2*i)+1] >= 0:
			all_triangles.append(Vector2(float(arr[2*i]), float(arr[(2*i)+1])))
			indices.append(ix)
			ix += 1
	var out_arr = []
	out_arr.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector2Array()
	if all_triangles.size() == 0:
		return null

	verts.append_array(all_triangles)

	out_arr[Mesh.ARRAY_VERTEX] = verts
	# out_arr[Mesh.ARRAY_INDEX] = indices
	var mymesh = ArrayMesh.new()
	mymesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, out_arr)
	return mymesh



func create_collider_shape(points):
	var s = ConvexPolygonShape2D.new()
	s.points = points # Does this copy?
	return s
# Called when the node enters the scene tree for the first time.
func _ready():
	rd = RenderingServer.create_local_rendering_device()
	var shader_file := load("res://marching_squares.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	self.set_grid()
	self.build_triangulation_dict()
	# self.mesh = generateTriangleMeshGpu()

func clear_shapes(b, owner):
	# b.shape_owner_clear_shapes(owner)
	b.remove_shape_owner(self.owner_id)
	self.owner_id = b.create_shape_owner(b)

func get_new_collider_shapes_set():
	if self.mesh == null:
		return {}

	var points = self.mesh.surface_get_arrays(self.mesh.ARRAY_VERTEX)[0]
	if points.size() == 0:
		return {}
	var i = 0
	var points_set = {}
	while i < (points.size() / 3):
		points_set[[points[3*i], points[(3*i)+1], points[(3*i)+2]]] = true
		i += 1
	return points_set

func set_difference(d1, d2):
	return d1.keys().filter(func(k): return !d2.has(k))

func regenerate(v):
	var body = self.get_parent()
	#if self.owner_id != null:
	#	self.clear_shapes(body, self.owner_id)
	if self.owner_id == null:
		self.owner_id = body.create_shape_owner(body)
	self.mesh = generateTriangleMeshGpu()
	
	var new_set = get_new_collider_shapes_set()
	var new_tris = set_difference(new_set, self.current_collider_shapes_points)
	var deleted_tris = set_difference(self.current_collider_shapes_points, new_set)
	
	for new_tri in deleted_tris:
		var id = self.current_collider_shapes_points[new_tri]
		body.shape_owner_remove_shape(self.owner_id, id)
		self.current_collider_shapes_points.erase(new_tri)
		self.shape_add_count -= 1
		for k in self.current_collider_shapes_points.keys():
			if self.current_collider_shapes_points[k] >= id:
				self.current_collider_shapes_points[k] = self.current_collider_shapes_points[k] - 1

	for new_tri in new_tris:
		var s = ConvexPolygonShape2D.new()
		s.points = PackedVector2Array(new_tri)
		body.shape_owner_add_shape(self.owner_id, s)
		self.current_collider_shapes_points[new_tri] = self.shape_add_count #s.get_rid().get_id()
		self.shape_add_count += 1

func set_grid():
	var root_node = get_tree().get_root().get_child(0)
	var root_grid_size = root_node.get("grid_size")
	if root_grid_size != null:
		self.grid_size = root_grid_size
	var root_grid_step = root_node.get("grid_step")
	if root_grid_step != null:
		self.grid_step = root_grid_step
	var root_threshold = root_node.get("threshold")
	if root_threshold != null:
		self.threshold = root_threshold

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
