#How the oil temp senders work

##### Oil Temperature Sender #####

The preferred oil temperature sender is a nippon-seiki/defi unit.  These are very pricey, but very well made.  Note that the curve presented here was not provided by nippon-seiki and was determined using cooking oil, a multimeter, and a candy thermometer.  The sensor is [R2](https://code.google.com/p/robotmeter/source/detail?r=2) in a voltage divider with a 2200 ohm resistor as [R1](https://code.google.com/p/robotmeter/source/detail?r=1).

[OpenOffice doc with defi oil temp curve](http://robotmeter.com/meter/sensorcurves/defisenders.ods)

The code is incomplete and untested
```
//code for defi/nippon-seiki temp sender  
long lookup_oil_temp(long tval){
//FIX DECIMAL PROBLEM...REMEBRE
  if (tval <= 200){
    return 0;
  }
  
  if (tval > 200 && tval <= 315){
    //return .37 * tval + 47.74;
    return (37 * tval + 4774);
  }
  
  if (tval > 315 && tval <= 477){
    //return .28 * tval + 71.3;
    return (28 * tval + 7130);
  }
  
  if (tval > 477 && tval <= 790){
    //return .33 * tval + 35.59;
    return (33 * tval + 3559);
  }
  
  if (tval > 790){
    return 9999;
  } 
  
}
```

Oil temperature sender is a ISSPRO sender, part [R8958](https://code.google.com/p/robotmeter/source/detail?r=8958).  I chose this sender because it comes in a number of different thread types/sizes.

ISSPRO was kind enough to provide an RT curve for this sender: [OilTemp pdf](http://robotmeter/meter/sensorcurves/OilTempThermistorTBcodeGS.pdf) TODO: FIX LINK

For this code to work the sender should be set up as [R2](https://code.google.com/p/robotmeter/source/detail?r=2) with [R1](https://code.google.com/p/robotmeter/source/detail?r=1) as a 220 Ohm resistor.
```
  long lookup_oil_temp(long tval){
  tval = tval * 1000; //added an extra 0
  if (tval <= 11500){
    return (9999); 
  }
  if (tval >= 68100){
    return (0);
  }
  if ((tval <= 68000)&&(tval > 39600)){
    return (long)(((tval-134266)*10)/(-473));
  }
  if ((tval <= 39600)&&(tval > 28200)){
    return (long)(((tval-115600)*10)/(-380));
  }
  if ((tval <= 28200)&&(tval > 19700)){
    return (long)(((tval-93366)*10)/(-283));
  }  
  if ((tval <= 19700)&&(tval > 11600)){
    return (long)(((tval-54800)*10)/(-135));
  }  
  }
```

Autometer 2258 oil temp sender curve (a beta tester was unhappy with the workmanship on the isspro senders so I came up with alternates):

Use a voltage divider setup with the sensor as [R2](https://code.google.com/p/robotmeter/source/detail?r=2) and a ?? ohm resistor as [R1](https://code.google.com/p/robotmeter/source/detail?r=1).

[pdf of autometer curves](http://robotmeter.com/meter/sensorcurves/autometer.pdf)
[OpenOffice document of temp sensor curve figured for the following code](http://robotmeter.com/meter/sensorcurves/autometertempsender.ods)

> //code for autometer 2258 sender
```
  long lookup_oil_temp(long tval){
   tval = tval * 1000
   if (tval <= 84000){
      return (0);
   }
   if (tval >= 854000){
     return (9999);
   }
   if ((tval > 84000) && (tval <= 182860)
     return (long)((tval * 4)/10 + 67400)/100;
   }
   if ((tval > 182860) && (tval <= 290080)
     return (long)((tval * 28)/100 + 89450)/100;
   }
   if ((tval > 290080) && (tval <= 459190)
     return (long)((tval * 24)/100 + 101590)/100;
   }
   if ((tval > 459190) && (tval <= 541800)
     return (long)((tval * 24)/100 + 98580)/100;
   }   
   if ((tval > 541800) && (tval <= 721130)
     return (long)((tval * 28)/100 + 77720)/100;
   } 
   if ((tval > 721130) && (tval <= 853330)
     return (long)((tval * 45)/100 - 46240)/100;
   }    
  }
```