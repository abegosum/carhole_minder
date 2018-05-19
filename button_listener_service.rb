require 'rpi_gpio'
require 'constants'

class ButtonListenerService
	attr_reader :button_pin
  attr_reader :button_name
	
	def initialize(button_pin, button_name)
		@button_pin = button_pin
    @button_name = button_name
	end
		

	def initialize_gpio
		RPi::GPIO.setup button_pin, :as => :input
		@gpio_is_initialized = true
	end

	def button_pressed?
		RPi::GPIO.low? button_pin
	end

	def wait_for_button_release
		loop do
			button_still_pressed = button_pressed?
			break unless button_still_pressed
			sleep LOOP_DELAY
		end
    puts "#{button_name} button released"
	end

	def stop_button_listener
		@service_thread[:stop] = true
	end

	def rejoin_service
		@service_thread.join
	end

	def start_button_listener
		initialize_gpio unless @gpio_is_initialized
		@service_thread = Thread.new do
			current_thread = Thread.current
			while ! current_thread[:stop]
				if button_pressed?
          puts "#{button_name} button pressed"
					yield
					wait_for_button_release
				end
				sleep LOOP_DELAY
			end
			puts "Service stopped"
		end
	end


	private
	@gpio_is_initialized = false
	@service_running = false
	@service_thread = nil

end
