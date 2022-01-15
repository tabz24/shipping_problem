require 'csv'
require './shipment'
require './client'

class Distribution

  attr_accessor :capacity, :clients, :shipments, :parcels, :shipment_client_mapping

  MAXIMUM = Float::INFINITY

  def initialize(capacity)
    @capacity = capacity
    @shipments = []
    @shipment_client_mapping = {}
  end

  def run
    read_inputs
    assign_shipments
    write_outputs
  end

  def read_inputs
    @parcels = CSV.read("input.csv", headers: true)
    clients = {}
    # Group all parcels by clients name
    @parcels.each do |parcel|
      clients[parcel['client_name']] = Client.new(parcel['client_name']) if clients[parcel['client_name']].nil?
      clients[parcel['client_name']].total_size = clients[parcel['client_name']].total_size + parcel['weight'].to_i
    end
    @clients = clients.sort_by {|_key, object| -object.total_size}.to_h.values
  end

  def write_outputs
    CSV.open("result.csv", "w") do |file|
      file << @parcels.headers + ['shipment_ref']
      @parcels.each do |parcel|
        parcel[:shipment_ref] = "shipment #{ @shipment_client_mapping[parcel['client_name']]}"
        file << parcel
      end
    end
  end

  def assign_shipments
    while @clients.count > 0
      find_perfect_shipment
    end
  end

  # This method tries all combination of clients to find combination which is closest to
  # shipments total capacity
  def find_perfect_shipment
    gap = MAXIMUM
    selected_subset = nil
    (1..(@clients.length)).to_a.each do |index|
      @clients.combination(index).each do |subset_clients|
        total = subset_clients.map(&:total_size).sum
        if @capacity >= total && @capacity - total < gap
          selected_subset = subset_clients
          gap = @capacity - total
        end
        break if gap == 0
      end
      break if gap == 0
    end
    shipment_id = @shipments.count + 1
    @shipments << Shipment.new(shipment_id, selected_subset)
    selected_subset.each do |client|
      @shipment_client_mapping[client.name] = shipment_id
    end
    update_clients_list selected_subset
  end

  def update_clients_list(selected_clients)
    selected_clients.each do |client|
      @clients.delete(client)
    end
  end

end