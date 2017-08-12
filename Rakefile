#!/usr/bin/env rake

module RakeUtils
  def self.set_rake_environment(args)

    environment = args[:environment] ||= 'development'
    ENV['RACK_ENV'] =   environment

    require_relative './config/config'
    require_relative 'models'

    environment
  end
end

namespace :server do
  desc 'will start either torqbox web server or puma webserver (if not on jruby). default env is development'
  task :start, [:environment]  do |t,args|

    environment = RakeUtils::set_rake_environment(args)

    if ENV['RUBY_VERSION'] =~ /jruby/
      if environment == 'production' || environment == 'qa' || environment == 'integration'
        current_date = (Time.now.to_f * 1000).to_i.to_s
        if environment == 'production'
          heap_opts = '-J-XX:MaxMetaspaceSize=1024m -J-Xmx2048m -J-Xms2048m'
        else
          heap_opts = '-J-XX:MaxMetaspaceSize=128m -J-Xmx400m -J-Xms400m'
        end
        # super crazy verbose logging, add this -Xlog.exceptions=true -Xlog.backtraces=true -Xerrno.backtrace=true
        jruby_opts = '-J-XX:+CMSClassUnloadingEnabled -Xcompile.invokedynamic=true -Xreify.variables=false   -J-XX:+UseConcMarkSweepGC -J-XX:+CMSParallelRemarkEnabled ' + heap_opts + ' -J-XX:+ScavengeBeforeFullGC -J-XX:+CMSScavengeBeforeRemark  -J-XX:+UseCMSInitiatingOccupancyOnly -J-XX:CMSInitiatingOccupancyFraction=70 -J-server'
        system "bundle exec /home/ubuntu/#{ENV['RUBY_VERSION']}/bin/jruby #{jruby_opts} -J-Dcom.sun.management.jmxremote -J-Dcom.sun.management.jmxremote.authenticate=false -J-Dcom.sun.management.jmxremote.port=9999 -J-Dcom.sun.management.jmxremote.ssl=false  -S rackup -s torquebox -p 8000 -E #{environment} config.ru > ./log/#{environment}.error.log 2>&1 &"
      else
        puts "torqbox server should be listening on port 8000...."
        system "rackup -s torquebox -p 8000 -E #{environment} config.ru  > ./log/#{environment}.error.log 2>&1 &"
      end
    else
      puts "simple server should be listening on port 8000..."
      system "rackup -E #{environment}  -p 8000 config.ru > ./log/#{environment}.error.log"
    end
  end


  task :stop, [:environment] do |t,args|
    #environment = args[:environment] ||= 'development'

    system "kill -9 `ps -ef | grep rackup | grep -v grep | awk '{print $2}'`"

  end

end



