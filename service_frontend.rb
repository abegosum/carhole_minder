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
    @carhole_minder.open_or_close_garage_door
  end

  def timer_setting_index
    @carhole_minder.get_timer_setting_index
  end

  def timer_setting_index=(value)
    @carhole_minder.set_timer_setting_index value
  end

  private
  @carhole_minder
end
