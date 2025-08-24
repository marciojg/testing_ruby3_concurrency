https://gist.github.com/hungle00/5570866825db537c9b4bb7b913868916 - bom exemplo de apresentação
https://github.com/socketry/async - muito conteudo para ler

Infraestrutura dos containers
```
barco-1   | [1] Puma starting in cluster mode...
barco-1   | [1] * Puma version: 6.6.1 ("Return to Forever")
barco-1   | [1] * Ruby version: ruby 3.4.5 (2025-07-16 revision 20cda200d3) +PRISM [x86_64-linux]
barco-1   | [1] *  Min threads: 5
barco-1   | [1] *  Max threads: 5
barco-1   | [1] *  Environment: development
barco-1   | [1] *   Master PID: 1
barco-1   | [1] *      Workers: 1
barco-1   | [1] *     Restarts: (✔) hot (✖) phased (✖) refork
barco-1   | [1] * Preloading application
porto1-1  | Puma starting in single mode...
porto1-1  | * Puma version: 6.6.1 ("Return to Forever")
porto1-1  | * Ruby version: ruby 3.2.9 (2025-07-24 revision 8f611e0c46) [x86_64-linux]
porto1-1  | *  Min threads: 0
porto1-1  | *  Max threads: 5
porto1-1  | *  Environment: development
porto1-1  | *          PID: 1
porto1-1  | * Listening on http://0.0.0.0:4000
porto1-1  | Use Ctrl-C to stop
```

Benchmark
```
Rehearsal ----------------------------------------------------------------
call_via_restclient            0.046162   0.027976   0.074138 ( 16.587289)
call_via_restclient_parallel   0.023261   0.014011   0.037272 (  6.058636)
call_via_restclient_async      0.017558   0.017434   0.034992 (  4.033461)
call_via_httpx                 0.014253   0.001162   0.015415 ( 16.024834)
call_via_httpx_v2              0.010725   0.001509   0.012234 ( 16.022101)
call_via_httpx_fibers          0.011317   0.004243   0.015560 (  4.012599)
call_via_httpx_async           0.010885   0.003688   0.014573 (  4.013234) <----- The best and simplest
call_via_async_http            0.026542   0.010718   0.037260 ( 16.054831)
------------------------------------------------------- total: 0.241444sec

                                   user     system      total        real
call_via_restclient            0.023968   0.020015   0.043983 ( 16.201920)
call_via_restclient_parallel   0.016223   0.017567   0.033790 (  6.057054)
call_via_restclient_async      0.020892   0.009372   0.030264 (  4.070013)
call_via_httpx                 0.014220   0.000143   0.014363 ( 16.026375)
call_via_httpx_v2              0.011527   0.001677   0.013204 ( 16.112581)
call_via_httpx_fibers          0.011708   0.003698   0.015406 (  4.108287)
call_via_httpx_async           0.010335   0.000222   0.010557 (  4.012291) <----- The best and simplest
call_via_async_http            0.025884   0.008940   0.034824 ( 16.052878)
172.21.0.1 - - [24/Aug/2025:23:24:38 +0000] "POST /benchmark HTTP/1.1" 200 20 166.7580
```
