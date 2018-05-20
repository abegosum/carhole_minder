$LOAD_PATH.unshift('.')

require 'carhole_minder'
service = CarholeMinder.new
service.run!
