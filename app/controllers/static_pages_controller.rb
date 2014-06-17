class StaticPagesController < ApplicationController

  before_filter :build_canned_values

  layout "clean_canvas"

  def home
  	if signed_in?
      @micropost = current_user.microposts.build
      @feed_items = current_user.feed
      @questions_answered = current_user.answered_questions
  	end

  end

  def help
    render layout:false
  end

  def about
  end

  def contact
  end

  private

  def build_canned_values
    @canned_categories = %w{art illustration print web}
    @canned_feed = [
        {categories: %w{art web}, image_url: "b3/img/portfolio1.png", url:"portfolio-item.html", title: "Awesome portfolio item", primary_category: "Art"},
        {categories: %w{illustration}, image_url: "b3/img/portfolio2.png", url: "portfolio-item.html", title: "Awesome portfolio item", primary_category: "Web Design"}, 
        {categories: %w{print}, image_url: "b3/img/portfolio3.png", url: "portfolio-item.html", title: "Awesome portfolio item", primary_category: "Print"}, 
        {categories: %w{art web}, image_url: "b3/img/portfolio2.png", url: "portfolio-item.html", title: "Awesome portfolio item", primary_category: "Web design"}, 
        {categories: %w{art illustration}, image_url: "b3/img/portfolio1.png", url: "portfolio-item.html", title: "Awesome portfolio item", primary_category: "Illustration"}, 
        {categories: %w{print}, image_url: "b3/img/portfolio3.png", url: "portfolio-item.html", title: "Awesome portfolio item", primary_category: "Print"}, 
        {categories: %w{web}, image_url: "b3/img/portfolio2.png", url: "portfolio-item.html", title: "Awesome portfolio item", primary_category: "Web Design"}, 
        {categories: %w{art.illustration web}, image_url: "b3/img/portfolio3.png", url: "portfolio-item.html", title: "Awesome portfolio item", primary_category: "Art"}, 
        {categories: %w{print}, image_url: "b3/img/portfolio1.png", url: "portfolio-item.html", title: "Awesome portfolio item", primary_category: "Illustration"}
      ]
    @canned_recent_questions = [
      {image_url: "b3/img/portfolio1.png", date: Date.today - 2.days, title: "Randomized words which don't look embarrasing hidden."},
      {image_url: "b3/img/portfolio1.png", date: Date.today - 1.day, title: "Randomized words which don't look embarrasing hidden."}
    ]
  end
end
