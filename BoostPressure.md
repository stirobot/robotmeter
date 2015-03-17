#How the Boost Pressure Works

##### Boost Sensor #####

The boost sensor only shows boost and not vac.  A freescale (motorola) MPX4250GP was used due to its outputting 0-5 Volts and its measurement range.  According to freescale this sensor is used in oem car applications.

[mac graph boost curve](http://robotmeter.com/meter/sensorcurves/boostcurve.gcx)

The pressure sensor use will measure pressures up to 36 psi, which should be plenty.
```
  long lookup_boost(long boost){
  //boost = ( (boost-106000) / 259000 );
  // boost = ( (( boost * 398) / 1000) + 2); //2 is the y intercept
  //398 changed to 378 for slope...because slope was too steep
  boost = ( (( boost * 378) / 1000) - 4); ///10; //get rid of the divide by ten when adding decimals on display
  return boost;
  }

```