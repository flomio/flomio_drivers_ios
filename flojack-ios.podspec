Pod::Spec.new do |s|
  s.name         = 'flojack-ios'
  s.version      = '0.1'
  s.license      = 'Apache v2.0'
  s.summary      = 'An Objective-C library for the FloJack NFC reader'
  s.homepage     = 'http://www.flomio.com/flojack'
  s.author       = { 'John Bullard' => 'john@flomio.com', 'Richard Grundy' => 'richard@flomio.com' }
  s.source       = { :git => 'https://github.com/flomio/flojack-ios', :tag => '0.1' }
  s.source_files = 'FloJack/*'
  s.requires_arc = true
end
