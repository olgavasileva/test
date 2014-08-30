object false
node(:summary) do
  resp_ratios = @question.try(:response_ratios)

  {
    choices: @question.choices.map { |c| {
      id: c.id,
      response_ratio: resp_ratios[c]
    } },
    response_count: @question.responses.count,
    view_count: 1000,
    comment_count: @question.comment_count,
    share_count: @question.share_count,
    skip_count: @question.skip_count,
    published_at: @question.updated_at,
    sponsor: nil,
    creator_id: @question.user.id,
    creator_name: @question.user.name,
    anonymous: @anonymous,
  }
end
