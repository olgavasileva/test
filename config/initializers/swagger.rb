GrapeSwaggerRails.options.app_name = 'Statisfy'
GrapeSwaggerRails.options.url      = '/swagger_doc.json'
GrapeSwaggerRails.options.app_url  = 'http://localhost:3000' if Rails.env.development?
GrapeSwaggerRails.options.app_url  = 'http://labs.statisfy.co' if Rails.env.labs?
GrapeSwaggerRails.options.app_url  = 'http://staging.statisfy.co' if Rails.env.staging?
GrapeSwaggerRails.options.app_url  = 'http://api.statisfy.co' if Rails.env.production?
