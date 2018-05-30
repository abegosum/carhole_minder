require_relative 'constants'
require_relative 'button_listener_service'
require_relative 'door_open_switch_listener_service'

TIMER_PINS = [ TIMER_SETTING_1_LED, TIMER_SETTING_2_LED, TIMER_SETTING_3_LED ]

class CarholeMinder
  
  attr_reader :timer_setting

  def initialize
    @timer_setting = 0
  end
  
  def init_gpio
    puts 'Setting up GPIO in/out settings'
  	RPi::GPIO.set_numbering :bcm
    RPi::GPIO.setup DOOR_BUTTON_LED_PIN, :as => :output
    RPi::GPIO.setup READY_LED_PIN, :as => :output
    RPi::GPIO.setup RELAY_PIN, :as => :output
    RPi::GPIO.setup TIMER_SETTING_1_LED, :as => :output
    RPi::GPIO.setup TIMER_SETTING_2_LED, :as => :output
    RPi::GPIO.setup TIMER_SETTING_3_LED, :as => :output
  end
  
  def init_pins
    puts 'Initializing pin states'
    turn_off_led READY_LED_PIN
    
    turn_on_led TIMER_SETTING_1_LED 
    turn_off_led TIMER_SETTING_2_LED 
    turn_off_led TIMER_SETTING_3_LED 
  
    RPi::GPIO.set_high RELAY_PIN
  
    set_default_led_state(DOOR_BUTTON_LED_PIN, DOOR_BUTTON_LED_DEFAULT_STATE)
  
    turn_on_led READY_LED_PIN
  end
  
  def set_default_led_state(led_pin, state)
    if state == :on
      RPi::GPIO.set_high led_pin
    else
      RPi::GPIO.set_low led_pin
    end
  end
  
  def turn_on_led(pin_number)
    RPi::GPIO.set_high pin_number
  end
  
  def turn_off_led(pin_number)
    RPi::GPIO.set_low pin_number
  end
  
  def blink_door_button_led
    relay_thread = Thread.new do
      for i in 0..DOOR_OPEN_LIGHT_BLINKS
        puts "Turning off"
        turn_off_led DOOR_BUTTON_LED_PIN
        sleep DOOR_OPEN_LIGHT_BLINK_DURATION
        puts "Turning on"
        turn_on_led DOOR_BUTTON_LED_PIN
        sleep DOOR_OPEN_LIGHT_BLINK_DURATION
      end
    end
  end
  
  def open_or_close_garage_door
    blink_door_button_led
    RPi::GPIO.set_low RELAY_PIN
    sleep RELAY_OPEN_DELAY
    RPi::GPIO.set_high RELAY_PIN
  end

  def close_garage_door_by_timer
    puts "Attempting to close open door"
    open_or_close_garage_door
  end
  
  def update_timer_led_indicator
    highest_index = TIMER_PINS.length - 1
    for i in 0..highest_index
      if i == @timer_setting 
        puts "Turning on LED at #{i} - #{TIMER_PINS[i]}"
        turn_on_led TIMER_PINS[i]
      else 
        puts "Turning off LED at #{i} - #{TIMER_PINS[i]}"
        turn_off_led TIMER_PINS[i]
      end
    end
  end
  
  def advance_timer_setting
    if @timer_setting == (TIMER_PINS.length - 1)
      @timer_setting = 0
    else
      @timer_setting += 1
    end
    update_timer_led_indicator
  end

  def disable_timer
    @timer_setting = TIMER_DISABLED_INDICATOR
    puts "Timer disabled"
    update_timer_led_indicator
  end

  def enable_timer
    @timer_setting = 0
    puts "Timer enabled"
    update_timer_led_indicator
  end

  def timer_disabled?
    @timer_setting == TIMER_DISABLED_INDICATOR
  end

  def toggle_timer
    if timer_disabled?
      enable_timer
    else 
      disable_timer
    end
  end

  def shutdown_service_leds
    turn_off_led READY_LED_PIN
    turn_off_led DOOR_BUTTON_LED_PIN
    turn_off_led TIMER_BUTTON_LED_PIN
    turn_off_led TIMER_SETTING_1_LED
    turn_off_led TIMER_SETTING_2_LED
    turn_off_led TIMER_SETTING_3_LED
  end

  def shutdown_computer
    system '/usr/bin/sudo /sbin/shutdown -h 0'
  end

  def door_open?
    (! @door_open_service.nil?) && @door_open_service.door_open?
  end

  def run!
    Thread.abort_on_exception = true
    init_gpio
    init_pins

    door_button_service = ButtonListenerService.new(DOOR_BUTTON_PIN, 'DOOR_BUTTON')
    door_button_service.long_press_delay = SHUTDOWN_LONG_PRESS_SECONDS
    door_button_service.long_press_lambda = lambda do
      shutdown_service_leds
      shutdown_computer
    end
      
    door_button_service.start_button_listener do 
      open_or_close_garage_door
    end

    @door_open_service = DoorOpenSwitchListenerService.new(timer_setting)
    @door_open_service.start_door_open_switch_listener do
      puts "TIMER REACHED!"
      close_garage_door_by_timer
    end

    timer_button_service = ButtonListenerService.new(TIMER_BUTTON_PIN, 'TIMER_BUTTON')
    timer_button_service.long_press_lambda = lambda do 
      toggle_timer
      @door_open_service.toggle_timer
    end
    timer_button_service.start_button_listener do
      if timer_disabled?
        @door_open_service.reset_timer # prevent instantaneous closing on timer enable
        enable_timer
      else
        advance_timer_setting
      end
      @door_open_service.update_timer_setting timer_setting
      @door_open_service.reset_timer
    end

    Kernel.trap 'SIGTERM' do 
      puts "Trapped Signal"
      shutdown_service_leds
      exit(0)
    end
    
    begin
      while true
        sleep MAIN_THREAD_SLEEP_DELAY
      end
    rescue SignalException => e
      puts "Received Signal Exception #{e}"
      shutdown_service_leds
      exit(0)
    end
  end

  private
  @door_open_service = nil
  
end
