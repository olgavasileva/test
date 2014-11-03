ActiveAdmin.register Rpush::Apns::App, as: "Push Apps" do
  menu parent: 'Push'

  permit_params :name, :environment, :certificate, :password, :connections

  index do
    column :name
    column :environment

    column "Certificate" do |app|
      app.certificate.truncate(256) if app.certificate
    end

    column :connections

    actions
  end

  show do |app|
    attributes_table do
      row :environment
      row :certificate
    end

    active_admin_comments
  end


  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :environment, collection:%w(production development), hint:"You should have one APN Certificate for each environment per App"
      f.input :certificate, label:"Apple Certificate (PEM)", hint:"openssl pkcs12 -nodes -clcerts -in cert.p12 -out <environment>.pem"
      f.input :password, hint:"Leave this blank if you don't have a password on the Apple certificate"
      f.input :connections, hint:"Number of simultaneous connections to the remote push service (max 2 pushes per second per connection)"
    end
    f.actions
  end
end
