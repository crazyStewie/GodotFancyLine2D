shader_type canvas_item;

// these textures should all be organized in the same order. For example, if the color array has
// the materials A, B, C and D, in this order, they should appear in the same orther in the 
// normal array, and be ordered in the same way on the depth texture's channels
uniform sampler2DArray COLOR_ARRAY;
uniform sampler2DArray NORMAL_ARRAY;
uniform sampler2D DEPTH_PACKED;

// Stores the texture index used on each direction, TOP, RIGHT, LEFT and BOTTOM, respectively
uniform vec4 INDEX_TRLB = vec4(0);
// Set in code with texture mode set to stretch, allows for seamless connection between the
// 2 endpoints of the line2d
uniform float UVX_SCALE = 1.0;

varying mat2 NORMAL_MATRIX;

const float PI = 3.14159265359;
void vertex() {
    NORMAL_MATRIX = mat2(COLOR.rg*2.0 - vec2(1.0), COLOR.ba*2.0 - vec2(1.0));
	UV.x*=UVX_SCALE;
}

void fragment() {
	float dir_weight = UV.y*2.0 - 1.0;
	
// Makes the shape appear round, should be removed in favor of modifying the texture itself
	vec2 round_uv = UV;
	float normal_lateral = 2.0*UV.y - 1.0;
	float pithagoras = sqrt(1.0 - pow(normal_lateral, 2.0));
	mat3 round_normals = mat3(
		vec3(1, 0, 0),
		normalize(vec3(0, pithagoras, -normal_lateral)),
		normalize(vec3(0, normal_lateral, pithagoras)*0.5)
	);
	round_uv.y = asin(normal_lateral)/PI;

// Samples the depth texture (each depth packed in a different channel)
	vec4 depth_samples = texture(DEPTH_PACKED, round_uv);

// Sorts the depths sampled between the face. For example, any face with Index 0.0 should use the 
// depth sample on the RED channel
// this can probably be optimzied
	vec4 depths = vec4(equal(INDEX_TRLB, vec4(0.0)))*depth_samples.rrrr;
	depths += vec4(equal(INDEX_TRLB, vec4(1.0)))*depth_samples.gggg;
	depths += vec4(equal(INDEX_TRLB, vec4(2.0)))*depth_samples.bbbb;
	depths += vec4(equal(INDEX_TRLB, vec4(3.0)))*depth_samples.aaaa;

// Calculates the weights for each direction
	vec4 weights = vec4(
		clamp(-NORMAL_MATRIX[1].y*dir_weight + 0.5*abs(NORMAL_MATRIX[1].y), 0.0, 1.0), //UP
		clamp(NORMAL_MATRIX[1].x*dir_weight + 0.5*abs(NORMAL_MATRIX[1].x), 0.0, 1.0), //RIGHT
		clamp(-NORMAL_MATRIX[1].x*dir_weight + 0.5*abs(NORMAL_MATRIX[1].x), 0.0, 1.0), //LEFT
		clamp(NORMAL_MATRIX[1].y*dir_weight + 0.5*abs(NORMAL_MATRIX[1].y), 0.0, 1.0) //DOWN
	);
// Calculates the weights for each direction without clamping, gives slighly different results
//	vec4 weights = vec4(
//		-NORMAL_MATRIX[1].y*dir_weight + 0.5*abs(NORMAL_MATRIX[1].y), //UP
//		NORMAL_MATRIX[1].x*dir_weight + 0.5*abs(NORMAL_MATRIX[1].x), //RIGHT
//		-NORMAL_MATRIX[1].x*dir_weight + 0.5*abs(NORMAL_MATRIX[1].x), //LEFT
//		NORMAL_MATRIX[1].y*dir_weight + 0.5*abs(NORMAL_MATRIX[1].y) //DOWN
//	);
// Use the depths to modify the weights for nicer blending
	weights += 0.5*depths;

// Finds out which direction has the max weight and isolates it, selecting the first if multiple 
// share the same max_weight, ends up with a vector that is guaranteed to have a single component
// 1.0, and all others 0.0
// this can probably be optimized
	float max_weight = max(max(weights[0], weights[1]), max(weights[2], weights[3]));
	bvec4 bweights = equal(weights, vec4(max_weight));
	bweights.y = bweights.y && !bweights.x;
	bweights.z = bweights.z && !any(bweights.xy);
	bweights.w = bweights.w && !any(bweights.xyz);
	weights = vec4(bweights);

// Finds the index of the texture used by the selected face.
// A dot product is calculated by multiplying the corresponding components on both vertices, and
// adding the results
// For example, if weights = [w1, w2, w3, w4] and INDEX_TRLB = [I1, I2, I3, I4], the resulting
// dot product is dot(weights, INDEX_TRLB) = w1*I1 + w2*I2 + w3*I3 + w4*I4.
// since only one of (w1, w2, w3, w4) is set to 1, with all the others being 0, the result is
// guaranteed to the one Index out of [I1, I2, I3, I4] that corresponds to the set weight.
	float idx = dot(weights, INDEX_TRLB);

// Samples and applies the Color and Normal based on the index previously calculated
	COLOR = texture(COLOR_ARRAY, vec3(round_uv, idx));
	vec3 normal_sample = texture(NORMAL_ARRAY, vec3(round_uv, idx)).xyz;
	// Fix Y, not necessary if the texture uses the GREEN = DOWN convention
	normal_sample.y = 1.0 - normal_sample.y; 
    NORMAL.xyz = round_normals*normalize(2.0*(normal_sample) - vec3(1.0));
// Makes the normal follow the line2d
    NORMAL.xy = NORMAL_MATRIX*NORMAL.xy;
}