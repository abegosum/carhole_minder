require 'rpi_gpio'

BUTTON_PIN = 25
RELAY_PIN = 24
LED_PIN = 2
LOOP_DELAY = 0.01

def initialize_gpio
	RPi::GPIO.set_numbering :bcm
	RPi::GPIO.setup BUTTON_PIN, :as => :input
	RPi::GPIO.setup RELAY_PIN, :as => :output
	RPi::GPIO.setup LED_PIN, :as => :output
end

def toggle_relay
	if RPi::GPIO.high? RELAY_PIN
		RPi::GPIO.set_low RELAY_PIN
	else
		RPi::GPIO.set_high RELAY_PIN
	end
end

def toggle_led
	if RPi::GPIO.high? LED_PIN
		RPi::GPIO.set_low LED_PIN
	else
		RPi::GPIO.set_high LED_PIN
	end
end

def button_pressed?
	RPi::GPIO.low? BUTTON_PIN
end

def initialize_pins
	RPi::GPIO.set_high RELAY_PIN
	RPi::GPIO.set_low LED_PIN
end

def wait_for_button_release
	loop do
		button_still_pressed = button_pressed?
		puts "Button Released" unless button_still_pressed
		break unless button_still_pressed
		sleep LOOP_DELAY
	end
end

initialize_gpio
initialize_pins

loop do
	if button_pressed?
		toggle_relay
		toggle_led
		puts "Button Pressed"
		wait_for_button_release
	end
	sleep LOOP_DELAY
end
