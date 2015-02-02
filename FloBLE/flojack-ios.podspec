Pod::Spec.new do |s|
  s.name          = "flojack-ios"
  s.version       = "1.0.0"
  s.summary       = "iOS static lib for FloJack NFC reader/writer."
  s.homepage      = "https://github.com/flomio/flojack-ios"
  s.license       = 'Apache v2'
  s.author        = { "John Bullard" => "john@flomio.com", "Richard Grundy" => "richard@flomio.com" }
  s.source 		    = { :git => 'https://github.com/flomio/flojack-ios.git', :tag => '1.0.0'}
  s.platform      = :ios
  s.source_files  = 'FloJack', 'FloJack/**/*.{h,m,mm}'
  s.frameworks 	  = 'AudioToolbox', 'AVFoundation', 'CoreAudio', 'CoreData', 'CoreGraphics', 'Foundation', 'MediaPlayer', 'MobileCoreServices', 'QuartzCore', 'SenTestingKit' 
  s.xcconfig      = { 'GCC_INPUT_FILETYPE' => 'sourcecode.cpp.objcpp', 'OTHER_LDFLAGS' => '-all_load'}
  s.requires_arc  = true
end
