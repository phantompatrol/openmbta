module Boat

  MBTA_ID_TO_NAME = {
    "Boat-F1" => "Hingham Boat",
    "Boat-F2" => "Quincy Boat",
    "Boat-F2(H)" => "Quincy/Hull Boat",
    "Boat-F4" => "Charlestown Ferry",
  }

  NAME_TO_MBTA_ID = MBTA_ID_TO_NAME.invert

  ROUTE_ID_TO_NAME = MBTA_ID_TO_NAME.inject({}) do |memo, pair|
    mbta_id, name = pair
    route_id = Route.find_by_mbta_id(mbta_id).id
    memo[route_id] = name
    memo
  end

  NAME_TO_ROUTE_ID = ROUTE_ID_TO_NAME.invert

  def self.routes
    service_ids = Service.active_on(Now.date).map(&:id)
    results = ActiveRecord::Base.connection.select_all("select route_id, trips.first_stop, trips.last_stop, count(trips.id) as trips_remaining from trips where trips.route_type = 4 and trips.end_time > '#{Now.time}' and trips.service_id in (#{service_ids.join(',')}) group by route_id, trips.first_stop;").
      group_by {|x| ROUTE_ID_TO_NAME[x["route_id"].to_i] }.
      map { |route_name, values| { :route_short_name  =>  route_name, :headsigns => generate_headsigns(values) }}
  end

  def self.trips(options)
    route_mbta_id = NAME_TO_MBTA_ID[options[:route_short_name]]

    conditions = if options[:headsign]  == "Loop"
      ["routes.mbta_id = ? and first_stop = last_stop and service_id in (?) and end_time > '#{Now.time}'", route_mbta_id, Service.ids_active_today]
    else
      first_stop, last_stop = headsign_to_stops(options[:headsign])
      ["routes.mbta_id = ? and first_stop = ? and last_stop = ? and service_id in (?) and end_time > '#{Now.time}'", route_mbta_id, first_stop, last_stop, Service.ids_active_today]
    end
    Trip.all(:joins => :route,
             :conditions => conditions,
             :order => "start_time asc", 
             :limit => options[:limit] || 10)
  end

  def self.arrivals(stopping_id, options)
    route_mbta_id = NAME_TO_MBTA_ID[options[:route_short_name]]

    conditions = if options[:headsign]  == "Loop"
      ["stoppings.stop_id = ? and routes.mbta_id = ? and first_stop = last_stop and service_id in (?) and trips.first_stop = trips.last_stop and stoppings.arrival_time > '#{Now.time}'", 
        stopping_id, route_mbta_id, Service.ids_active_today]
    else
      first_stop, last_stop = headsign_to_stops(options[:headsign])
      ["stoppings.stop_id = ? and routes.mbta_id = ? and first_stop = ? and last_stop = ? and service_id in (?) and stoppings.arrival_time > '#{Now.time}'", 
        stopping_id, route_mbta_id, first_stop, last_stop, Service.ids_active_today]
    end
    Stopping.all(
      :joins => "inner join trips on trips.id = stoppings.trip_id inner join routes on routes.id = trips.route_id",
      :conditions => conditions,
      :order => "stoppings.arrival_time asc"
    )
  end

  def self.generate_headsigns(values)
    values.map {|x| [generate_headsign(x["first_stop"], x["last_stop"]), x["trips_remaining"].to_i] }
  end

  def self.generate_headsign(first_stop, last_stop)
    first_stop == last_stop ? "Loop" : "#{first_stop} to #{last_stop}"
  end

  def self.headsign_to_stops(headsign)
    first_stop, last_stop = headsign.split(" to ")
  end
end