json.(user, :username, :email)
json.user_id user.id
json.avatar_url user.avatar.try(:image_url)
json.member_since user.created_at
json.number_of_asked_questions user.number_of_asked_questions
json.number_of_answered_questions user.number_of_answered_questions
json.number_of_comments_left user.number_of_comments_left
json.number_of_followers user.number_of_followers

if user.kind_of?(User)

  if user.is_pro? || user.publisher?
    urls = Rails.application.routes.url_helpers
    json.pro_dashboard_url urls.dashboard_user_url(user, auth_token: @instance.auth_token,
                                                   host: Rails.env.production? ? 'api.statisfy.co' : Rails.application.default_url_options[:host])
  end

  if current_user.id == user.id
    json.providers do
      json.array! user.authentications do |authentication|
        json.extract! authentication, :id, :provider
      end
    end
  end

end
