module Utils

  class Base

    def initialize args
      update args
    end

    def update args
      args.each do |k,v|
        instance_variable_set "@#{k}", v if respond_to? k
      end
    end

  end

end
