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

## Building the Hardware

I'm working on a full write-up on the hardware build.  Please check back later for more information!

## Project Software Requirements

* Ruby >= 2.3
* Ruby Development Headers
* Bundler

### Installing Requirements

Note that all of the instructions on this page assume that you're running a recent version of Raspbian or another Debian variant on a Raspberry Pi.

1. Install ruby and ruby development headers

        sudo apt-get install ruby ruby-dev

1. Install bundler gem globally

        sudo gem install bundler

## Building and Testing the Software

1. Clone the repository into a local folder

        git clone git@<server>:<path>/carhole_minder.git
        cd carhole_minder

1. Install the Bundled Gems (local to the project or another path, if you prefer)

        bundle install --path=vendor/bundle

1. Copy the default configuration (`constants.rb.default`) to `constants.rb`

        cp constants.rb.default constants.rb

1. Test the software by running the `daemon_start.rb` file

        bundle exec ruby daemon_start.rb


You should now see "Initializing pin states" and "Enabling timer" on the console.  Additionally, the timer and door button LEDs should fully illuminate. 

## Starting on System Startup

You probably don't want to have to login and start your garage managing service every reboot, so edit the `carhole.service` file and change `WorkingDirectory` to the path where you cloned the project.  Additionally, if you cloned the project using any other user than `pi`, modify the `User` and `Group` entries accordingly (any user must be in the `gpio` group for the software to work properly).

Once you've made those changes, copy the service file to `/etc/systemd/system` (using sudo) and reload the the systemd daemon.

```
sudo cp carhole.service /etc/systemd/system/
sudo systemctl daemon-reload
```

You should now be able to see your service status using systemd.

```
sudo systemd status carhole.service
```

Start the service using systemd and enable it to start on boot.

```
sudo systemd start carhole.service
sudo systemd enable carhole.service
```
