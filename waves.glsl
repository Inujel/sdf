#include "sdf_primitives.glsl"

vec4 sdScene(vec3 p)
{
    float d = sdSphere(p, vec3(0.0, -1.0, 0.0), 2.0);
    float s = (sin(p.y*6.0 + iTime*4.5) + 1.0) * 0.5;
    d -= pow(s, 8.0) * 0.1;
    return vec4(d, 1.0, 0, 0);
}

vec3 sdNormal(vec3 p)
{
    // https://iquilezles.org/www/articles/normalsSDF/normalsSDF.htm
    const float h = 1e-4;
    const vec2 k = vec2(1,-1);
    return normalize(k.xyy * sdScene(p + k.xyy*h).x + 
                     k.yyx * sdScene(p + k.yyx*h).x + 
                     k.yxy * sdScene(p + k.yxy*h).x + 
                     k.xxx * sdScene(p + k.xxx*h).x);
}

vec4 sdIntersect(vec3 ro, vec3 rd)
{
    vec3 mat = vec3(0, 0, 0);
    float t = 1.0;
    for (int i = 0; i < 300 && t < 1e3; ++i)
    {
        vec3 p = ro + t*rd;
        vec4 s = sdScene(p);

        if (s.x <= 1e-4 * t) 
            break;

        t += s.x;
        mat = s.yzw;
    }
        
    if (t > 1e3)
        mat = vec3(0, 0, 0);

    return vec4(t, mat);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 pi = (2.0*fragCoord.xy - iResolution.xy) / iResolution.y;
	vec3 ro = vec3(0.0, 0.0, 10.0 );
	vec3 rd = normalize(vec3(pi, -2.0));
    vec4 info = sdIntersect(ro, rd);
    
    float t = info.x;
    vec3 p = ro + t*rd; 
    vec3 color = vec3(0, 0, 0);
    

    if (info.y < 0.5) 
    {

    }
    else if (info.y < 1.5)
    {
        /* material 1 */
        float lum = 0.05;
        vec3 light = vec3(-0.1, 0.6, 0.2);
        vec3 normal = sdNormal(p);
        lum += clamp(dot(normal, light), 0.0, 1.0);
        color = vec3(lum, lum, lum);
    }

    fragColor = vec4(color, 1.0);
}

