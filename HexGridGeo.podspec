#
#  Be sure to run `pod spec lint HexGridGeoSwift.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "HexGridGeo"
  s.version      = "2.0.3"
  s.platform     = :ios, "9.0"
  s.summary      = "HexGridGeoSwift."
  s.homepage     = "https://github.com/gtforge/HexGridGeoSwift"
  s.license      = "BSD"
  s.author       = { "Gil Polak" => "gilp@gett.com" }
  s.source       = { :git => "https://github.com/gtforge/HexGridGeoSwift.git" }
  s.source_files  = "HexGridGeo/*"
  s.dependency 'Morton'
  s.dependency 'HexGrid'

end
