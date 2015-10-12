class Gadget < ActiveRecord::Base
  establish_connection "widgets_#{Rails.env}".to_sym
end