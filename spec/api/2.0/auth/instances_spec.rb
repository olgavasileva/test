require 'rails_helper'

def parsed_response
  JSON.parse response.body
end

describe :instances do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/instances", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "With no params" do
    it {expect(status).to eq 200}
    it {expect(parsed_response).not_to be_nil}
    it {expect(parsed_response['error_code']).to eq 400}
    it {expect(parsed_response['error_message']).to match /api_signature is missing/}
  end

  context "With all required params" do
    let(:params) {{api_signature:api_signature, app_version:app_version, device_vendor_identifier:device_vendor_identifier, platform:platform, manufacturer:manufacturer, model:model, os_version:os_version}}
    let(:api_signature) {"HMM"}
    let(:app_version) {"1.2"}
    let(:device_vendor_identifier) {FactoryGirl.generate :device_vendor_identifier}
    let(:platform) {'ios'}
    let(:manufacturer) {'apple'}
    let(:model) {'iPhone 5s'}
    let(:os_version) {'iOS 7.1'}

    context "When the signature doesn't match" do
      let(:api_signature) {"BAD"}

      it {expect(response.status).to eq 200}
      it {expect(parsed_response['error_code']).to eq 1000}
      it {expect(parsed_response['error_message']).to match /Invalid API signature/}
      it {expect(parsed_response['instance_token']).to be_nil}
    end

    context "When the signature is OK" do
      let(:valid_signature) {Digest::SHA2.hexdigest(device_vendor_identifier + ENV["api_shared_secret"].to_s)}
      let(:api_signature) {valid_signature}

      it {expect(parsed_response['share_community_public']).to eq Setting.find_by_key('share_community_public').try(:value) }
      it {expect(parsed_response['share_community_private']).to eq Setting.find_by_key('share_community_private').try(:value) }

      context "When the signature is uppercase" do
        let(:api_signature) {valid_signature.upcase}

        it {expect(response.status).to eq 201}
        it {expect(parsed_response['error_code']).to be_nil}
        it {expect(parsed_response['error_message']).to be_nil}
        it {expect(parsed_response['instance_token']).not_to be_nil}
      end

      context "When the signature is lowercase" do
        let(:api_signature) { valid_signature.downcase}

        it {expect(response.status).to eq 201}
        it {expect(parsed_response['error_code']).to be_nil}
        it {expect(parsed_response['error_message']).to  be_nil}
        it {expect(parsed_response['instance_token']).not_to be_nil}
      end

      context "When the instance_token is not supplied" do
        it {expect(response.status).to eq 201}
        it {expect(parsed_response['error_code']).to be_nil}
        it {expect(parsed_response['instance_token']).not_to be_nil}
        it "should create an instance and return its token" do
          expect(Instance.find_by(uuid:parsed_response['instance_token'])).not_to be_nil
        end
        it {expect(parsed_response['api_domain']).to be_present}
        it {expect(parsed_response['background_images'].class).to eq Array}
        it {expect(parsed_response['background_images_retina'].class).to eq Array}
        it {expect(parsed_response['background_choice_images'].class).to eq Array}
        it {expect(parsed_response['background_choice_images_retina'].class).to eq Array}
        it {expect(parsed_response['background_order_choice_images'].class).to eq Array}
        it {expect(parsed_response['background_order_choice_images_retina'].class).to eq Array}

        context "When there are two enabled and one disabled key/value pairs in Settings" do
          let(:before_api_call) do
            FactoryGirl.create :setting, key: "Superman", value: "Clark Kent"
            FactoryGirl.create :setting, key: "007", value: "James Bond"
            FactoryGirl.create :setting, key: "86", value: "Maxwell Smart", enabled: false
          end

          it {expect(parsed_response['Superman']).to eq "Clark Kent"}
          it {expect(parsed_response['007']).to eq "James Bond"}
          it {expect(parsed_response['86']).to be_nil}
        end

        context "When there is one background image of each type (quetion, choice, order choice) and for standard and retina displays" do
          let(:before_api_call) do
            CannedQuestionImage.stub(:all).and_return([question_image])
            CannedChoiceImage.stub(:all).and_return([choice_image])
            CannedOrderChoiceImage.stub(:all).and_return([order_choice_image])
          end
          let(:question_image) {double(:question_image, device_image_url:"DEVICE QUESTION URL", retina_device_image_url:"RETINA DEVICE QUESTION URL")}
          let(:choice_image) {double(:choice_image, device_image_url:"DEVICE CHOICE URL", retina_device_image_url:"RETINA DEVICE CHOICE URL")}
          let(:order_choice_image) {double(:order_choice_image, device_image_url:"DEVICE ORDER URL", retina_device_image_url:"RETINA DEVICE ORDER URL")}

          it {expect(parsed_response['background_images']).to eq ["DEVICE QUESTION URL"]}
          it {expect(parsed_response['background_images_retina']).to eq ["RETINA DEVICE QUESTION URL"]}
          it {expect(parsed_response['background_choice_images']).to eq ["DEVICE CHOICE URL"]}
          it {expect(parsed_response['background_choice_images_retina']).to eq ["RETINA DEVICE CHOICE URL"]}
          it {expect(parsed_response['background_order_choice_images']).to eq ["DEVICE ORDER URL"]}
          it {expect(parsed_response['background_order_choice_images_retina']).to eq ["RETINA DEVICE ORDER URL"]}
        end

        it "should set the app version on the instance" do
          expect(Instance.find_by(uuid:parsed_response['instance_token']).app_version).to eq app_version
        end
      end

      context "When the instance_token is supplied" do
        let(:params) {{api_signature:api_signature, app_version:app_version, instance_token:instance_token, device_vendor_identifier:device_vendor_identifier, platform:platform, manufacturer:manufacturer, model:model, os_version:os_version}}

        context "When the instance_token is nil" do
          let(:instance_token) {nil}

          context "When a device matching the device_vendor_identifier doesn't exist" do
            it {expect(response.status).to eq 201}
            it {expect(parsed_response['error_code']).to be_nil}
            it {expect(parsed_response['error_message']).to be_nil}
            it {expect(parsed_response['instance_token']).not_to be_nil}
            it "should create an instance and return its token" do
              expect(Instance.find_by(uuid:parsed_response['instance_token'])).not_to be_nil
            end
            it "should create a device with that device_vendor_identifier" do
              expect(Device.find_by(device_vendor_identifier:device_vendor_identifier)).not_to be_nil
            end
            it "should set the app version on the instance" do
              expect(Instance.find_by(uuid:parsed_response['instance_token']).app_version).to eq app_version
            end
          end

          context "When a device matching the device_vendor_identifier already exists" do
            let(:before_api_call) { existing_device }
            let(:existing_device) { FactoryGirl.create :device }
            let(:device_vendor_identifier) {existing_device.device_vendor_identifier}

            it {expect(response.status).to eq 201}
            it {expect(parsed_response['error_code']).to be_nil}
            it {expect(parsed_response['instance_token']).not_to be_nil}
            it "should create an instance and return its token" do
              expect(Instance.find_by(uuid:parsed_response['instance_token'])).not_to be_nil
            end
            it "should not create a new device with that device_vendor_identifier" do
              expect(Device.find_by(device_vendor_identifier:device_vendor_identifier)).not_to be_nil
              expect(Device.find_by(device_vendor_identifier:device_vendor_identifier).id).to eq existing_device.id
            end
            it "should set the app version on the instance" do
              expect(Instance.find_by(uuid:parsed_response['instance_token']).app_version).to eq app_version
            end
          end
        end

        context "When the supplied instance_token is not nil" do
          context "When an instance with that token doesn't yet exist" do
            let(:instance_token) { FactoryGirl.generate :uuid }

            it {expect(response.status).to eq 200}
            it {expect(parsed_response['error_code']).to eq 1001}
            it {expect(parsed_response['error_message']).to match /Invalid instance token/}
            it {expect(parsed_response['instance_token']).to be_nil}
          end

          context "When the instance already exists" do
            let(:existing_instance) { FactoryGirl.create :instance }
            let(:instance_token) { existing_instance.uuid }

            it {expect(response.status).to eq 201}
            it {expect(parsed_response['error_code']).to be_nil}
            it {expect(parsed_response['instance_token']).not_to be_nil}
            it "should use that instance and return the same token" do
              expect(Instance.find_by(uuid:parsed_response['instance_token']).id).to eq existing_instance.id
            end
            it "should increment the launch_count" do
              expect(Instance.find_by(uuid:parsed_response['instance_token']).launch_count).to eq 1
            end
            it "should set the app version on the instance" do
              expect(Instance.find_by(uuid:parsed_response['instance_token']).app_version).to eq app_version
            end

            context "When a device matching the device_vendor_identifier doesn't exist" do
              let(:before_api_call) { existing_device }
              let(:existing_device) { FactoryGirl.create :device }
              let(:device_vendor_identifier) {existing_device.device_vendor_identifier}

              it {expect(response.status).to eq 201}
              it {expect(parsed_response['error_code']).to be_nil}
              it {expect(parsed_response['instance_token']).not_to be_nil}
              it "should create an instance and return its token" do
                expect(Instance.find_by(uuid:parsed_response['instance_token'])).not_to be_nil
              end
              it "should not create a new device with that device_vendor_identifier" do
                expect(Device.find_by(device_vendor_identifier:device_vendor_identifier)).not_to be_nil
                expect(Device.find_by(device_vendor_identifier:device_vendor_identifier).id).to eq existing_device.id
              end
              it "should set the app version on the instance" do
                expect(Instance.find_by(uuid:parsed_response['instance_token']).app_version).to eq app_version
              end
            end

            context "When a device matching the device_vendor_identifier already exists" do
              let(:before_api_call) { existing_device }
              let(:existing_device) { FactoryGirl.create :device }
              let(:device_vendor_identifier) {existing_device.device_vendor_identifier}

              it {expect(response.status).to eq 201}
              it {expect(parsed_response['error_code']).to be_nil}
              it {expect(parsed_response['instance_token']).not_to be_nil}
              it "should create an instance and return its token" do
                expect(Instance.find_by(uuid:parsed_response['instance_token'])).not_to be_nil
              end
              it "should not create a new device with that device_vendor_identifier" do
                expect(Device.find_by(device_vendor_identifier:device_vendor_identifier)).not_to be_nil
                expect(Device.find_by(device_vendor_identifier:device_vendor_identifier).id).to eq existing_device.id
              end
              it "should set the app version on the instance" do
                expect(Instance.find_by(uuid:parsed_response['instance_token']).app_version).to eq app_version
              end
            end
          end
        end
      end
    end
  end
end
