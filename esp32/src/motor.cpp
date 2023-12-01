#include <Arduino.h>
#include "motor.h"

// setting PWM properties
const int freq = 5000;
// const int ledChannel = 0;
const int resolution = 8;

Motor::Motor()
{
    // pinMode(R_PWM, OUTPUT);
    ledcSetup(R_PWM_CHANNEL, freq, resolution);
    ledcSetup(L_PWM_CHANNEL, freq, resolution);

    ledcAttachPin(R_PWM_PIN, R_PWM_CHANNEL);
    ledcAttachPin(L_PWM_PIN, L_PWM_CHANNEL);
    pinMode(R_EN, OUTPUT);
    pinMode(L_EN, OUTPUT);

    digitalWrite(R_EN, HIGH);
    digitalWrite(L_EN, HIGH);
}

void Motor::stop()
{
    // analogWrite(R_PWM_PIN, 0);
    // analogWrite(L_PWM_PIN, 0);
    ledcWrite(R_PWM_CHANNEL, 0);
    ledcWrite(L_PWM_CHANNEL, 0);
}

void Motor::forward(unsigned long pwm)
{
    if (pwm > PWM_MAX)
    {
        pwm = PWM_MAX;
    }
    else if (pwm < PWM_MIN)
    {
        pwm = PWM_MIN;
    }

    // analogWrite(R_PWM_PIN, pwm);
    // analogWrite(L_PWM_PIN, 0);
    ledcWrite(R_PWM_CHANNEL, pwm);
    ledcWrite(L_PWM_CHANNEL, 0);
}

void Motor::backward(unsigned long rpm)
{

    if (rpm > PWM_MAX)
    {
        rpm = PWM_MAX;
    }
    else if (rpm < PWM_MIN)
    {
        rpm = PWM_MIN;
    }
    ledcWrite(R_PWM_CHANNEL, 0);
    ledcWrite(L_PWM_CHANNEL, rpm);
}

int Motor::get_current_rpm()
{
    return CURRENT_RPM;
}

int Motor::set_current_rpm(unsigned long rpm)
{
    CURRENT_RPM = rpm;
}

void Motor::set_target_rpm(unsigned long rpm)
{
    RPM_TARGET = rpm;
}
