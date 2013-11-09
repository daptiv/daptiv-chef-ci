module DaptivChefCI
  module RakeTaskHelpers
    extend self
    
    @@exit_on_failure = true
    
    def exit_on_failure
      @@exit_on_failure
    end
    
    def exit_on_failure=(exit_on_failure)
      @@exit_on_failure = exit_on_failure
    end
    
    def execute(&block)
      begin
        block.call()
      rescue SystemExit => ex
        if @@exit_on_failure
          exit(ex.status)
        else
          raise
        end
      rescue Exception => ex
        if @@exit_on_failure
          STDERR.puts("#{ex.message} (#{ex.class})")
          STDERR.puts(ex.backtrace.join("\n"))
          exit(1)
        else
          raise
        end
      end
    end
    
  end
end