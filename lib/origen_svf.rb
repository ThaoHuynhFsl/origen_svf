require 'origen'
require_relative '../config/application.rb'
require 'origen_testers'
module OrigenSVF
  # THIS FILE SHOULD ONLY BE USED TO LOAD RUNTIME DEPENDENCIES
  # If this plugin has any development dependencies (e.g. dummy DUT or other models that are only used
  # for testing), then these should be loaded from config/boot.rb
  require 'origen_svf/tester'
  require 'origen_svf/origen_testers/api'
end
