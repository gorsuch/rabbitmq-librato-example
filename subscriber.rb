require 'bunny'
require 'datalogger'
require 'json'
require 'librato/metrics'

DataLogger::Logger.component = 'librato-rand-subscriber'

Librato::Metrics.authenticate ENV['LIBRATO_EMAIL'], ENV['LIBRATO_KEY']

def queue_size(queue)
  queue.queued.inject(0) { |result, data| result + data.last.size }
end

c = Bunny.new(ENV['RABBITMQ_URL'])
c.start
c.qos

e = c.exchange('')
q = c.queue('metrics')

librato_queue = Librato::Metrics::Queue.new

while true do
  q.subscribe(ack: true, message_max: 10) do |msg|
    metric = JSON.parse(msg[:payload])
    DataLogger::Logger.log(action: 'recieve-from-rabbitmq', metric: metric)
    librato_queue.add metric
    DataLogger::Logger.log(action: 'add-to-librato', metric: metric)
  end
  
  DataLogger::Logger.log(action: 'submit-to-librato', size: queue_size(librato_queue)) do
    librato_queue.submit
  end
end
