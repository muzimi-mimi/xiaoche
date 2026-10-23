/* yaw cost measurement: reference (double, /131) vs PID port (float, /16.384) */
#include <stdint.h>

volatile float  yaw_angle_f = 0.0f;
volatile double yaw_angle_d = 0.0;

/* --- A: reference project style: double, +-250dps scale (131.0), bias -4, dz +-1 --- */
void yaw_ref_double(int16_t raw, double dt)
{
    double gz = raw / 131.0 - 4.0;
    if (gz > -1.0 && gz < 1.0) gz = 0.0;
    yaw_angle_d += gz * dt;
}

/* --- B: PID port style: float, +-2000dps scale (16.384), bias 0, dz +-0.5 --- */
void yaw_pid_float(int16_t raw, float dt)
{
    float gz = raw / 16.384f;
    if (gz > -0.5f && gz < 0.5f) gz = 0.0f;
    yaw_angle_f += gz * dt;
}
