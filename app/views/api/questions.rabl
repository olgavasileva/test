collection @questions, object_root: :question
attributes :id, :type, :title, :description
attribute :rotate, if: lambda{|q| q.kind_of? ChoiceQuestion}
attributes :min_responses, :max_responses, if: lambda{|q| q.instance_of? MultipleChoiceQuestion}
child(:choices, if:lambda{|q| q.kind_of? ChoiceQuestion}) { attributes :id, :title, :rotate, :text_response_required }
child(:choices, if:lambda{|q| q.instance_of? MultipleChoiceQuestion}) { attributes :id, :title, :rotate, :text_response_required, :muex }
child(:category) { attributes :id, :name }