require 'bunny'
require 'datalogger'
require 'json'

DataLogger::Logger.component = 'librato-rand-publisher'

c = Bunny.new(ENV['RABBITMQ_URL'])
c.start

e = c.exchange('')

while true do
  DataLogger::Logger.log(action: 'publish') do
    e.publish({ rand: rand(1000) }.to_json, :key => 'metrics')
  end
  sleep rand(10)
end

