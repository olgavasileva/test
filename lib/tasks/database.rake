namespace :db do

  def background_image filename
    File.join "db","seeds","backgrounds",filename
  end

  desc "Add the background images"
  task backgrounds: :environment do
    image_files = %w(bluegrunge.png bluetriangle.png bluetriangular.png bluewall.png greengrunge.png greentriangle.png greentriangular.png greenwall.png redgrunge.png redtriangle.png redtriangular.png redwall.png yellowgrunge.png yellowtriangle.png yellowtriangular.png yellowwall.png)
    existing_file_paths = BackgroundImage.all.map{|f|f.image.path}
    image_files.each_with_index do |image_file, position|
      CannedImage.create image:open(background_image image_file) unless existing_file_paths.find {|fp| fp.match /#{image_file}$/}
    end
  end

end