Grover.configure do |config|
  config.options = {
    format: "A4",
    prefer_css_page_size: true,
    emulate_media: "screen",
    wait_until: "domcontentloaded",
    print_background: true
  }
end
