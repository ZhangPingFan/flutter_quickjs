#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_quickjs.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_quickjs'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  s.prepare_command = 'sh build_quickjs.sh'

  # Flutter.framework does not contain a i386 slice.
  # replace 'i386' with 'arm64' when running on iphone simulator (for mac with intel core)
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.vendored_frameworks = 'framework/QuickJS.xcframework'
  s.swift_version = '5.0'
end
