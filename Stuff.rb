module Base

  def initialize args
    update args
  end

  def update args
    args.each do |k,v|
      instance_variable_set "@#{k}", v if respond_to? k
    end
  end

end


class Person
  attr_accessor :firstname, :lastname, :age
  include Base
end


class Dog
  attr_accessor :name, :age
  include Base
end
