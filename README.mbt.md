# IB MoonBit API Wrapper - WebAssembly Target

**Purpose**: This is the WebAssembly target-specific implementation of the IB TWS/Gateway API wrapper for MoonBit.

## Why This Project Exists?

Due to a MoonBit language limitation, the main [ibmoon](../ibmoon) project cannot use target-specific FFI implementations when building with explicit targets. This project provides a working WebAssembly implementation that uses the WebAssembly FFI layer directly.

**See the [main ibmoon project](../ibmoon) for complete documentation on the FFI limitation and why multiple target-specific projects are needed.**

## Features

- **Target**: WebAssembly (Wasm)
- **FFI Implementation**: Uses WebAssembly host functions for socket operations
- **Use Case**: Browser environments, WebAssembly runtimes
- **Performance**: Efficient for browser-based applications

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
moon build --target wasm

# Run tests
moon test --target wasm
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
moon run --target wasm cmd/main/example_managed_accounts

# Run account summary example
moon run --target wasm cmd/main/example_account_summary

# Run positions example
moon run --target wasm cmd/main/example_positions
```

## Prerequisites

- **WebAssembly Runtime**: Required for Wasm execution (browser or Wasmtime/WasmEdge)
- **IB TWS or IB Gateway**: Must be running and configured with API access
- **API Port**: Default is 7496 for paper trading, 7497 for live trading
- **API Connections**: Must be enabled in TWS/Gateway settings

## Browser-Specific Setup

**Important**: WebAssembly cannot directly access TCP sockets from the browser. You need to use a WebSocket proxy:

### Option 1: WebSocket Proxy Server

Set up a WebSocket proxy server that forwards connections to IB TWS/Gateway:

```javascript
// Example Node.js proxy server
const WebSocket = require('ws');
const net = require('net');

const wss = new WebSocket.Server({ port: 8080 });

wss.on('connection', (ws) => {
  const client = net.createConnection({ host: '127.0.0.1', port: 7496 });
  
  ws.on('message', (data) => {
    client.write(data);
  });
  
  client.on('data', (data) => {
    ws.send(data);
  });
  
  client.on('close', () => ws.close());
  ws.on('close', () => client.destroy());
});
```

### Option 2: Host Function Integration

For non-browser WebAssembly runtimes (Wasmtime, WasmEdge), you can provide host functions that implement socket operations directly.

## Testing with Live IB API

To test with a live IB API:

1. Start IB TWS or IB Gateway
2. Enable API connections on port 7496
3. Ensure client ID is not already in use
4. Set up WebSocket proxy if running in browser
5. Run integration test:

```bash
moon test --target wasm
```

## Architecture

### Socket Layer
- **File**: `socket.mbt`
- **FFI File**: `socket.wat`
- **Implementation**: Uses WebAssembly host functions for TCP connections

### Core Files
All core IB API files are included:
- `api.mbt` - High-level API wrapper
- `client.mbt` - Connection and client management
- `decoder.mbt` - Message decoding
- `encoder.mbt` - Message encoding
- `handlers.mbt` - Message handlers for callbacks
- `protocol.mbt` - Message protocol definitions
- `socket.mbt` - Socket abstraction layer
- `ibmoon.mbt` - Main package interface

## WebAssembly-Specific Notes

- **Runtime**: Requires WebAssembly runtime environment
- **Host Functions**: Socket operations require host function implementations
- **Browser Limitations**: Cannot directly access TCP sockets from browser
- **WebSocket Proxy**: Required for browser-based applications
- **Memory Management**: WebAssembly linear memory managed by runtime

## Browser Usage Example

```html
<!DOCTYPE html>
<html>
<head>
  <title>IB MoonBit - WebAssembly</title>
</head>
<body>
  <script>
    // Load WebAssembly module
    const response = await fetch('ibmoonwa.wasm');
    const bytes = await response.arrayBuffer();
    const { instance } = await WebAssembly.instantiate(bytes, {
      // Provide host functions for socket operations
      env: {
        socket_connect: (addr, timeout) => { /* ... */ },
        socket_send: (socket, data, len) => { /* ... */ },
        socket_recv: (socket, buffer, len) => { /* ... */ },
        socket_close: (socket) => { /* ... */ }
      }
    });
    
    // Use the module
    // ...
  </script>
</body>
</html>
```

## Limitations

- **Browser TCP Access**: WebAssembly cannot directly access TCP sockets from browser
- **WebSocket Proxy Required**: Browser applications need a WebSocket proxy server
- **Host Function Complexity**: Requires careful implementation of host functions
- **Debugging**: WebAssembly debugging can be more challenging than native code

## Related Projects

- **[ibmoon](../ibmoon)** - Main project with complete documentation
- **[ibmoonjs](../ibmoonjs)** - JavaScript/Node.js target for server-side applications
- **[ibmoonc](../ibmoonc)** - C/Native target for native performance

## License

Apache-2.0 - See [LICENSE](LICENSE) file for details

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## Support

- **Documentation**: See [ibmoon/docs](../ibmoon/docs) for comprehensive documentation
- **Issues**: Report issues in the main [ibmoon](../ibmoon) repository
- **FFI Details**: See [ibmoon/docs/FFI_INTEGRATION_GUIDE.md](../ibmoon/docs/FFI_INTEGRATION_GUIDE.md)