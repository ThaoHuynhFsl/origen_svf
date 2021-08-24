module OrigenSVF
  class Tester
    include OrigenTesters::VectorBasedTester

    def initialize
      @pat_extension = 'svf'
      @compress = false
      @comment_char = '//'
    end

    def subdirectory
      'svf'
    end

    def pattern_header(options = {})
      microcode 'PIOMAP ('
      ordered_pins.each do |pin|
        if pin.direction == :input
          l = 'IN'
        elsif pin.direction == :output
          l = 'OUT'
        else
          l = 'INOUT'
        end
        microcode "  #{l} #{pin.name.upcase}"
      end
      microcode ');'
      microcode ''
      microcode 'TRST ABSENT;'
      microcode 'ENDIR IDLE;'
      microcode 'ENDDR IDLE;'
    end

    def set_timeset(name, period_in_ns)
      super
      f = (1 / (period_in_ns / 1_000_000_000.0)).ceil
      microcode "FREQUENCY #{f} HZ;"
    end

    def delay(cycles, options = {})
      microcode "RUNTEST #{cycles} TCK;"
    end

    def write_ir(reg_or_val, options = {})
      microcode "SIR #{size(reg_or_val, options)} TDI(#{data(reg_or_val)});"
    end

    def write_dr(reg_or_val, options = {})
      if reg_or_val.has_overlay?
        cc "Overlay on ATE: #{reg_or_val.overlay_str}"
      end
      microcode "SDR #{size(reg_or_val, options)} TDI(#{data(reg_or_val)});"
    end

    def read_ir(reg_or_val, options = {})
      microcode "SIR #{size(reg_or_val, options)} TDO(#{data(reg_or_val)}) MASK(#{mask(reg_or_val, options)});"
    end

    def read_dr(reg_or_val, options = {})
      if reg_or_val.has_overlay?
        cc "Overlay on ATE: #{reg_or_val.overlay_str}"
      end
      microcode "SDR #{size(reg_or_val, options)} TDO(#{data(reg_or_val)}) MASK(#{mask(reg_or_val, options)});"
    end

    def pattern_footer(options = {})
    end

    def cycle(options = {})
      v = ''
      ordered_pins.each do |pin|
        if pin.state == :dont_care
          if pin.direction == :output
            v += 'X'
          else
            v += 'Z'
          end
        elsif pin.state == :drive
          if pin.data == 0
            v += 'L'
          else
            v += 'H'
          end
        elsif pin.state == :compare
          if pin.data == 0
            v += 'D'
          else
            v += 'U'
          end
        else
          fail "Unknown pin state: #{pin.state}"
        end
      end
      microcode "PIO (#{v})"
      delay(options[:repeat]) if options[:repeat] && options[:repeat] > 1
    end

    def microcode(str)
      if str.length > 80
        str.scan(/.{1,80}/).each do |line|
          super(line)
        end
      else
        super
      end
    end
    def handshake(options = {})
      ss 'Tester handshake is not support.  Add comment here to highlight'
    end

    def start_subroutine(name)
        local_subroutines << name.to_s.chomp unless local_subroutines.include?(name.to_s.chomp) || @inhibit_vectors
        # name += "_subr" unless name =~ /sub/
        ::Pattern.open name: name, call_startup_callbacks: false, subroutine: true
      end

      # Ends the current subroutine that was started with a previous call to start_subroutine
      def end_subroutine(_cond = false)
        ::Pattern.close call_shutdown_callbacks: false, subroutine: true
      end
# Returns an array of subroutines created by the current pattern
      def local_subroutines # :nodoc:
        @local_subroutines ||= []
      end

      def loop_vectors(name = nil, number_of_loops = 1, _global = false)
        # The name argument is present to maych J750 API, sort out the
        unless name.is_a?(String)
          name, number_of_loops, global = nil, name, number_of_loops
        end
        if number_of_loops > 1
          cc "Looping is not support by SVF.  Add comment here to highligh."
          cc "LOOPING #{name} #{number_of_loops} times"
          yield
          cc "END LOOPING #{name}"
        else
          yield
        end
      end
      alias_method :loop_vector, :loop_vectors



    private

    def data(reg_or_val, options = {})
      unless reg_or_val.is_a? Numeric
      if reg_or_val.has_overlay?
        debugger
      end
      end
      d = reg_or_val.respond_to?(:data) ? reg_or_val.data : reg_or_val
      d.to_s(16).upcase
    end

    def mask(reg_or_val, options = {})
      if reg_or_val.respond_to?(:shift_out_left)
        v = 0
        reg_or_val.shift_out_left do |bit|
          v <<= 1
          v |= 1 if bit.is_to_be_read?
        end
        v.to_s(16).upcase
      else
        ((1 << size(reg_or_val, options)) - 1).to_s(16).upcase
      end
    end

    def size(reg_or_val, options = {})
      options[:size] || reg_or_val.size
    end

  end
end
