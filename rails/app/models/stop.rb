class Stop < ActiveRecord::Base
  has_many :stoppings
  has_many :trips, :through => :stoppings
  validates_uniqueness_of :mbta_id

  include TimeFormatting

  STOP_ARRIVAL_FINDERS = {
    :bus => BusStopArrivals,
    :commuter_rail => CommuterRailStopArrivals
  }

  # returns a representation of the upcoming arrivals at this stop
  def arrivals(options)
    stoppings = STOP_ARRIVAL_FINDERS[options[:transport_type]].arrivals(self.id, options)
    stoppings.map {|stopping|
      # Discovered the the position field of trips is not reliable. So we must
      # calculate.
      # Would be better if we fixed all the data in the database in one shot.
      trip = stopping.trip
      trip_num_stops = trip.stoppings.count
      position = trip.stoppings.index(stopping) + 1
      {
        :arrival_time => format_time(stopping.arrival_time),
        :trip_id => stopping.trip_id,
        :more_stops => trip_num_stops - position, # trip.num_stops - stopping.position,
        :last_stop => trip.last_stop,
        :position => position # stopping.position
      }
    }
  end

  def self.populate
    Generator.generate('stops.txt') do |row|
      Stop.create :mbta_id => row[0],
        :name => row[2],
        :lat => row[4],
        :lng => row[5]
    end
  end
end
