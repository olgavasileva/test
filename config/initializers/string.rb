class String
  def fixup_push_token
    gsub(/(^<)|(>$)| /, "")
  end

  def true?
    %w(true yes).include?(self.downcase) || self.to_i != 0
  end
end