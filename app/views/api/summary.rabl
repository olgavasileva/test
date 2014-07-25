object false
node(:summary) do
  {
    response_count: @question.responses.count,
    view_count: 1000,
    comment_count: @question.comment_count,
    share_count: @question.share_count,
    skip_count: @question.skip_count,
    published_at: @question.updated_at,
    sponsor: nil,
    creator_id: User.first.id,
    creator_name: User.first.name,
    anonymous: @anonymous
  }
end
