# IB MoonBit API Wrapper - WebAssembly Target

**Purpose**: This is the WebAssembly target-specific implementation of IB TWS/Gateway API wrapper for MoonBit.

## Why This Project Exists?

Due to a MoonBit language limitation, the main [ibmoon](../ibmoon) project cannot use target-specific FFI implementations when building with explicit targets. This project provides a working WebAssembly implementation that uses WebAssembly FFI layer directly.

**See the [main ibmoon project](../ibmoon) for complete documentation on the FFI limitation and why multiple target-specific projects are needed.**

## Features

- **Target**: WebAssembly (wasm-gc)
- **FFI Implementation**: Uses WebAssembly host functions for socket operations
- **Use Case**: Browser environments, web applications
- **Portability**: Runs in any WebAssembly-compatible runtime

## Installation

```bash
# Add this project as a dependency in your moon.pkg.json
{
  "import": [
    {
      "path": "../ibmoonwa",
      "alias": "ibmoon"
    }
  ]
}
```

## Building

```bash
# Build for WebAssembly target
moon build --target wasm-gc

# Run tests
moon test --target wasm-gc
```

## Usage

```moonbit
import "ibmoon"

// Create client
let config = ibmoon::connection_config("127.0.0.1", 7496, 1, None)
let client = ibmoon::new_client(config)

// Connect
match ibmoon::client_connect(client) {
  Ok(client) => {
    println("Connected to IB TWS/Gateway")
    
    // Set up callbacks
    let client = ibmoon::set_managed_accounts_callback(client, fn(accounts : String) {
      println("Accounts: " + accounts)
    })
    
    // Request managed accounts
    match ibmoon::req_managed_accounts(client) {
      Ok(_) => {
        // Process messages
        for i = 0; i < 10; i = i + 1 {
          ibmoon::client_process_messages(client)
        }
      }
      Err(e) => ()
    }
    
    // Disconnect
    ibmoon::client_disconnect(client)
  }
  Err(e) => {
    println("Failed to connect")
  }
}
```

## Running Examples

```bash
# Run managed accounts example
moon run --target wasm-gc cmd/main/example_managed_accounts

# Run account summary example
moon run --target wasm-gc cmd/main/example_account_summary

# Run positions example
moon run --target wasm-gc cmd/main/example_positions
```

## Prerequisites

- **WebAssembly Runtime**: Any WebAssembly-compatible runtime (browsers, Node.js, wasmtime, etc.)
- **IB TWS or IB Gateway**: Must be running and configured with API access
- **API Port**: Default is 7496 for paper trading, 7497 for live trading
- **API Connections**: Must be enabled in TWS/Gateway settings
- **Host Functions**: Runtime must provide socket host functions (see socket.wat)

## Testing with Live IB API

To test with a live IB API:

1. Start IB TWS or IB Gateway
2. Enable API connections on port 7496
3. Ensure client ID is not already in use
4. Run integration test:

```bash
moon test --target wasm-gc
```

## Architecture

### Socket Layer
- **File**: `socket.mbt`
- **FFI File**: `socket.wat` (WebAssembly Text format)
- **Implementation**: Uses WebAssembly host functions for socket operations
- **Host Functions Required**:
  - `ibmoon_socket_connect`
  - `ibmoon_socket_send`
  - `ibmoon_socket_receive`
  - `ibmoon_socket_close`

### Core Files
All core IB API files are included:
- `types.mbt` - Data types for contracts, orders, etc.
- `orders.mbt` - Order types and helpers
- `protocol.mbt` - Message protocol definitions
- `encoder.mbt` - Message encoding
- `decoder.mbt` - Message decoding
- `client.mbt` - Connection and client management
- `api.mbt` - High-level API wrapper
- `handlers.mbt` - Message handlers for callbacks

## WebAssembly-Specific Notes

- **Runtime**: Requires WebAssembly-compatible runtime
- **Host Functions**: Socket operations are provided by host environment
- **Browser Limitations**: Direct TCP connections from browser are restricted
  - Use WebSocket proxy for browser-based applications
  - Consider using [ibmoonjs](../ibmoonjs) for Node.js environments
- **Memory**: Linear memory model, careful with buffer management
- **Error Handling**: WebAssembly traps are converted to MoonBit `Result` types
- **Socket Lifecycle**: Sockets must be explicitly closed to free resources

## Browser Usage

**Important**: Direct TCP socket connections are restricted in web browsers. To use ibmoonwa in a browser:

1. **WebSocket Proxy**: Set up a WebSocket proxy that forwards to IB API
2. **Modified Socket Implementation**: Replace socket layer with WebSocket-based implementation
3. **CORS Configuration**: Ensure proxy handles CORS properly
4. **Security**: Browser applications must handle authentication securely

Alternatively, for server-side Node.js applications, use [ibmoonjs](../ibmoonjs) instead.

## Runtime Support

### Browsers
- Chrome, Firefox, Safari, Edge (modern versions)
- Requires WebSocket proxy for network access
- Good for client-side trading interfaces

### Node.js
- Supported via `wasmtime` or similar WebAssembly runtime
- Slower than native JavaScript (ibmoonjs)
- Use [ibmoonjs](../ibmoonjs) for better Node.js performance

### Standalone Runtimes
- `wasmtime` - Standalone WebAssembly runtime
- `wasmer` - High-performance WebAssembly runtime
- `wasmtime` - Fast and lightweight

## Performance Characteristics

- **Connection Speed**: Moderate (WebAssembly overhead)
- **Message Throughput**: Good (near-native with optimization)
- **Memory Usage**: Low (compact WebAssembly binary)
- **CPU Usage**: Efficient (WebAssembly execution)

## Limitations

- **Browser TCP**: Direct TCP connections not supported in browsers
- **Host Functions**: Requires runtime to provide socket host functions
- **Debugging**: More difficult than native targets
- **Tooling**: Less mature than JavaScript or C tooling

## When to Use ibmoonwa

### Use ibmoonwa When:
- Building browser-based trading interfaces with WebSocket proxy
- Need portable binary that runs on any WebAssembly runtime
- Targeting environments where JavaScript runtime is not available
- Want smallest possible binary size

### Use ibmoonjs When:
- Building Node.js server applications
- Need better performance in Node.js environment
- Want easier debugging and development experience

### Use ibmoonc When:
- Building native applications for Linux/macOS
- Need maximum performance
- Targeting production server environments

## Related Projects

- **[ibmoon](../ibmoon)** - Main project with complete documentation
- **[ibmoonjs](../ibmoonjs)** - JavaScript/Node.js target for server-side apps
- **[ibmoonc](../ibmoonc)** - C/Native target for native performance

## License

Apache-2.0 - See [LICENSE](LICENSE) file for details

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## Support

- **Documentation**: See [ibmoon/docs](../ibmoon/docs) for comprehensive documentation
- **Issues**: Report issues in the main [ibmoon](../ibmoon) repository
- **FFI Details**: See [ibmoon/docs/FFI_INTEGRATION_GUIDE.md](../ibmoon/docs/FFI_INTEGRATION_GUIDE.md)