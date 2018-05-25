$LOAD_PATH.unshift('.')

require 'daemons'
require 'carhole_minder'

Daemons.run('daemon_start.rb')
