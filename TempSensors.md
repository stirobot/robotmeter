#How the temp sensors work

##### Generic Ambient Temperature Sensors #####


252FG1K from ussensors: [ProductPage](http://www.ussensor.com/prod_DO-35_std.htm) [RT curve points](http://www.ussensor.com/rt%20charts/252FG1K.htm)


The temperature sensors will show temperatures up to 500+ C degrees.  Unfortunately the heatshrink and the sheathing on the wires you use will not go this high (The heatshrink will melt when exposed to a continuous 300 deg C or 572 deg F.  They should be able to withstand a continuous 135 deg C or 275 deg F.  The PVC wire insulation will probably handle slightly less.)   If you wish to use these on a very high temperatures you will need to put an an insulator around everything but the glass part of the sensor.  Examples of high heat applications include touching the turbo/turbo heatshield/brake caliper/etc.  Examples of applications that do not need insulation include, ambient engine bay temps, on IC temps, wheel well temps, etc.  These sensors are not exhaust gas temperature sensors!  These sensors are not mean to be installed IN air intakes or in IC piping.


In order for these to work with the code below they should be set up in a voltage divider with the sensor as [R2](https://code.google.com/p/robotmeter/source/detail?r=2) and a 470 ohm resistor as [R1](https://code.google.com/p/robotmeter/source/detail?r=1).

Design considerations:
I tried using a pure lookup table, but it took up too much space on the chip.  I also found that I was unable to implement the actual (complicated) formula that describes the RT curve of this setup.  So, I resorted to using small straight line formulas to get the same effect.


```
long lookup_temp(long tval){  
    tval = tval * 100; ''
  if (tval < 8900){
   return (9999); 
  }
  if (tval > 96000){
    return (0);
  }
  if ((tval <= 96000)&&(tval > 93221)){
    return (((tval-101577)*10)/(-172));
  }
  if ((tval <= 93221)&&(tval > 89610)){
    return (((tval-104201)*10)/(-226));
  }
  if ((tval <= 89610)&&(tval > 85125)){
    return (((tval-107738)*10)/(-280));
  }
  if ((tval <= 85125)&&(tval > 79139)){
    return (((tval-112264)*10)/(-335));
  }
  if ((tval <= 79139)&&(tval > 70799)){
    return (((tval-117588)*10)/(-388));
  }
  if ((tval <= 70799)&&(tval > 62470)){
    return (((tval-121441)*10)/(-421));
  }
  if ((tval <= 62470)&&(tval > 53230)){
    return (((tval-122367)*10)/(-428));
  }
  if ((tval <= 53230)&&(tval > 43707)){
    return (((tval-118651)*10)/(-405));
  }
  if ((tval <= 43707)&&(tval > 36471)){
    return (((tval-111349)*10)/(-366));
  }
  if ((tval <= 36471)&&(tval > 30685)){
    return (((tval-102232)*10)/(-321));
  }
  if ((tval <= 30685)&&(tval > 24800)){
    return (((tval-9078)*10)/(-270));
  }
  if ((tval <= 24800)&&(tval > 20000)){
    return (((tval-78575)*10)/(-220));
  }
  if ((tval <= 20000)&&(tval > 15851)){
    return (((tval-66507)*10)/(-175));
  }
  if ((tval <= 15851)&&(tval > 12380)){
    return (((tval-55300)*10)/(-137));
  }
  if ((tval <= 12380)&&(tval > 9085)){
    return (((tval-41752)*10)/(-94));
  }
  }
```