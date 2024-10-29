shader_type spatial;
render_mode cull_disabled;


uniform float Octaves;
uniform float Frequency;
uniform float Amplitude;
const float point_offset = 1.0;

//float triangle(float f) {
	//return 1.0 - 2.0 * abs(f - 0.5);
//}

float quadratic(float f) {
	return 1.0 - (1.0 - sin(f)) * (1.0 - sin(f));
}


// Getting random gradients
vec2 random_gradient(vec2 p) {
	//p = p + 0.01;
	float x = dot(p, vec2(123.4, 234.5));
	float y = dot(p, vec2(345.6, 456.7));
	
	vec2 gradient = vec2(x, y);
	gradient = sin(gradient);
	gradient *= 43758.5453;
	gradient = sin(gradient);
	
	return gradient;
}

// Sampling one noise octave
float get_octave(vec2 point) {
	
	vec2 GridID = floor(point);
	vec2 GridUV = fract(point);
	
	vec2 bl = GridID + vec2(0.0, 0.0);
	vec2 br = GridID + vec2(point_offset, 0.0);
	vec2 tl = GridID + vec2(0.0, point_offset);
	vec2 tr = GridID + vec2(point_offset, point_offset);
	
	vec2 Gradbl = random_gradient(bl);
	vec2 Gradbr = random_gradient(br);
	vec2 Gradtl = random_gradient(tl);
	vec2 Gradtr = random_gradient(tr);
	
	vec2 distbl = GridUV - vec2(0.0, 0.0);
	vec2 distbr = GridUV - vec2(point_offset, 0.0);
	vec2 disttl = GridUV - vec2(0.0, point_offset);
	vec2 disttr = GridUV - vec2(point_offset, point_offset);
	
	float dotbl = Gradbl.x * distbl.x + Gradbl.y * distbl.y;
	float dotbr = Gradbr.x * distbr.x + Gradbr.y * distbr.y;
	float dottl = Gradtl.x * disttl.x + Gradtl.y * disttl.y;
	float dottr = Gradtr.x * disttr.x + Gradtr.y * disttr.y;
	
	// A custom Smoothing function
	// Even if turned off, the collision shape still doesn't match
	GridID.x = quadratic(GridUV.x);
	GridID.y = quadratic(GridUV.y);
	
	float b = mix(dotbl, dotbr, GridUV.x);
	float t = mix(dottl, dottr, GridUV.x);
	float noise = mix(b, t, GridID.y);
	
	return noise;
}


float sample_noise(vec2 p, float octaves, float freq) {
	float value = 0.0;
	float freq_factor = freq;
	vec2 point = p;
	float amp = 1.0;
	for (float i = 0.0; i < (octaves + 0.0); i++) {
		value += get_octave(point * freq_factor) * amp;
		freq_factor *= 2.0;
		amp *= 0.5;
	}
	return value;
}

void vertex() {
	// Repositioning the vertexies positions so they match the collision shape
	vec2 vert = (VERTEX.zx + vec2(50)) / 100.0;
	
	// Sampling noise (Point, Octaves, Frequency)
	float y = sample_noise(vert, Octaves, Frequency);
	
	VERTEX.y += y * Amplitude;
	COLOR.rgb = vec3(y);
}

void fragment() {
	ALBEDO = COLOR.rgb;
}
