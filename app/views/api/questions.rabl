collection @questions, object_root: :question
attributes :id, :type, :title, :description, :response_count, :comment_count
attribute :rotate, if: lambda{|q| q.kind_of? ChoiceQuestion}
attributes :min_responses, :max_responses, if: lambda{|q| q.instance_of? MultipleChoiceQuestion}
attribute device_image_url: :image_url, if: lambda{|q| q.instance_of? TextChoiceQuestion}
attribute device_image_url: :image_url, if: lambda{|q| q.instance_of? TextQuestion}
attributes :text_type, :min_characters, :max_characters, if: lambda{|q| q.instance_of? TextQuestion}

child(:choices, if:lambda{|q| q.kind_of? TextChoiceQuestion}) { attributes :id, :title, :rotate }

child(:choices, if:lambda{|q| q.kind_of? OrderQuestion}) do
  attributes :id, :title, :rotate
  attribute device_image_url: :image_url
end

child(:choices, if:lambda{|q| q.kind_of? ImageChoiceQuestion}) do
  attributes :id, :title, :rotate
  attribute device_image_url: :image_url
end

child(:choices, if:lambda{|q| q.instance_of? MultipleChoiceQuestion}) do
  attributes :id, :title, :rotate, :muex
  attribute device_image_url: :image_url
end

child(:category) { attributes :id, :name }