# -*- coding: utf-8 -*-
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |footer|
    footer.item :home, 'Home', root_path
    footer.item :about, 'About Us', '#'
    footer.item :tos, 'Terms of Service', '#'
    footer.item :privacy, 'Privacy Policy', '#'
    footer.item :business, 'Partners & Advertisers', '#'
    footer.item :business_signin, 'Business Sign Up', new_registration_path(:partner)
    footer.item :business_signin, 'Business Sign In', new_session_path(:partner)
  end
end
