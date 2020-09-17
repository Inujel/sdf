//#include "sdf_primitives.glsl"
float sdSphere(vec3 p, vec3 center, float radius)
{
    return length(p - center) - radius;
}

float sdPlane(vec3 p, vec3 normal, float offset)
{
    return 0.0;
}

