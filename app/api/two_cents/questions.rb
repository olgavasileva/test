class TwoCents::Questions < Grape::API
  resource :questions do
    desc 'Question feed'
    params do
      requires :udid, type: String
      requires :remember_token, type: String
    end
    post 'feed/:remember_token' do
      policy_scope Question
    end
  end
end
