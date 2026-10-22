#!/bin/bash

# Set header to use fixed speed
echo  "1" > /sys/class/hwmon/hwmon3/pwm3_enable

# Set powerlimits to all known Nvidia GPUs
sudo nvidia-smi -pl 180

while true; do
    TEMPERATURE=$(nvidia-smi --query-gpu=temperature.gpu --format=noheader | head -n 1)

    # Validate temperature is numeric
    if ! [[ "$TEMPERATURE" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid temperature reading: $TEMPERATURE"
        sleep 5
        continue
    fi

    # PWM speed is an integer with value 0 - 255
    # 0% = 0
    # 10% = 25.5 ≈ 26
    # 20% = 51
    # 30% = 76.5 ≈ 77
    # 40% = 102
    # 50% = 127.5 ≈ 128
    # 60% = 153
    # 70% = 178.5 ≈ 179
    # 80% = 204
    # 90% = 229.5 ≈ 230
    # 100% = 255

    if [ $TEMPERATURE -gt 80 ]; then
        PWM_SPEED=255
    elif [ $TEMPERATURE -gt 70 ]; then
        PWM_SPEED=230
    elif [ $TEMPERATURE -gt 60 ]; then
        PWM_SPEED=190
    elif [ $TEMPERATURE -gt 50 ]; then
        PWM_SPEED=150
    else 
        PWM_SPEED=120
    fi
    # sys_fan_3
    #/sys/class/hwmon/hwmon3/pwm3

    echo $PWM_SPEED > /sys/class/hwmon/hwmon3/pwm3
    sleep 5
done