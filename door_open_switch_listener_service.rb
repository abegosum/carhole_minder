require 'rpi_gpio'
require_relative 'constants'

DOOR_DELAYS = [TIMER_SETTING_1_MINUTES, TIMER_SETTING_2_MINUTES, TIMER_SETTING_3_MINUTES]

class DoorOpenSwitchListenerService

  attr_reader :timer_setting

  def initialize(timer_setting)
    @timer_setting = timer_setting
  end

  def disble_timer
    @service_thread[:timer_enabled] = false unless @service_thread.nil?
    if @service_thread
      puts "Disabling Timer"
    else
      puts "Service Not Defined"
    end
  end

  def enable_timer
    @service_thread[:timer_enabled] = true unless @service_thread.nil?
    if @service_thread
      puts "Enabling Timer"
    else
      puts "Service Not Defined"
    end
  end

  def toggle_timer
    unless @service_thread.nil?
      @service_thread[:timer_enabled] = ! @service_thread[:timer_enabled]
    end
  end

	def initialize_gpio
		RPi::GPIO.setup DOOR_OPEN_SWITCH_PIN, :as => :input
    RPi::GPIO.setup TIMER_BUTTON_LED_PIN, :as => :output
    turn_on_timer_button_led
		@gpio_is_initialized = true
	end

  def turn_on_timer_button_led
    RPi::GPIO.set_high TIMER_BUTTON_LED_PIN
  end

  def turn_off_timer_button_led
    RPi::GPIO.set_low TIMER_BUTTON_LED_PIN
  end

  def start_blinking_timer_button
    @button_blink_thread = Thread.new do
      current_thread = Thread.current
      while ! current_thread[:stop]
        turn_off_timer_button_led
        sleep TIMER_BUTTON_BLINK_DURATION
        turn_on_timer_button_led
        sleep TIMER_BUTTON_BLINK_DURATION
      end
      turn_on_timer_button_led
    end if @button_blink_thread.nil?
  end

  def stop_blinking_timer_button
    @button_blink_thread[:stop] = true unless @button_blink_thread.nil?
    @button_blink_thread = nil
    turn_on_timer_button_led
  end

  def door_open?
    RPi::GPIO.low? DOOR_OPEN_SWITCH_PIN
  end

  def delay_in_seconds
    DOOR_DELAYS[@timer_setting] * 60
  end

  def get_timer_setting_index
    @timer_setting
  end

  def update_timer_setting(setting_index)
    enable_timer unless setting_index == TIMER_DISABLED_INDICATOR
    @timer_setting = setting_index
    @service_thread[:delay_seconds] = delay_in_seconds unless @service_thread.nil?
  end

  def reset_timer
    @door_open_detected_time = nil
    @timer_has_been_tripped = false
  end

  def start_door_open_switch_listener
    initialize_gpio unless @gpio_is_initialized
    stop_blinking_timer_button
    @service_thread = Thread.new do 
      current_thread = Thread.current
      current_thread[:timer_enabled] = true
      while ! current_thread[:stop]
        if door_open?
          puts "Door opened" unless @door_open_detected_time
          start_blinking_timer_button
          @door_open_detected_time = Time.now.to_i unless @door_open_detected_time
          if current_thread[:delay_seconds] && current_thread[:timer_enabled]
            seconds_since_open = Time.now.to_i - @door_open_detected_time
            if (seconds_since_open > current_thread[:delay_seconds]) && !@timer_has_been_tripped
              @timer_has_been_tripped = true
              yield
            end
          end
        else
          puts "Door closed" unless @door_open_detected_time.nil?
          reset_timer
          stop_blinking_timer_button
        end
				sleep LOOP_DELAY
      end
      puts "Service stopped"
    end
    update_timer_setting(timer_setting)
  end


  private
  @service_thread = nil
  @button_blink_thread = nil
  @door_open_detected_time = nil
  @gpio_is_initialized = false
  @timer_has_been_tripped = false

end
