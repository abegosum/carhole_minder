require 'rpi_gpio'
require 'constants'

DOOR_DELAYS = [TIMER_SETTING_1_MINUTES, TIMER_SETTING_2_MINUTES, TIMER_SETTING_3_MINUTES]

class DoorOpenSwitchListenerService

  attr_reader :timer_setting

  def initialize(timer_setting)
    @timer_setting = timer_setting
  end

	def initialize_gpio
		RPi::GPIO.setup DOOR_OPEN_SWITCH_PIN, :as => :input
		@gpio_is_initialized = true
	end

  def door_open?
    RPi::GPIO.low? DOOR_OPEN_SWITCH_PIN
  end

  def delay_in_seconds
    DOOR_DELAYS[timer_setting] * 60
  end

  def update_timer_setting(setting_index)
    @timer_setting = setting_index
    @service_thread[:delay_seconds] = delay_in_seconds unless @service_thread.nil?
  end

  def reset_timer
    @door_open_detected_time = nil
    @timer_has_been_tripped = false
  end

  def start_door_open_switch_listener
    initialize_gpio unless @gpio_is_initialized
    @service_thread = Thread.new do 
      current_thread = Thread.current
      while ! current_thread[:stop]
        if door_open?
          puts "Door opened" unless @door_open_detected_time
          @door_open_detected_time = Time.now.to_i unless @door_open_detected_time
          if current_thread[:delay_seconds]
            seconds_since_open = Time.now.to_i - @door_open_detected_time
            if (seconds_since_open > current_thread[:delay_seconds]) && !@timer_has_been_tripped
              @timer_has_been_tripped = true
              yield
            end
          end
        else
          puts "Door closed" unless @door_open_detected_time.nil?
          reset_timer
        end
				sleep LOOP_DELAY
      end
      puts "Service stopped"
    end
    update_timer_setting(timer_setting)
  end


  private
  @service_thread = nil
  @door_open_detected_time = nil
  @gpio_is_initialized = false
  @timer_has_been_tripped = false

end
