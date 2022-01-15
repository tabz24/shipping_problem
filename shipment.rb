class Shipment
  attr_accessor :id, :clients, :shipment_id

  def initialize(id, clients)
    @id = id
    @clients = clients
  end
end