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
      microcode "SDR #{size(reg_or_val, options)} TDI(#{data(reg_or_val)});"
    end

    def read_ir(reg_or_val, options = {})
      microcode "SIR #{size(reg_or_val, options)} TDO(#{data(reg_or_val)}) MASK(#{mask(reg_or_val, options)});"
    end

    def read_dr(reg_or_val, options = {})
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

    private

    def data(reg_or_val)
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
