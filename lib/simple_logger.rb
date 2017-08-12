require 'logger'

# for Rack logger to use regular logger this alias needs to be added to basic ::Logger
class ::Logger; alias_method :write, :<<; end

module SimpleLogger
  # This is the magical bit that gets mixed into your classes
  def logger
    SimpleLogger.logger
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.logger=(val)
    @logger = val
  end

  def self.set_logger_info(path, level = Logger::WARN)

    log = Logger.new(path)
    log.level = level

    SimpleLogger.logger=(log)
  end

  def self.get_error_logger(path)
    err_file = File.new(path, 'a+')
    err_file.sync = true

    err_file

  end

end