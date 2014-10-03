class String
  def fixup_push_token
    gsub(/(^<)|(>$)| /, "")
  end
end