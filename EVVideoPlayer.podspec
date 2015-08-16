Pod::Spec.new do |s|
  s.name             = "EVVideoPlayer"
  s.version          = "0.1.0"
  s.summary          = "A UIView subclass for playing videos"

  s.description      = <<-DESC
                        A video player with a lot of cool features. More coming soon!.
                       DESC

  s.homepage         = "https://github.com/EstebanVallejo/EVVideoPlayer"
  s.license          = 'MIT'
  s.author           = { "Esteban Vallejo" => "evallejo@gmail.com" }
  s.source           = { :git => "https://github.com/EstebanVallejo/EVVideoPlayer.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'AVFoundation', 'QuartzCore'
end
