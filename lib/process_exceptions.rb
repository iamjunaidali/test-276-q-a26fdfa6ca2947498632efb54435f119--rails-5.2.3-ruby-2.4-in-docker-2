class ProcessExceptions
  TIMESLOT = 15
  attr_accessor :response, :exception, :timestamps

  def initialize(array_of_exceptions = [])
    @data = array_of_exceptions
    @response = []
    @exception = { name: nil, count: nil }
    @timestamps = { timestamp: nil, logs: [] }
  end

  def result
    processing
  end

  private

  def update_timestamps(error_class)
    unless @timestamps[:logs].map{|i| i.has_value?(error_class)}.any?
      @exception[:count] = @exception[:count].to_i + 1
      @timestamps[:logs] << (@exception)
      @exception = {}
    else
      @timestamps[:logs].map {|hash| hash[:count] += 1 if hash[:name] == error_class }
    end
  end

  def sort
    p "a\n"*8
    p @response
    @response.each{|line| line[:logs] = line[:logs].sort{|a, b| a[:name] <=> b[:name]}}.sort!{|a, b| a[:timestamp] <=> b[:timestamp]}
  end

  def processing
    @data.each do |line|
      request_id, tstamp, error_class = line.split(" ")
      exception_time = Time.at(tstamp.to_i).utc
      end_of_hour = exception_time.beginning_of_hour
      @exception[:name] = error_class

      1.upto(4).each do |i|
        end_of_hour = end_of_hour + (TIMESLOT).minutes

        if exception_time.between?((end_of_hour - TIMESLOT.minutes), end_of_hour)
          ts = "#{(end_of_hour - TIMESLOT.minutes).strftime('%H:%M')}-#{end_of_hour.strftime('%H:%M')}"

          unless @response.map { |hash| hash.has_value?(ts) }.any?
            @timestamps[:timestamp] = ts
            update_timestamps(error_class)

            @response << @timestamps
            @timestamps = { timestamp: nil, logs: [] }
          else
            update_timestamps(error_class)
          end

          break
        end
      end
    end

    sort
  end
end
