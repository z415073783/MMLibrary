#
#  Be sure to run `pod spec lint MMLibrary.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "MMLibrary"
  spec.version      = "1.0.3.2"
  spec.summary      = "A short description of MMLibrary."

  spec.description  = <<-DESC
                 基础工具库
                   DESC

  spec.homepage     = "https://github.com/z415073783/MMLibrary.git"

  # spec.license      = "MIT"
  spec.license      = { :type => "MIT", :file => "The MIT License (MIT)" }

  spec.author             = { "zengliangmin" => "415073783@qq.com" }

  spec.platform     = :ios, "16.0"
  spec.ios.deployment_target = '16.0'


  spec.source       = { :git => "git@github.com:z415073783/MMLibrary.git", :tag => spec.version }

  # spec.vendored_frameworks = "Build/merge/*.framework"


  spec.source_files  = "Sources", "Sources/**/*"
  # spec.exclude_files = "MMLibrary/Info.plist"
  # spec.preserve_path = "Sources/ZipArchive/minizip/module/module.modulemap"
  # spec.xcconfig = { "SWIFT_INCLUDE_PATHS" => "$(PODS_ROOT)/MMLibrary/Sources/ZipArchive/minizip/module"}
  # , "OTHER_CODE_SIGN_FLAGS" => "--generate-entitlement-der"
  # spec.xcconfig = {"APPLICATION_EXTENSION_API_ONLY" => "NO"}

  spec.libraries = "z"
  # spec.dependency 'MMZipArchive'


end
