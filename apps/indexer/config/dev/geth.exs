import Config

~w(config config_helper.exs)
|> Path.join()
|> Code.eval_file()

hackney_opts = ConfigHelper.hackney_options()
timeout = ConfigHelper.timeout(1)

config :indexer,
  block_interval: ConfigHelper.parse_time_env_var("INDEXER_CATCHUP_BLOCK_INTERVAL", "5s"),
  json_rpc_named_arguments: [
    transport:
      if(System.get_env("ETHEREUM_JSONRPC_TRANSPORT", "http") == "http",
        do: EthereumJSONRPC.HTTP,
        else: EthereumJSONRPC.IPC
      ),
    transport_options: [
      http: EthereumJSONRPC.HTTP.HTTPoison,
      urls:
        ConfigHelper.parse_urls_list("ETHEREUM_JSONRPC_HTTP_URLS", "ETHEREUM_JSONRPC_HTTP_URL", "http://localhost:8545"),
      trace_urls:
        ConfigHelper.parse_urls_list(
          "ETHEREUM_JSONRPC_TRACE_URLS",
          "ETHEREUM_JSONRPC_TRACE_URL",
          "http://localhost:8545"
        ),
      eth_call_urls:
        ConfigHelper.parse_urls_list(
          "ETHEREUM_JSONRPC_ETH_CALL_URLS",
          "ETHEREUM_JSONRPC_ETH_CALL_URL",
          "http://localhost:8545"
        ),
      fallback_urls:
        ConfigHelper.parse_urls_list("ETHEREUM_JSONRPC_FALLBACK_HTTP_URLS", "ETHEREUM_JSONRPC_FALLBACK_HTTP_URL"),
      fallback_trace_urls:
        ConfigHelper.parse_urls_list("ETHEREUM_JSONRPC_FALLBACK_TRACE_URLS", "ETHEREUM_JSONRPC_FALLBACK_TRACE_URL"),
      fallback_eth_call_urls:
        ConfigHelper.parse_urls_list(
          "ETHEREUM_JSONRPC_FALLBACK_ETH_CALL_URLS",
          "ETHEREUM_JSONRPC_FALLBACK_ETH_CALL_URL"
        ),
      method_to_url: [
        eth_call: :eth_call,
        debug_traceTransaction: :trace,
        debug_traceBlockByNumber: :trace
      ],
      http_options: [recv_timeout: timeout, timeout: timeout, hackney: hackney_opts]
    ],
    variant: EthereumJSONRPC.Geth
  ],
  subscribe_named_arguments: [
    transport:
      System.get_env("ETHEREUM_JSONRPC_WS_URL") && System.get_env("ETHEREUM_JSONRPC_WS_URL") !== "" &&
        EthereumJSONRPC.WebSocket,
    transport_options: [
      web_socket: EthereumJSONRPC.WebSocket.WebSocketClient,
      url: System.get_env("ETHEREUM_JSONRPC_WS_URL"),
      fallback_url: System.get_env("ETHEREUM_JSONRPC_FALLBACK_WS_URL")
    ]
  ]
