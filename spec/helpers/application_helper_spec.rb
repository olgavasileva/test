require 'rails_helper'

describe ApplicationHelper do

  describe "#full_title" do
    it "should include the page title" do
      expect(helper.full_title("foo")).to match(/foo/)
    end

    it "should include the base title" do
      expect(helper.full_title("foo")).to match(/^2cents/)
    end

    it "should not include a bar for the home page" do
      expect(helper.full_title("")).not_to match(/\|/)
    end
  end
end