class ProgressBar
  class Output
    DEFAULT_OUTPUT_STREAM = $stdout

    attr_accessor :stream

    def initialize(options = {})
      self.bar    = options[:bar]
      self.stream      = options[:output] || DEFAULT_OUTPUT_STREAM
      self.length_calculator = LengthCalculator.new(options)
      self.throttle    = Throttle.new(options.merge(:timer => options[:timer]))
    end

    def self.detect(options = {})
      if (options[:output] || DEFAULT_OUTPUT_STREAM).tty?
        TtyOutput.new(options)
      else
        NonTtyOutput.new(options)
      end
    end

    def log(string)
      clear
      stream.puts string

      refresh(:force => true) unless bar.stopped?
    end

    def clear_string
      "#{" " * length_calculator.length}"
    end

    def length
      length_calculator.length
    end

    def with_refresh
      yield
      refresh
    end

    def refresh(options = {})
      clear if length_calculator.length_changed?

      throttle.choke(:force_update_if => (bar.stopped? || options[:force])) do
        stream.print bar_update_string + eol
        stream.flush
      end
    end

    protected

    attr_accessor :length_calculator,
                  :throttle,
                  :bar
  end
end
