class Client
  attr_accessor :name, :total_size

  def initialize(name)
    @name = name
    @total_size = 0
  end
end