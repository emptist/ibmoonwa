///|
// IB MoonBit API Wrapper - WebAssembly Target
// Demonstrates basic usage of ibmoonwa library with WebAssembly FFI

///|
fn main {
  println("IB MoonBit API Wrapper - WebAssembly Target")
  println("==========================================")
  println("")
  println("This project provides a MoonBit wrapper for Interactive Brokers")
  println("TWS/Gateway API with WebAssembly FFI socket implementation.")
  println("")
  println("Features:")
  println("  - Full IB API support (market data, orders, account data)")
  println("  - WebAssembly FFI socket implementation")
  println("  - High-level API wrapper for easy integration")
  println("  - Comprehensive error handling")
  println("")
  println("Usage:")
  println("  1. Build: moon build --target wasm")
  println("  2. Run examples in the package root")
  println("  3. See README.md for detailed documentation")
  println("")
  println("Note: This is a WebAssembly-specific target. For other targets,")
  println("      see ibmoonjs (JavaScript/Node.js) or ibmoonc (C/Native).")
  println("")
  println("Browser Limitations:")
  println("  - WebAssembly cannot directly access TCP sockets")
  println("  - Requires WebSocket proxy or host function integration")
  println("  - See README.md for browser-specific setup instructions")
}
