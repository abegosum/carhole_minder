
require_relative 'carhole_minder'
require_relative 'constants'
require 'drb/drb'

service = CarholeMinder.new

DRb.start_service("druby://localhost:#{DRB_PORT}", service)

service.run!
