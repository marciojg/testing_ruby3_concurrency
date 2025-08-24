require "sinatra"
require "rest-client"
require "parallel"
require "httpx"
require "json"
require "async"
require "async/http/internet/instance"

require "memory_profiler"
require "stackprof"
require "benchmark"

include HTTPX

def report_with_memory_profiler(method_name, &block)
  MemoryProfiler.start
  responses = yield
  report = MemoryProfiler.stop
  report.pretty_print(to_file: "./tmp/memory_profiler_#{method_name}.txt")
  responses
end

def report_with_stackprof(method_name, &block)
  StackProf.start(mode: :cpu)
  responses = yield
  StackProf.stop
  StackProf.results("/tmp/#{method_name}.dump")
  responses
end

post "/quote/:method" do
  report_with_memory_profiler(params[:method]) do
    send(params[:method])
  end

  responses = report_with_stackprof(params[:method]) do
    send(params[:method])
  end

  status 200
  "[#{params[:method]}] Executados #{responses.size} POSTs em porto/price"
end

def benchmark
  Benchmark.bm do |x|
    x.report { send("call_via_restclient") }
    x.report { send("call_via_restclient_parallel") }
    x.report { send("call_via_restclient_async") }
    x.report { send("call_via_httpx") }
    x.report { send("call_via_httpx_v2") }
    x.report { send("call_via_httpx_fibers") }
    x.report { send("call_via_httpx_async") }
    x.report { send("call_via_async_http") }
  end

  status 200
  "Benchmark concluído"
end

# teste 1 = 16:26
def call_via_restclient
  responses = []

  16.times do
    responses << RestClient.post(
      "http://porto1:4000/price",
      {}.to_json,                    # <- payload como JSON string
      { content_type: :json }         # <- define Content-Type corretamente
    )
  end

  responses
end

# teste 1 = 6:10
def call_via_restclient_parallel
  parallel_attributes = {
    in_threads: 3,
    isolation: true
  }

  results = Parallel.map(1..16, parallel_attributes) do
    RestClient.post(
      "http://porto1:4000/price",
      {}.to_json,                    # <- payload como JSON string
      { content_type: :json }         # <- define Content-Type corretamente
    )
  end

  results
end

# teste 1 = 4:08
def call_via_restclient_async
  # testando o rest client usando async para aplicar concorrencia
  responses = []

  Async do
    16.times do
      Async do
        responses << RestClient.post(
          "http://porto1:4000/price",
          {}.to_json,                    # <- payload como JSON string
          { content_type: :json }         # <- define Content-Type corretamente
        )
      end
    end
  end

  responses
end

# teste 1 = 16:03
def call_via_httpx
  # tentativa 1 - com httpx puro, continua sequencial
  # cria 16 UTIs
  requests = (1..16).map do |i|
    [:post, "http://porto1:4000/price", json: {}]
  end
  responses = HTTPX.request(requests)
  # or, if you want to pass options common to all requests
  # responses = HTTPX.request(requests, max_concurrent_requests: 5)
  responses
end

# teste 1 = 16:10
def call_via_httpx_v2
  # tentativa 2 - outra tetnativa com httpx puro, continua sequencial
  # precisa do import HTTPx
  urls = %w[http://porto1:4000/price] * 16
  $HTTPX_DEBUG = true
  client = Session.new
  requests = urls.map { |url| client.build_request(:post, url, json: {}) }
  responses = client.request(*requests)

  responses
end

# teste 1 = 4:02
def call_via_httpx_fibers
  # aplicando fibers manualmente e httpx, agora usou concorrencia
  Fiber.set_scheduler(Async::Scheduler.new)
  request = [:post, "http://porto1:4000/price", json: {}]
  responses = []

  # Executa 16 requests
  16.times do
    Fiber.schedule do
      responses << HTTPX.request(*request)
    end
  end

  responses
ensure
  Fiber.set_scheduler(nil)
end

# teste 1 = 4:02
def call_via_httpx_async
  # aplicando fibers via gem async e httpx, agora usou concorrencia
  request = [:post, "http://porto1:4000/price", json: {}]
  responses = []

  Async do
    16.times do
      Async do
        responses << HTTPX.request(*request)
      end
    end
  end

  responses
end

# teste 1 = 16:11
def call_via_async_http
  # Prepare the request:
  headers = [['accept', 'application/json']]
  body = JSON.dump({})

  16.times do
    Sync do
      # Issues a POST request:
      response = Async::HTTP::Internet.post("http://porto1:4000/price", headers, body)

      # pp JSON.parse(response.read)
    ensure
      response&.close
    end
  end
end
