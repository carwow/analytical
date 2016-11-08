module Analytical
  class SessionCommandStore
    attr_reader :session, :module_key

    def initialize(session, module_key, initial_list=nil)
      @session = session
      @module_key = module_key
      @session_key = ('analytical_'+module_key.to_s).to_sym
      assign(initial_list || [])
    end

    def assign(v)
      self.commands = v
      trim_commands!
    end

    def commands
      trim_commands!
      @session[@session_key]
    end
    def commands=(v)
      @session[@session_key] = v
      trim_commands!
    end

    def flush
      self.commands = []
    end

    def remove(processed_commands)
      self.commands -= processed_commands
    end

    # Pass any array methods on to the internal array
    def method_missing(method, *args, &block)
      commands.send(method, *args, &block).tap { trim_commands! }
    end

    private

    # Make sure to not exceed ~1KB of session storage use (max cookie is 4KB)
    def trim_commands!
      serialized_length = @session[@session_key].inspect.length
      return unless serialized_length > 1000
      @session[@session_key] = @session[@session_key][0..-2]
      trim_commands!
    end

  end
end
