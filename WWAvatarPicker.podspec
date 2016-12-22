
Pod::Spec.new do |s|

  s.name         = "WWAvatarPicker"
  s.version      = "1.0.7"
  s.summary      = "A compute for pick avatar"

  s.description  = <<-DESC
                   It is a compute for pick avatar for iOS, which implement by Objective-C.
                   DESC

  s.homepage     = "https://github.com/waiwaib/WWAvatarPicker"

  s.license      = { :type => "MIT", :file => "LICENSE" }
  
  s.author             = { "waiwaib" => "857557118@qq.com" }
  
  
  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/waiwaib/WWAvatarPicker.git", :tag => "1.0.7" }

  s.source_files  = "WWAvatarPicker/imagePicker/*"
  
  s.frameworks = "Foundation","UIKit"

  s.dependency  'MBProgressHUD'

  s.requires_arc = true
  
end
