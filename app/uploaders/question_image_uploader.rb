# encoding: utf-8

class QuestionImageUploader < RetinaImageUploader

  responsive_version :web, [320,320]
  responsive_version :device, [160,160]

end
