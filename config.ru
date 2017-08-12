require 'rack'

use Rack::Static, :urls => ['/docs/css', '/docs/lib']
use Rack::Static, :urls => ['/docs/'] , :index => 'index.html'
use Rack::Static, :urls => ['/public/']



require_relative 'app'


PATH_SPLITTER  = '/'.freeze


SimpleLogger.logger.info("server starting up")

run(App.freeze.app)