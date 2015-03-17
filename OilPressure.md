#How the oil pressure senders work

##### Oil Pressure #####

The preferred oil pressure sender is a defi unit. These things are pricey, but very well made.  Note that the curve given here was not willingly given (an email exchange resulted in them not providing me with datasheets.  All other manufacturers listed provided me with datasheets) by defi/nippon-seiki and was obtained by checking measurements and looking at the few datasheets available on the nippon seiki webpage(http://www.nippon-seiki.co.jp/e_keiki/press/mid_p_e.pdf).

```
long lookup_oil_psi(long psival){
 if (psival < 102){
   return 0;
 }
 if (psival > 922){
  return 9999; 
 }
 else {
  return (psival*14)/10 - 144;
 }
}
```

The 2nd preferred oil pressure sender is an autometer 100 psi unit model #2242.

[Autometer curves](http://robotmeter.com/meter/sensorcurves/autometer.pdf)

This sender is set up in a voltage divider with the sensor as [R2](https://code.google.com/p/robotmeter/source/detail?r=2) and [R1](https://code.google.com/p/robotmeter/source/detail?r=1) as a 100 Ohm resistor.
```
  long lookup_oil_psi(long psival){
   if (psival > 722){
     return (0);
   }
   if (psival < 257){
     return(9999);
   }
   if ((psival <= 722)&&(psival > 619)) {
     return 1747 - (psival*240)/100; 
   } 
   if ((psival <= 619)&&(psival > 520)) {
     return 1802 - (psival*250)/100;
   }
   if ((psival <= 520)&&(psival > 411)) {
     return 1694 - (psival*230)/100;     
   }
   if ((psival <= 411)&&(psival > 257)){
     return 1418 - (psival*160)/100;
   }
  }
```
Oil pressure sender used is an ISSPRO 33-240 Ohm 0-150psi sender.  Any of their senders with these values will work.

[ISSPRO curves](http://robotmeter.com/meter/sensorcurves/R9279FAM.pdf)

This sender is set up in a voltage divider with the sensor as [R2](https://code.google.com/p/robotmeter/source/detail?r=2) and [R1](https://code.google.com/p/robotmeter/source/detail?r=1) as a 100 Ohm resistor.
```
   long lookup_oil_psi(long psival){
   if (psival > 722){
     return (0);
   }
   if (psival < 257){
     return(9999);
   }
   if ((psival <= 722)&&(psival > 619)) {
     return 2620 - (psival*361)/100; 
   } 
   if ((psival <= 619)&&(psival > 520)) {
     return 2703 - (psival*379)/100;
   }
   if ((psival <= 520)&&(psival > 411)) {
     return 2542 - (psival*344)/100;     
   }
   if ((psival <= 411)&&(psival > 257)){
     return 2127 - (psival*244)/100;
   }
   }
```