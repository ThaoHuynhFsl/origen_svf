require 'origen_testers/api'
module OrigenTesters
  module API
    def svf?
      is_a?(OrigenSVF::Tester)
    end
  end
end
