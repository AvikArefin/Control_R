#ifndef MOTOR
#define MOTOR

#include <Arduino.h>

class Motor
{

public:
    Motor();
    void forward(unsigned long pwm);
    void backward(unsigned long pwm);
    void stop();
    int get_current_rpm();
    int set_current_rpm(unsigned long rpm);
    void set_target_rpm(unsigned long rpm);

private:
    const byte R_PWM_PIN = 13;
    const byte R_PWM_CHANNEL = 0;
    const byte L_PWM_PIN = 12;
    const byte L_PWM_CHANNEL = 1;
    const byte R_EN = 14;
    const byte L_EN = 27;
    const byte PWM_MIN = 0;
    const byte PWM_MAX = 255;
    const int RPM_MAX = 1000;
    const int RPM_MIN = 0;
    int RPM_TARGET = 0;
    int CURRENT_RPM = 0;
};
#endif // MOTOR