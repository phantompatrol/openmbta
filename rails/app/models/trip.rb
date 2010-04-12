class Trip < ActiveRecord::Base
  include Comparable
  extend TimeFormatting
  belongs_to :route
  belongs_to :service
  has_many :stoppings, :order => "position asc"
  has_many :stops, :through => :stoppings, :order => "stoppings.position asc"

  def stops_with_times
    stoppings.map {|stopping| 
      [stopping.stop.name, stopping.time]
    }
  end

  def print_stops
    stops_with_times.each {|x|
      puts "%s %s" % [x[1], x[0]]
    }
  end

  def start_time
    self.attributes_before_type_cast["start_time"]
  end

  def end_time
    self.attributes_before_type_cast["end_time"]
  end

  def <=>(other) 
    self.start_time <=> other.start_time
  end 


  def self.populate
    file = 'trips.txt'
    fields = Generator.get_fields(file)

    Generator.generate(file) do |row|
      route = Route.find_by_gtfs_id row[fields[:route_id]]
      service = Service.find_by_gtfs_id row[fields[:service_id]]
      Trip.create :route => route,
        :service => service,
        :gtfs_id => row[fields[:trip_id]],
        :headsign => (fields[:trip_headsign] == nil ? nil : row[fields[:trip_headsign]])
    end
  end

  def self.batch_create(route, service)

  end

  named_scope :missing_stops_summary, :conditions => "start_time is null or end_time is null"

  def self.denormalize
    self.all.each {|trip| trip.denormalize}
  end

  def denormalize
    self.denorm_service_days
    return if self.stoppings.empty?

    first_stopping = self.stoppings.first(:order => 'position asc')
    last_stopping = self.stoppings.first(:order => 'position desc')
    num_stops = self.stoppings.count

    self.update_attributes :first_stop => first_stopping.stop.name,
      :last_stop => last_stopping.stop.name,
      :num_stops => num_stops,
      :route_type => self.route.route_type

    self.raw_update(first_stopping, last_stopping)
    print '.'
  end

  def self.populate_nil_headsigns
    self.all.each {|trip| trip.populate_nil_headsign}
  end

  def populate_nil_headsign
    return if self.headsign != nil

    self.update_attribute(:headsign, Trip.generate_headsign(self.first_stop, self.last_stop))
  end

  named_scope :with_null_start_time, :conditions => "start_time is null"

  # We use this raw sql creation method because Rails can't handle MySQL time type for values >= 24:00:00 (i.e., a.m. stop times)
  def raw_update(first_stopping, last_stopping)
    stmt = "update trips set start_time = '#{first_stopping.arrival_time}', end_time = '#{last_stopping.arrival_time}' where id = #{self.id}"
    puts "Executing #{stmt}"
    self.connection.execute(stmt)
  end

  def denorm_service_days
    return unless service
    sched_type = if service.monday
                   "weekday"
                 elsif service.saturday
                   "saturday"
                 elsif service.sunday
                   "sunday"
                 end
    if service.start_date == service.end_date
      sched_type = "holiday"
    end
    params = { :service_start_date => service.start_date,
      :service_end_date => service.end_date, 
      :schedule_type => sched_type
    }
    update_attributes params
  end

  def inspect
    "<Trip #{id}; #{headsign}; #{first_stop} #{start_time} => #{last_stop} #{end_time}>" 
  end

  def self.generate_headsigns(values)
    values.map {|x| [generate_headsign(x["first_stop"], x["last_stop"]), x["trips_remaining"].to_i] }
  end

  def self.generate_headsign(first_stop, last_stop)
    "#{first_stop} to #{last_stop}"
  end

  def self.headsign_to_stops(headsign)
    first_stop, last_stop = headsign.split(" to ")
  end

end
