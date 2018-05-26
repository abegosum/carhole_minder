require 'rpi_gpio'
require 'constants'

class ButtonListenerService
	attr_reader :button_pin
  attr_reader :button_name
  attr_accessor :long_press_lambda
  attr_accessor :long_press_delay
	
	def initialize(button_pin, button_name)
		@button_pin = button_pin
    @button_name = button_name
    @long_press_delay = LONG_PRESS_SECONDS
	end
		

	def initialize_gpio
		RPi::GPIO.setup button_pin, :as => :input
		@gpio_is_initialized = true
	end

	def button_pressed?
		RPi::GPIO.low? button_pin
	end

	def wait_for_button_release
    start_wait_time = Time.now.to_i
		loop do
      unless start_wait_time.nil?
        seconds_past = Time.now.to_i - start_wait_time
        if seconds_past >= @long_press_delay
          puts "Long press of #{button_name} detected"
          long_press_lambda.call unless long_press_lambda.nil?
          start_wait_time = nil
        end
      end
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
