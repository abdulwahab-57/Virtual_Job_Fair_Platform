Grover.configure do |config|
  config.options = {
    timeout: 0,
    protocolTimeout: 0,
    format: "A4",
    margin: {
      top: "0.5in",
      left: "0.5in",
      right: "0.5in"
    },
    launch_args: [
      "--no-sandbox",
      "--disable-crash-reporter",
      "--disable-crashpad-for-testing"
    ],
    prefer_css_page_size: true,
    emulate_media: "screen",
    wait_until: "domcontentloaded",
    print_background: true
  }
end
