module SubwayRoutes
  def self.routes(service_ids)
    results = [{
        :route_short_name => "Commuter Rail Lines",
        :headsigns => ActiveRecord::Base.connection.select_all(
          "select gtfs_id from routes where route_type = 2 order by gtfs_id asc").
          map {|x| x['gtfs_id'].sub(/^CR-/, '')}
     }]
  end
end
