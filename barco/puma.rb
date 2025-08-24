# Quantidade de workers (processos). 0 = desabilitado
workers Integer(ENV.fetch("WEB_CONCURRENCY", 1))

# Threads mínimas e máximas por worker
threads_count = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
threads threads_count, threads_count

# Porta e bind
port ENV.fetch("PORT", 4000)

# Ambiente
environment ENV.fetch("RACK_ENV", "development")

# Preload app para economizar memória com copy-on-write (quando workers > 0)
preload_app!

# Log
stdout_redirect "/dev/stdout", "/dev/stderr", true

# Tempo de espera entre restarts
worker_timeout 60 if ENV.fetch("RACK_ENV", "development") == "development"
