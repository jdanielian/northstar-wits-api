
Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/models/validators/**/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/models/contracts/**/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }



