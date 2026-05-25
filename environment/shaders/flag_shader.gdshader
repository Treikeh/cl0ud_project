shader_type spatial;

render_mode cull_disabled;

uniform sampler2D Texture:source_color,filter_nearest;


group_uniforms Wave;
uniform float Wave_Speed = 5.0;
uniform float Wave_Size = 0.1;
uniform float Wave_Repeat = 5.0;
uniform sampler2D Wave_Power_Texture:source_color;


group_uniforms Rotation;
uniform float Rotate_Deg ;




vec2 rotate_uv(vec2 uv, float deg) {
	float rad = radians(deg);
	mat2 rot = mat2(vec2(cos(rad), -sin(rad)),vec2(sin(rad),  cos(rad)));
	return (rot * (uv - 0.5)) + 0.5;
}

void vertex() {
	vec2 uv = UV;
	uv = rotate_uv(uv,Rotate_Deg);

	float Wave_Base = sin((uv.x * Wave_Repeat) + (-Wave_Speed * TIME));
	
	float Power_UV = clamp(UV.x,0.01,0.99);
	float Wave_Power = texture(Wave_Power_Texture, vec2(Power_UV, 0.5)).r;
	
	
	float Sin_Value = Wave_Base * Wave_Size * Wave_Power ;
	
	
	
	VERTEX.z = Sin_Value;
}


void fragment() {
	vec4 Final_Color =  texture(Texture,UV);
	ALBEDO = Final_Color.rgb;
	ALPHA = Final_Color.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
