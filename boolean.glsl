#include "sdf_primitives.glsl"

vec4 sdScene(vec3 q)
{
    float d = sdPlaneY(q, -3.0);
    vec3 p = q + vec3(0, -2.2 - sin(iTime), 0);
    p.y += sin(p.x * 2.0 + iTime * 1.7) * 0.15;

    {
        float d_box = sdBox(p, vec3(-4.0, -2.3, -0.7), vec3(0.7, 0.7, 0.7));
        float d_sphere = sdSphere(p, vec3(-3.4, -3.0, -1.1), 1.0);
        float d_inter = max(d_sphere, d_box);
        d = min(d, d_inter);
    } 

    {
        float d_box = sdBox(p, vec3(-0.4, -3.0, -1.1), vec3(0.7, 0.7, 0.7));
        float d_sphere = sdSphere(p, vec3(-1.0, -2.3, -0.7), 1.0);
        d = min(d, d_box);
        d = max(d, -d_sphere);
    } 

    {
        float d_box = sdBox(p, vec3(2.0, -2.3, -0.7), vec3(0.7, 0.7, 0.7));
        float d_sphere = sdSphere(p, vec3(2.6, -3.0, -1.1), 1.0);
        d = min(d, d_sphere);
        d = max(d, -d_box);
    } 

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

float sdShadow(vec3 ro, vec3 rd, float k)
{
    float res = 1.0;
    
    float t = 0.01;
    for( int i=0; i<128; i++ )
    {
        vec3 pos = ro + t*rd;
        float h = sdScene(pos).x;
        res = min( res, k*max(h,0.0)/t );
        if( res<0.0001 ) break;
        t += clamp(h,0.01,0.5);
    }

    return res;
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

vec4 render( vec3 ro, vec3 rd )
{
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
        float lum = 0.2;
        vec3 light = vec3(-0.1, 0.6, 0.2);
        vec3 normal = sdNormal(p);
        lum += clamp(dot(normal, light), 0.0, 1.0);
        lum *= 0.7 + 0.3 * sdShadow(p + 1e-3*normal, light, 60.0);
        lum *= exp(-0.02 * info.x);
        color = vec3(lum, lum, lum);
    }

    return vec4(color, 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 pi = (2.0*fragCoord.xy - iResolution.xy) / iResolution.y;
	vec3 ro = vec3(0.0, 2.0, 10.0 );
	vec3 rd = normalize(vec3(pi.x, pi.y-0.5, -2.0));

#if 1
    vec3 d = 1.0f * vec3(0.25, -0.25, 0) / iResolution.y;
    fragColor = 1.0 / 6.0 * (render(ro, rd + d.xxz) + 
                             render(ro, rd + d.xyz) + 
                             render(ro, rd + d.yxz) + 
                             render(ro, rd + d.yyz) + 
                             2.0 * render(ro, rd));
#else 
    fragColor = render(ro, rd);
#endif
}

