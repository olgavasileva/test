class EnterpriseTargetsSegment < ActiveRecord::Base
  belongs_to :enterprise_target
  belongs_to :segment
end
