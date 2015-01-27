class TextResponse < Response
  include Rakismet::Model
  rakismet_attrs  :author => proc { user.username },
                  :author_email => proc { user.email },
                  :user_ip => :user_ip,
                  :content => :text

  attr_accessor :user_ip

  validates :text, presence:true

  def description
    text
  end
end