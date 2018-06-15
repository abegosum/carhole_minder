# Carhole Minder

Carhole Minder is a ruby application intended for use on a Raspberry Pi (B, B+, 2B, 3, etc).  It is an internet-enabled garage-door opener and closer with a built in timer and alerting.  

It has been tested with a Liftmaster garage door opener.  The generations of these openers are identified by the color of the "Learn" button on the back.  Mine is a purple button opener.  It may work with other garage door openers (assuming you need only short two wires to send a signal to open the door); but, you're mileage may vary.  I assume NO responsibility for the use of this project by anyone else and simply offer it as open source in the case that someone else can benefit.

## Project Hardware Requirements

To create this project, you'll need the following components:

* A Raspberry Pi (I recycled an old B I had lying around; but, any will do)
* 1 LED for the power indicator 
* 3 LEDs (preferably a different color from the power LED) for timer status indication
* 2 buttons, preferably with built in LEDs (I used [these Adafruit Mini Arcade Buttons](https://www.adafruit.com/product/3429))
* A magnet switch with a "normally open" option, as typically used by alarms (I used [this](http://www.microcenter.com/product/422392/Switch_Magnetic_Alarm))
* A 5V relay module (I used [this](http://www.microcenter.com/product/486581/2_Channel_5V_Relay_Module) as it was in stock at my local electronics store; but, you don't need two relays)

## Project Software Requirements

* Ruby (I used v2.3.3 to build the project, though other versions may or may not work)
* Bundler

## Building and Testing the Software

## Starting on System Startup

## Building the Hardware
