module DaptivChefCI
  module RakeTaskHelpers
    extend self
    
    def execute(&block)
      begin
        block.call()
      rescue SystemExit => ex
        exit(ex.status)
      rescue Exception => ex
        STDERR.puts("#{ex.message} (#{ex.class})")
        STDERR.puts(ex.backtrace.join("\n"))
        exit(1)
      end
    end
    
  end
end