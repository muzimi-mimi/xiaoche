/* compare existing ISR costs vs the yaw port */
#include <math.h>
#include <stdint.h>

volatile float  fout;
volatile double dout;

/* existing main.c line 288: AngleAcc = -atan2(AY, AZ) / 3.14159 * 180 + G;  (all double) */
void existing_atan2_double(int16_t AY, int16_t AZ)
{
    dout = -atan2((double)AY, (double)AZ) / 3.14159 * 180.0;
}

/* float alternative */
void alt_atan2f(int16_t AY, int16_t AZ)
{
    fout = -atan2f((float)AY, (float)AZ) / 3.14159f * 180.0f;
}

/* existing main.c line 291: AngleGyro = Angle - GX / 32768.0 * 2000 * 0.01;  (double) */
float g_angle, g_gyro;
void existing_gyro_term(int16_t GX)
{
    g_gyro = g_angle - GX / 32768.0 * 2000 * 0.01;
}
