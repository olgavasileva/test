class EmbeddableUnit < ActiveRecord::Base
  belongs_to :survey

  default :uuid do |eu|
    "EU"+UUID.new.generate.gsub(/-/, '')
  end

end
