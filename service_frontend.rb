require_relative 'carhole_minder'
require_relative 'constants'

class ServiceFrontend

  def initialize(carhole_minder)
    @carhole_minder = carhole_minder
  end

  def door_open?
    @carhole_minder.door_open?
  end

  def open_or_close_garage_door
    if @carhole_minder.door_open?
      result = :closing
    else
      result = :opening
    end
    @carhole_minder.open_or_close_garage_door
    result
  end

  def timer_settings
    @carhole_minder.timer_settings
  end

  def timer_setting_index
    @carhole_minder.get_timer_setting_index
  end

  def advance_timer_setting
    @carhole_minder.advance_timer_setting_and_update
    @carhole_minder.get_timer_setting_index
  end

  def timer_setting_index=(value)
    @carhole_minder.set_timer_setting_index value
  end

  def seconds_since_last_open
    @carhole_minder.seconds_since_last_open
  end

  def door_last_opened_time
    @carhole_minder.door_last_opened_time
  end

  def door_last_closed_time
    @carhole_minder.door_last_closed_time
  end

  def door_close_attempted_time
    @carhole_minder.door_close_attempted_time
  end

  private
  @carhole_minder
end
