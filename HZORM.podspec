Pod::Spec.new do |s|

  s.name         = "HZORM" 
  s.version      = "0.1.1"    
  s.summary      = "HZORM provides a beautiful, simple ActiveRecord implementation to interact with the database."
  s.homepage     = "https://github.com/GeniusBrother/HZORM.git"
  s.license      = "MIT"
  s.author             = { "GeniusBrother" => "zuohong_xie@163.com" }
  s.platform     = :ios, "8.0"
  s.requires_arc = true
  s.source       = { :git => "https://github.com/GeniusBrother/HZORM.git", :tag => s.version }    
  s.frameworks = "Foundation"

  s.public_header_files = 'HZORM/Classes/**/*.h'
  s.source_files = 'HZORM/Classes/**/*.{h,m}' 

  s.dependency 'FMDB', '~>2.7.0'
end
