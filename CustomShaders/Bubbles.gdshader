shader_type canvas_item;

uniform vec2 Direction = vec2(1.0, 0.0);
uniform float Speed : hint_range(0.0, 1.0) = 0.1;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

  vec4 add(vec4 base, vec4 blend){
      return base + blend;
  }

  void fragment()
  {
      vec4 bg_color = texture(screen_texture, SCREEN_UV);
      COLOR = texture(TEXTURE, UV + (Direction * TIME * Speed));
      COLOR.rgb = add(bg_color, COLOR).rgb;
  }