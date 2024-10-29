@tool
extends CollisionShape3D

@export var Rebuild: bool = false:
	set(Value):
		rebuild()
@export var length: int
@export var Octaves: int = 5.0
@export var Frequency: float = 2.0
@export var Amplitude: float = 1.0



func rebuild():
	var new_shape = HeightMapShape3D.new()
	new_shape.map_width = length + 1
	new_shape.map_depth = length + 1
	
	var height_array: Array = []
	for x in length + 1:
		for z in length + 1:
			var point: Vector2 = Vector2(x, z) / 100.0
			var y: float = sample_noise(point, Octaves, Frequency)
			
			height_array.append(y * Amplitude)
	
	
	new_shape.set_map_data(height_array)
	shape = new_shape
	print(height_array.size())

func sample_noise(p, octaves, freq):
	var value: float = 0.0
	var freq_factor: float = freq
	var point: Vector2 = p
	var amp: float = 1.0
	for i in octaves:
		value += get_octave(p * freq_factor) * amp
		freq_factor *= 2.0
		amp *= 0.5
	return value


func get_octave(point: Vector2):
	var GridID: Vector2 = floor(point)
	var GridUV: Vector2 = Vector2(point.x - floor(point.x), point.y - floor(point.y))
	var point_offset: float = 1.0
	
	var bl = GridID + Vector2(0.0, 0.0)
	var br = GridID + Vector2(point_offset, 0.0)
	var tl = GridID + Vector2(0.0, point_offset)
	var tr = GridID + Vector2(point_offset, point_offset)
	
	var Gradbl = random_gradient(bl);
	var Gradbr = random_gradient(br);
	var Gradtl = random_gradient(tl);
	var Gradtr = random_gradient(tr);
	
	var distbl = GridUV - Vector2(0.0, 0.0);
	var distbr = GridUV - Vector2(point_offset, 0.0);
	var disttl = GridUV - Vector2(0.0, point_offset);
	var disttr = GridUV - Vector2(point_offset, point_offset);
	
	var dotbl = Gradbl.x * distbl.x + Gradbl.y * distbl.y
	var dotbr = Gradbr.x * distbr.x + Gradbr.y * distbr.y
	var dottl = Gradtl.x * disttl.x + Gradtl.y * disttl.y
	var dottr = Gradtr.x * disttr.x + Gradtr.y * disttr.y
	
	# This gives the same problem too! cus it has a sine function in it
	GridID.x = quadratic(GridID.x)
	GridID.y = quadratic(GridID.y)
	
	var b = lerp(dotbl, dotbr, GridUV.x)
	var t = lerp(dottl, dottr, GridUV.y)
	var noise = lerp(b, t, GridID.y)
	
	return noise

func random_gradient(p: Vector2):
	var x = p.dot(Vector2(123.4, 234.5))
	var y = p.dot(Vector2(345.6, 456.7))
	
	var gradient: Vector2 = Vector2(x, y)
	
	# Here is where the problem happens
	# If we don't get the sin of gradient in both the collision shape and the shader then they sinc
	# But if we try to get the sine everything goes OFF, pls help!
	gradient = Vector2(sin(gradient.x), sin(gradient.y))
	gradient *= 43758.5453
	gradient = Vector2(sin(gradient.x), sin(gradient.y))
	
	return gradient

func quadratic(f: float):
	return 1 - (1 - sin(f)) * (1 - sin(f))
