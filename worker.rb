require 'datalogger'
require 'librato/metrics'

DataLogger::Logger.component = 'librato-rand'

Librato::Metrics.authenticate ENV['LIBRATO_EMAIL'], ENV['LIBRATO_KEY']

while true do
  begin
    DataLogger::Logger.log(action: 'submit') do     
      Librato::Metrics.submit rand: rand(1000)
    end
    sleep rand(10)
  rescue => e
    puts e
  end
end
