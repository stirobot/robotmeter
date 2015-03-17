#MKI features and image gallery

# Features of the MKI #
  * Powers off of the car's 12V power supply.
  * Logging mode-logs all parameters via usb to a computer (any os) in a comma delimited text format for easy excel, OO-calc, matlab, etc. consumption.
  * Oil Pressure
  * Oil temperature
  * Oil temperature warmup-starts up in oil temp mode. When the oil temp reaches a set point (ie the car is warmed up) the unit switches to the default mode (default mode is the accelerometer display)
  * 2 axis 2g accelerometer (I'm using a 1.2g but plan to switch) with a lateral bar graph and discrete display.
  * 2 x Misc temperature sensors-useful for cabin temp, ambient temp, and various underhood temps. Could also be setup for you to jump out of the car in between laps and test tire temps.
  * lap timer with 2 laps/lines-this is persistent and will continue to run even if you switch modes. However, it has a 9 hour time limit based on a limit in the microcontroller used in the arduino.
  * turbo (boost) pressure (not vacuum)
  * peak hold/reset for most sensors (reset via time is planned for the near future)
  * several types of displays (in code configurable for now). A two sensor display with peaks. A single sensor display with bar graph and peaks. A specialized accelerometer display. (A 4 sensor non-peak display is also a possibility, but has not been coded yet).
  * temporary peak bar hold on the accelerometer (looks like a VU meter on a stereo system)
  * Warnings-currently setup to flash backlight. In addition (though not currently configured) a warning light could go on or a buzzer could sound. This could be configured at multiple step levels (in code, and not written yet).
  * boost referenced (or more generically, sensor referenced) Intercooler water spray. (Planned, not yet implemented).
  * “HIGH” and “LOW” display when sensor is out of range (can be turned off per sensor/per display)


TODO: rehost image on robotmeter.com and link