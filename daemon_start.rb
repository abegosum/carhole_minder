
require_relative 'carhole_minder'
require_relative 'service_frontend'
require_relative 'constants'
require 'drb/drb'

SERVICE_SAFE = 3

daemon_object = CarholeMinder.new

drb_front_object = ServiceFrontend.new(daemon_object)

#DRb.start_service("druby://localhost:#{DRB_PORT}", drb_front_object, SERVICE_SAFE)
DRb.start_service("druby://localhost:#{DRB_PORT}", drb_front_object)

daemon_object.run!
