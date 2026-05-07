shader_type canvas_item;

uniform vec3 base_color;
uniform sampler2D mask;

void fragment() {
	vec3 color = base_color;
	float alpha = texture(mask, UV).a;
	
	COLOR.rgb = color;
	COLOR.a = alpha;
}
