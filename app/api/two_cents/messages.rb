class TwoCents::Messages < Grape::API
  resource :messages do

    # list groups
    desc "List my messages"
    get 'messages'

    # update group
    desc "Update status one of my messages"
    post 'message'

    # delete message
    desc "Delete one of my messages"
    delete 'message'

  end
end