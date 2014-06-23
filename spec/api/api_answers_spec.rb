require 'spec_helper'

describe "API Access AnswersController" do

	subject { page }

	let(:user) { FactoryGirl.create(:user) }
	let(:device) { FactoryGirl.create(:device) }
	let(:ownership) { user.own!(device) }
	let(:another_user) { FactoryGirl.create(:user) }

	describe "AnswersController methods" do

		describe "accessing answer_question_type_1 action" do
			let(:category) { FactoryGirl.create(:category) }
			let(:q1) { FactoryGirl.create(:question, user: user, category: category, title: "test 1", info: "info 1", question_type: 1) }
			let(:ch1) { FactoryGirl.create(:choice, question: q1, label: "choice 1", description: "desc 1") }
			let(:ch2) { FactoryGirl.create(:choice, question: q1, label: "choice 2", description: "desc 2") }
			let(:ch3) { FactoryGirl.create(:choice, question: q1, label: "choice 3", description: "desc 3") }
			let(:ch4) { FactoryGirl.create(:choice, question: q1, label: "choice 4", description: "desc 4") }

			before do
				category.save
				q1.save
				ch1.save
				ch2.save
				ch3.save
				ch4.save
			end

			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/answers/answer_question_type_1", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/answers/answer_question_type_1", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/answers/answer_question_type_1", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/answers/answer_question_type_1", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with valid answer creation" do
				before do
					params = { answer: { agree: false, question_id: q1.id }, response1: { order: 1, choice_id: ch4.id, percent: 0.0, star: 0, slider: 0 }, response2: { order: 2, choice_id: ch2.id, percent: 0.0, star: 0, slider: 0 }, response3: { order: 3, choice_id: ch1.id, percent: 0.0, star: 0, slider: 0 }, response4: { order: 4, choice_id: ch3.id, percent: 0.0, star: 0, slider: 0 }, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/answers/answer_question_type_1", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('agree') }	
				specify { expect(response.body).to match('user') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).to match('title') }
				specify { expect(response.body).to match('info') }
				specify { expect(response.body).to match('image_url') }
				specify { expect(response.body).to match('question_type') }
				specify { expect(response.body).to match('category') }
				specify { expect(response.body).to match('order') }
				specify { expect(response.body).to match('percent') }
				specify { expect(response.body).to match('star') }
				specify { expect(response.body).not_to match('user_id') }	
				specify { expect(response.body).to match('answer') }
				specify { expect(response.body).to match('results') }
				specify { expect(response.body).to match('choices') }
				specify { expect(response.body).to match('order_average') }
			end
		end


		describe "accessing answer_question_type_2 action" do
			let(:category) { FactoryGirl.create(:category) }
			let(:q1) { FactoryGirl.create(:question, user: user, category: category, title: "test 1", info: "info 1", question_type: 2) }
			let(:ch1) { FactoryGirl.create(:choice, question: q1, label: "choice 1", description: "desc 1") }
			let(:ch2) { FactoryGirl.create(:choice, question: q1, label: "choice 2", description: "desc 2") }

			before do
				category.save
				q1.save
				ch1.save
				ch2.save
			end

			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/answers/answer_question_type_2", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/answers/answer_question_type_2", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/answers/answer_question_type_2", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/answers/answer_question_type_2", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with valid answer creation" do
				before do
					params = { answer: { agree: false, question_id: q1.id }, response1: { order: 0, choice_id: ch1.id, percent: 0.0, star: 0, slider: 75 }, response2: { order: 0, choice_id: ch2.id, percent: 0.0, star: 0, slider: -75 }, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/answers/answer_question_type_2", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('agree') }	
				specify { expect(response.body).to match('user') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).to match('title') }
				specify { expect(response.body).to match('info') }
				specify { expect(response.body).to match('image_url') }
				specify { expect(response.body).to match('question_type') }
				specify { expect(response.body).to match('category') }
				specify { expect(response.body).to match('order') }
				specify { expect(response.body).to match('percent') }
				specify { expect(response.body).to match('star') }
				specify { expect(response.body).not_to match('user_id') }
				specify { expect(response.body).to match('answer') }
				specify { expect(response.body).to match('results') }
				specify { expect(response.body).to match('choices') }
				specify { expect(response.body).to match('slider_average') }
			end
		end


		describe "accessing answer_question_type_3 action" do
			let(:category) { FactoryGirl.create(:category) }
			let(:q1) { FactoryGirl.create(:question, user: user, category: category, title: "test 1", info: "info 1", question_type: 3) }
			let(:ch1) { FactoryGirl.create(:choice, question: q1, label: "choice 1", description: "desc 1") }
			let(:ch2) { FactoryGirl.create(:choice, question: q1, label: "choice 2", description: "desc 2") }
			let(:ch3) { FactoryGirl.create(:choice, question: q1, label: "choice 3", description: "desc 3") }
			let(:ch4) { FactoryGirl.create(:choice, question: q1, label: "choice 4", description: "desc 4") }

			before do
				category.save
				q1.save
				ch1.save
				ch2.save
				ch3.save
				ch4.save
			end

			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/answers/answer_question_type_3", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/answers/answer_question_type_3", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/answers/answer_question_type_3", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/answers/answer_question_type_3", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with valid answer creation" do
				before do
					params = { answer: { agree: false, question_id: q1.id }, response1: { order: 0, choice_id: ch4.id, percent: 0.0, star: 4, slider: 0 }, response2: { order: 0, choice_id: ch2.id, percent: 0.0, star: 2, slider: 0 }, response3: { order: 0, choice_id: ch1.id, percent: 0.0, star: 5, slider: 0 }, response4: { order: 0, choice_id: ch3.id, percent: 0.0, star: 1, slider: 0 }, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/answers/answer_question_type_3", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('agree') }	
				specify { expect(response.body).to match('user') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).to match('title') }
				specify { expect(response.body).to match('info') }
				specify { expect(response.body).to match('image_url') }
				specify { expect(response.body).to match('question_type') }
				specify { expect(response.body).to match('category') }
				specify { expect(response.body).to match('order') }
				specify { expect(response.body).to match('percent') }
				specify { expect(response.body).to match('star') }
				specify { expect(response.body).not_to match('user_id') }	
				specify { expect(response.body).to match('answer') }
				specify { expect(response.body).to match('results') }
				specify { expect(response.body).to match('choices') }
				specify { expect(response.body).to match('star_average') }
			end
		end


		describe "accessing answer_question_type_4 action" do
			let(:category) { FactoryGirl.create(:category) }
			let(:q1) { FactoryGirl.create(:question, user: user, category: category, title: "test 1", info: "info 1", question_type: 1) }
			let(:ch1) { FactoryGirl.create(:choice, question: q1, label: "choice 1", description: "desc 1") }
			let(:ch2) { FactoryGirl.create(:choice, question: q1, label: "choice 2", description: "desc 2") }
			let(:ch3) { FactoryGirl.create(:choice, question: q1, label: "choice 3", description: "desc 3") }
			let(:ch4) { FactoryGirl.create(:choice, question: q1, label: "choice 4", description: "desc 4") }
			let(:ch5) { FactoryGirl.create(:choice, question: q1, label: "choice 5", description: "desc 5") }

			before do
				category.save
				q1.save
				ch1.save
				ch2.save
				ch3.save
				ch4.save
				ch5.save
			end

			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/answers/answer_question_type_4", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/answers/answer_question_type_4", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/answers/answer_question_type_4", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/answers/answer_question_type_4", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with valid answer creation" do
				before do
					params = { answer: { agree: false, question_id: q1.id }, response1: { order: 0, choice_id: ch4.id, percent: 0.10, star: 0, slider: 0 }, response2: { order: 0, choice_id: ch2.id, percent: 0.25, star: 0, slider: 0 }, response3: { order: 0, choice_id: ch1.id, percent: 0.15, star: 0, slider: 0 }, response4: { order: 0, choice_id: ch3.id, percent: 0.45, star: 0, slider: 0 }, response5: { order: 0, choice_id: ch5.id, percent: 0.05, star: 0, slider: 0 }, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/answers/answer_question_type_4", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('agree') }	
				specify { expect(response.body).to match('user') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).to match('title') }
				specify { expect(response.body).to match('info') }
				specify { expect(response.body).to match('image_url') }
				specify { expect(response.body).to match('question_type') }
				specify { expect(response.body).to match('category') }
				specify { expect(response.body).to match('order') }
				specify { expect(response.body).to match('percent') }
				specify { expect(response.body).to match('star') }
				specify { expect(response.body).not_to match('user_id') }	
				specify { expect(response.body).to match('answer') }
				specify { expect(response.body).to match('results') }
				specify { expect(response.body).to match('choices') }
				specify { expect(response.body).to match('percent_average') }
			end
		end


		describe "accessing answer_question_type_5 action" do
			let(:category) { FactoryGirl.create(:category) }
			let(:q1) { FactoryGirl.create(:question, user: user, category: category, title: "test 1", info: "info 1", question_type: 5) }
			let(:ch1) { FactoryGirl.create(:choice, question: q1, label: "choice 1", description: "desc 1") }
			let(:ch2) { FactoryGirl.create(:choice, question: q1, label: "choice 2", description: "desc 2") }
			let(:ch3) { FactoryGirl.create(:choice, question: q1, label: "choice 3", description: "desc 3") }
			let(:ch4) { FactoryGirl.create(:choice, question: q1, label: "choice 4", description: "desc 4") }
			let(:ch5) { FactoryGirl.create(:choice, question: q1, label: "choice 5", description: "desc 5") }
			let(:ch6) { FactoryGirl.create(:choice, question: q1, label: "choice 6", description: "desc 6") }

			before do
				category.save
				q1.save
				ch1.save
				ch2.save
				ch3.save
				ch4.save
				ch5.save
				ch6.save
			end

			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/answers/answer_question_type_5", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/answers/answer_question_type_5", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/answers/answer_question_type_5", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/answers/answer_question_type_5", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with valid answer creation" do
				before do
					params = { answer: { agree: false, question_id: q1.id }, response1: { order: 0, choice_id: ch4.id, percent: 0.0, star: 0, slider: 0 }, response2: { order: 0, choice_id: ch2.id, percent: 0.0, star: 0, slider: 0 }, response3: { order: 0, choice_id: ch1.id, percent: 0.0, star: 1, slider: 0 }, response4: { order: 0, choice_id: ch3.id, percent: 0.0, star: 0, slider: 0 }, response5: { order: 0, choice_id: ch5.id, percent: 0.0, star: 0, slider: 0 }, response6: { order: 0, choice_id: ch6.id, percent: 0.0, star: 1, slider: 0 },udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/answers/answer_question_type_5", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('agree') }	
				specify { expect(response.body).to match('user') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).to match('title') }
				specify { expect(response.body).to match('info') }
				specify { expect(response.body).to match('image_url') }
				specify { expect(response.body).to match('question_type') }
				specify { expect(response.body).to match('category') }
				specify { expect(response.body).to match('order') }
				specify { expect(response.body).to match('percent') }
				specify { expect(response.body).to match('star') }
				specify { expect(response.body).not_to match('user_id') }	
				specify { expect(response.body).to match('answer') }
				specify { expect(response.body).to match('results') }
				specify { expect(response.body).to match('choices') }
				specify { expect(response.body).to match('star_average') }
			end
		end
	end


end