require 'spec_helper'

describe "API Access QuestionsController" do

	subject { page }

	let(:user) { FactoryGirl.create(:user) }
	let(:device) { FactoryGirl.create(:device) }
	let(:ownership) { user.own!(device) }
	let(:another_user) { FactoryGirl.create(:user) }

	describe "QuestionsController methods" do

		describe "accessing next10 action" do
			let(:category) { FactoryGirl.create(:category) }
			let(:q1) { FactoryGirl.create(:question, user: user, category: category, title: "test 1", info: "info 1") }
			let(:q2) { FactoryGirl.create(:question, user: user, category: category, title: "test 2", info: "info 2") }
			let(:q3) { FactoryGirl.create(:question, user: user, category: category, title: "test 3", info: "info 3") }

			let(:ch1) { FactoryGirl.create(:choice, question: q1, label: "choice 1", description: "desc 1") }
			let(:ch2) { FactoryGirl.create(:choice, question: q1, label: "choice 2", description: "desc 2") }
			let(:ch3) { FactoryGirl.create(:choice, question: q2, label: "choice 3", description: "desc 3") }
			let(:ch4) { FactoryGirl.create(:choice, question: q2, label: "choice 4", description: "desc 4") }
			let(:ch5) { FactoryGirl.create(:choice, question: q3, label: "choice 5", description: "desc 5") }
			let(:ch6) { FactoryGirl.create(:choice, question: q3, label: "choice 6", description: "desc 6") }

			before do
				category.save
				q1.save
				q2.save
				q3.save
				ch1.save
				ch2.save
				ch3.save
				ch4.save
				ch5.save
				ch6.save
			end

			describe "without proper authorization" do
				before do
					params = { page: 1, format: :json }
					post "api/questions/next10", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/next10", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/questions/next10", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/questions/next10", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with proper authorization" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, page: 1, format: :json }
					post "api/questions/next10", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('title') }
				specify { expect(response.body).to match('info') }
				specify { expect(response.body).to match('image_url') }
				specify { expect(response.body).to match('question_type') }
				specify { expect(response.body).to match('created_at') }
				specify { expect(response.body).to match("min_value") }
				specify { expect(response.body).to match("max_value") }
				specify { expect(response.body).to match("interval") }
				specify { expect(response.body).to match("units") }
				specify { expect(response.body).to match("category") }
				specify { expect(response.body).to match('user') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).not_to match('user_id') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).to match("#{q1.title}") }
				specify { expect(response.body).to match("#{q1.info}") }
				specify { expect(response.body).to match("#{q2.title}") }
				specify { expect(response.body).to match("#{q2.info}") }
				specify { expect(response.body).to match("#{q3.title}") }
				specify { expect(response.body).to match("#{q3.info}") }
				specify { expect(response.body).to match("#{user.name}") }
				specify { expect(response.body).to match("choices") }
				specify { expect(response.body).to match("#{ch1.label}") }
				specify { expect(response.body).to match("#{ch1.description}") }
				specify { expect(response.body).to match("#{ch2.label}") }
				specify { expect(response.body).to match("#{ch2.description}") }
				specify { expect(response.body).to match("#{ch3.label}") }
				specify { expect(response.body).to match("#{ch3.description}") }
				specify { expect(response.body).to match("#{ch4.label}") }
				specify { expect(response.body).to match("#{ch4.description}") }
				specify { expect(response.body).to match("#{ch5.label}") }
				specify { expect(response.body).to match("#{ch5.description}") }
				specify { expect(response.body).to match("#{ch6.label}") }
				specify { expect(response.body).to match("#{ch6.description}") }
			end
		end

		describe "accessing results action" do
			
			let(:category) { FactoryGirl.create(:category) }
			let(:q1) { FactoryGirl.create(:question, user: user, category: category, title: "test 1", info: "info 1", question_type: 1) }
			let(:q2) { FactoryGirl.create(:question, user: user, category: category, title: "test 2", info: "info 2", question_type: 2) }

			let(:ch1) { FactoryGirl.create(:choice, question: q1, label: "choice 1", description: "desc 1") }
			let(:ch2) { FactoryGirl.create(:choice, question: q1, label: "choice 2", description: "desc 2") }
			let(:ch3) { FactoryGirl.create(:choice, question: q1, label: "choice 3", description: "desc 3") }
			let(:ch4) { FactoryGirl.create(:choice, question: q1, label: "choice 4", description: "desc 4") }
			let(:ch5) { FactoryGirl.create(:choice, question: q2, label: "choice 5", description: "desc 5") }
			let(:ch6) { FactoryGirl.create(:choice, question: q2, label: "choice 6", description: "desc 6") }

			let(:answer_user_1) { FactoryGirl.create(:user) }

			let (:a1) { FactoryGirl.create(:answer, user: user, question: q1) }
			let (:r1) { FactoryGirl.create(:response, answer: a1, choice: ch1, order: 4) }
			let (:r2) { FactoryGirl.create(:response, answer: a1, choice: ch2, order: 3) }
			let (:r3) { FactoryGirl.create(:response, answer: a1, choice: ch3, order: 2) }
			let (:r4) { FactoryGirl.create(:response, answer: a1, choice: ch4, order: 1) }

			let (:a2) { FactoryGirl.create(:answer, user: user, question: q2) }
			let (:r5) { FactoryGirl.create(:response, answer: a2, choice: ch5, slider: 75) }
			let (:r6) { FactoryGirl.create(:response, answer: a2, choice: ch6, slider: 25) }

			let (:a3) { FactoryGirl.create(:answer, user: answer_user_1, question: q1) }
			let (:r7) { FactoryGirl.create(:response, answer: a1, choice: ch1, order: 1) }
			let (:r8) { FactoryGirl.create(:response, answer: a1, choice: ch2, order: 2) }
			let (:r9) { FactoryGirl.create(:response, answer: a1, choice: ch3, order: 3) }
			let (:r10) { FactoryGirl.create(:response, answer: a1, choice: ch4, order: 4) }

			let (:a4) { FactoryGirl.create(:answer, user: answer_user_1, question: q2) }
			let (:r11) { FactoryGirl.create(:response, answer: a2, choice: ch5, slider: 33) }
			let (:r12) { FactoryGirl.create(:response, answer: a2, choice: ch6, slider: 67) }

			before do

				category.save
				q1.save
				q2.save
				ch1.save
				ch2.save
				ch3.save
				ch4.save
				ch5.save
				ch6.save
				a1.save
				a2.save
				r1.save
				r2.save
				r3.save
				r4.save
				r5.save
				r6.save
				a3.save
				r7.save
				r8.save
				r9.save
				r10.save
				a4.save
				r11.save
				r12.save
			end

			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/questions/#{q1.id}/results", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/questions/#{q1.id}/results", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/questions/#{q1.id}/results", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with proper authorization for QT1" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/#{q1.id}/results", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }
				specify { expect(response.body).to match('results') }
				specify { expect(response.body).to match('choices') }
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('order_average') }
				specify { expect(response.body).to match('percent_average') }
				specify { expect(response.body).to match('star_average') }
				specify { expect(response.body).to match('slider_average') }
				specify { expect(response.body).to match("#{ch1.id}") }
				specify { expect(response.body).to match("#{ch2.id}") }
				specify { expect(response.body).to match("#{ch3.id}") }
				specify { expect(response.body).to match("#{ch4.id}") }
				specify { expect(response.body).to match("count") }
			end

			describe "with proper authorization for QT2" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/#{q2.id}/results", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }
				specify { expect(response.body).to match('results') }
				specify { expect(response.body).to match('choices') }
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('order_average') }
				specify { expect(response.body).to match('percent_average') }
				specify { expect(response.body).to match('star_average') }
				specify { expect(response.body).to match('slider_average') }
				specify { expect(response.body).to match("#{ch5.id}") }
				specify { expect(response.body).to match("#{ch6.id}") }
				specify { expect(response.body).to match("count") }
			end
		end

		describe "accessing results_v2 action" do

			let(:category) { FactoryGirl.create(:category) }
			let(:q1) { FactoryGirl.create(:question, user: user, category: category, title: "test 1", info: "info 1", question_type: 1) }
			let(:q2) { FactoryGirl.create(:question, user: user, category: category, title: "test 2", info: "info 2", question_type: 2) }

			let(:ch1) { FactoryGirl.create(:choice, question: q1, label: "choice 1", description: "desc 1") }
			let(:ch2) { FactoryGirl.create(:choice, question: q1, label: "choice 2", description: "desc 2") }
			let(:ch3) { FactoryGirl.create(:choice, question: q1, label: "choice 3", description: "desc 3") }
			let(:ch4) { FactoryGirl.create(:choice, question: q1, label: "choice 4", description: "desc 4") }
			let(:ch5) { FactoryGirl.create(:choice, question: q2, label: "choice 5", description: "desc 5") }
			let(:ch6) { FactoryGirl.create(:choice, question: q2, label: "choice 6", description: "desc 6") }

			let(:another_user) { FactoryGirl.create(:user) }
			let(:other_user) { FactoryGirl.create(:user) }

			let (:a1) { FactoryGirl.create(:answer, user: other_user, question: q1) }
			let (:r1) { FactoryGirl.create(:response, answer: a1, choice: ch1, order: 4) }
			let (:r2) { FactoryGirl.create(:response, answer: a1, choice: ch2, order: 3) }
			let (:r3) { FactoryGirl.create(:response, answer: a1, choice: ch3, order: 2) }
			let (:r4) { FactoryGirl.create(:response, answer: a1, choice: ch4, order: 1) }

			let (:a2) { FactoryGirl.create(:answer, user: other_user, question: q2) }
			let (:r5) { FactoryGirl.create(:response, answer: a2, choice: ch5, slider: 75) }
			let (:r6) { FactoryGirl.create(:response, answer: a2, choice: ch6, slider: 25) }

			let (:a3) { FactoryGirl.create(:answer, user: another_user, question: q1) }
			let (:r7) { FactoryGirl.create(:response, answer: a1, choice: ch1, order: 1) }
			let (:r8) { FactoryGirl.create(:response, answer: a1, choice: ch2, order: 2) }
			let (:r9) { FactoryGirl.create(:response, answer: a1, choice: ch3, order: 3) }
			let (:r10) { FactoryGirl.create(:response, answer: a1, choice: ch4, order: 4) }

			let (:a4) { FactoryGirl.create(:answer, user: another_user, question: q2) }
			let (:r11) { FactoryGirl.create(:response, answer: a2, choice: ch5, slider: 33) }
			let (:r12) { FactoryGirl.create(:response, answer: a2, choice: ch6, slider: 67) }

			before do
				category.save
				q1.save
				q2.save
				ch1.save
				ch2.save
				ch3.save
				ch4.save
				ch5.save
				ch6.save
				another_user.save
				a1.save
				a2.save
				r1.save
				r2.save
				r3.save
				r4.save
				r5.save
				r6.save
				a3.save
				r7.save
				r8.save
				r9.save
				r10.save
				a4.save
				r11.save
				r12.save
			end

			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/questions/#{q1.id}/results_v2", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/questions/#{q1.id}/results_v2", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/questions/#{q1.id}/results_v2", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with proper authorization for QT1 and no user Answer" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/#{q1.id}/results_v2", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }
				specify { expect(response.body).to match('results') }
				specify { expect(response.body).to match('choices') }
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('order_average') }
				specify { expect(response.body).to match('percent_average') }
				specify { expect(response.body).to match('star_average') }
				specify { expect(response.body).to match('slider_average') }
				specify { expect(response.body).to match("#{ch1.id}") }
				specify { expect(response.body).to match("#{ch2.id}") }
				specify { expect(response.body).to match("#{ch3.id}") }
				specify { expect(response.body).to match("#{ch4.id}") }
				specify { expect(response.body).to match("count") }
				specify { expect(response.body).not_to match("my_responses") }
			end

			describe "with proper authorization for QT2 and no user Answer" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/#{q2.id}/results_v2", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }
				specify { expect(response.body).to match('results') }
				specify { expect(response.body).to match('choices') }
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('order_average') }
				specify { expect(response.body).to match('percent_average') }
				specify { expect(response.body).to match('star_average') }
				specify { expect(response.body).to match('slider_average') }
				specify { expect(response.body).to match("#{ch5.id}") }
				specify { expect(response.body).to match("#{ch6.id}") }
				specify { expect(response.body).to match("count") }
				specify { expect(response.body).not_to match("my_responses") }
			end

			describe "with proper authorization for QT1 and YES user Answer" do
				let(:a5) { FactoryGirl.create(:answer, user: user, question: q1) }
				let(:r13) { FactoryGirl.create(:response, answer: a5, choice: ch1, order: 4) }
				let(:r14) { FactoryGirl.create(:response, answer: a5, choice: ch2, order: 3) }
				let(:r15) { FactoryGirl.create(:response, answer: a5, choice: ch3, order: 2) }
				let(:r16) { FactoryGirl.create(:response, answer: a5, choice: ch4, order: 1) }

				before do
					a5.save
					r13.save
					r14.save
					r15.save
					r16.save

					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/#{q1.id}/results_v2", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }
				specify { expect(response.body).to match('results') }
				specify { expect(response.body).to match('choices') }
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('order_average') }
				specify { expect(response.body).to match('percent_average') }
				specify { expect(response.body).to match('star_average') }
				specify { expect(response.body).to match('slider_average') }
				specify { expect(response.body).to match("#{ch1.id}") }
				specify { expect(response.body).to match("#{ch2.id}") }
				specify { expect(response.body).to match("#{ch3.id}") }
				specify { expect(response.body).to match("#{ch4.id}") }
				specify { expect(response.body).to match("count") }
				specify { expect(response.body).to match("my_responses") }
				specify { expect(response.body).to match("choice_id") }
			end

			describe "with proper authorization for QT2 and YES user Answer" do
				let(:a6) { FactoryGirl.create(:answer, user: user, question: q2) }
				let(:r17) { FactoryGirl.create(:response, answer: a6, choice: ch5, slider: 75) }
				let(:r18) { FactoryGirl.create(:response, answer: a6, choice: ch6, slider: 25) }

				before do
					a6.save
					r17.save
					r18.save

					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/#{q2.id}/results_v2", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }
				specify { expect(response.body).to match('results') }
				specify { expect(response.body).to match('choices') }
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('order_average') }
				specify { expect(response.body).to match('percent_average') }
				specify { expect(response.body).to match('star_average') }
				specify { expect(response.body).to match('slider_average') }
				specify { expect(response.body).to match("#{ch5.id}") }
				specify { expect(response.body).to match("#{ch6.id}") }
				specify { expect(response.body).to match("count") }
				specify { expect(response.body).to match("my_responses") }
				specify { expect(response.body).to match("choice_id") }
			end
		end

		describe "accessing next10WithPacks action" do
			let(:category) { FactoryGirl.create(:category) }
			let(:q1) { FactoryGirl.create(:question, user: user, category: category, title: "test 1", info: "info 1") }
			let(:q2) { FactoryGirl.create(:question, user: user, category: category, title: "test 2", info: "info 2") }
			let(:q3) { FactoryGirl.create(:question, user: user, category: category, title: "test 3", info: "info 3") }

			let(:ch1) { FactoryGirl.create(:choice, question: q1, label: "choice 1", description: "desc 1") }
			let(:ch2) { FactoryGirl.create(:choice, question: q1, label: "choice 2", description: "desc 2") }
			let(:ch3) { FactoryGirl.create(:choice, question: q2, label: "choice 3", description: "desc 3") }
			let(:ch4) { FactoryGirl.create(:choice, question: q2, label: "choice 4", description: "desc 4") }
			let(:ch5) { FactoryGirl.create(:choice, question: q3, label: "choice 5", description: "desc 5") }
			let(:ch6) { FactoryGirl.create(:choice, question: q3, label: "choice 6", description: "desc 6") }

			let(:pack) { FactoryGirl.create(:pack, title: "a test pack") }

			before do
				category.save
				q1.save
				q2.save
				q3.save
				ch1.save
				ch2.save
				ch3.save
				ch4.save
				ch5.save
				ch6.save
				pack.save
				pack.include_question!(q2)
				pack.include_question!(q3)
			end

			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/questions/next10WithPacks", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/questions/next10WithPacks", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/questions/next10WithPacks", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with proper authorization" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/next10WithPacks", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('title') }
				specify { expect(response.body).to match('info') }
				specify { expect(response.body).to match('image_url') }
				specify { expect(response.body).to match('question_type') }
				specify { expect(response.body).to match('created_at') }
				specify { expect(response.body).to match("min_value") }
				specify { expect(response.body).to match("max_value") }
				specify { expect(response.body).to match("interval") }
				specify { expect(response.body).to match("units") }
				specify { expect(response.body).to match("category") }
				specify { expect(response.body).to match('user') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).not_to match('user_id') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).to match("#{q1.title}") }
				specify { expect(response.body).to match("#{q1.info}") }
				specify { expect(response.body).to match("#{q2.title}") }
				specify { expect(response.body).to match("#{q2.info}") }
				specify { expect(response.body).to match("#{q3.title}") }
				specify { expect(response.body).to match("#{q3.info}") }
				specify { expect(response.body).to match("#{user.name}") }
				specify { expect(response.body).to match("choices") }
				specify { expect(response.body).to match("#{ch1.label}") }
				specify { expect(response.body).to match("#{ch1.description}") }
				specify { expect(response.body).to match("#{ch2.label}") }
				specify { expect(response.body).to match("#{ch2.description}") }
				specify { expect(response.body).to match("#{ch3.label}") }
				specify { expect(response.body).to match("#{ch3.description}") }
				specify { expect(response.body).to match("#{ch4.label}") }
				specify { expect(response.body).to match("#{ch4.description}") }
				specify { expect(response.body).to match("#{ch5.label}") }
				specify { expect(response.body).to match("#{ch5.description}") }
				specify { expect(response.body).to match("#{ch6.label}") }
				specify { expect(response.body).to match("#{ch6.description}") }
				specify { expect(response.body).to match("inclusions") }
				specify { expect(response.body).to match("pack_id") }
				specify { expect(response.body).to match("question_id") }
				specify { expect(response.body).to match("packs") }
				specify { expect(response.body).to match("#{pack.title}") }
			end
		end


		describe "accessing question_feed action" do
			let(:friend_user) { FactoryGirl.create(:user) }
			let(:other_user) { FactoryGirl.create(:user) }

			let(:q1) { FactoryGirl.create(:question, user: friend_user, title: "test 1") }
			let(:q2) { FactoryGirl.create(:question, user: friend_user, title: "test 2") }
			let(:q3) { FactoryGirl.create(:question, user: other_user, title: "test 3") }
			let(:q4) { FactoryGirl.create(:question, user: other_user, title: "test 4") }

			let(:ch1) { FactoryGirl.create(:choice, question: q1, label: "choice 1", description: "desc 1") }
			let(:ch2) { FactoryGirl.create(:choice, question: q1, label: "choice 2", description: "desc 2") }
			let(:ch3) { FactoryGirl.create(:choice, question: q2, label: "choice 3", description: "desc 3") }
			let(:ch4) { FactoryGirl.create(:choice, question: q2, label: "choice 4", description: "desc 4") }
			let(:ch5) { FactoryGirl.create(:choice, question: q3, label: "choice 5", description: "desc 5") }
			let(:ch6) { FactoryGirl.create(:choice, question: q3, label: "choice 6", description: "desc 6") }
			let(:ch7) { FactoryGirl.create(:choice, question: q4, label: "choice 7", description: "desc 7") }
			let(:ch8) { FactoryGirl.create(:choice, question: q4, label: "choice 8", description: "desc 8") }

			let(:pack) { FactoryGirl.create(:pack, title: "a test pack") }

			let(:sharing1) { friend_user.sharings.build(receiver_id: user.id, question_id: q1.id) }
			let(:sharing2) { other_user.sharings.build(receiver_id: user.id, question_id: q3.id) }

			let(:answer1) { friend_user.answers.build(question_id:q3.id) }

			before do
				friend_user.save
				other_user.save
				user.friend!(friend_user)

				q1.save
				q2.save
				q3.save
				q4.save
				ch1.save
				ch2.save
				ch3.save
				ch4.save
				ch5.save
				ch6.save
				ch7.save
				ch8.save

				sharing1.save
				sharing2.save

				answer1.save

				pack.save
				pack.include_question!(q2)
				pack.include_question!(q3)
			end

			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/questions/question_feed", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/questions/question_feed", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/questions/question_feed", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with proper authorization" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/question_feed", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('title') }
				specify { expect(response.body).to match('info') }
				specify { expect(response.body).to match('image_url') }
				specify { expect(response.body).to match('question_type') }
				specify { expect(response.body).to match('created_at') }
				specify { expect(response.body).to match("min_value") }
				specify { expect(response.body).to match("max_value") }
				specify { expect(response.body).to match("interval") }
				specify { expect(response.body).to match("units") }
				specify { expect(response.body).to match("category") }
				specify { expect(response.body).to match('user') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).not_to match('user_id') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).to match("#{q1.title}") }
				specify { expect(response.body).to match("#{q1.info}") }
				specify { expect(response.body).to match("#{q2.title}") }
				specify { expect(response.body).to match("#{q2.info}") }
				specify { expect(response.body).to match("#{q3.title}") }
				specify { expect(response.body).to match("#{q3.info}") }
				specify { expect(response.body).to match("#{q4.title}") }
				specify { expect(response.body).to match("#{q4.info}") }
				specify { expect(response.body).to match("#{friend_user.name}") }
				specify { expect(response.body).to match("#{other_user.name}") }
				specify { expect(response.body).to match("choices") }
				specify { expect(response.body).to match("#{ch1.label}") }
				specify { expect(response.body).to match("#{ch1.description}") }
				specify { expect(response.body).to match("#{ch2.label}") }
				specify { expect(response.body).to match("#{ch2.description}") }
				specify { expect(response.body).to match("#{ch3.label}") }
				specify { expect(response.body).to match("#{ch3.description}") }
				specify { expect(response.body).to match("#{ch4.label}") }
				specify { expect(response.body).to match("#{ch4.description}") }
				specify { expect(response.body).to match("#{ch5.label}") }
				specify { expect(response.body).to match("#{ch5.description}") }
				specify { expect(response.body).to match("#{ch6.label}") }
				specify { expect(response.body).to match("#{ch6.description}") }
				specify { expect(response.body).to match("#{ch7.label}") }
				specify { expect(response.body).to match("#{ch7.description}") }
				specify { expect(response.body).to match("#{ch8.label}") }
				specify { expect(response.body).to match("#{ch8.description}") }
				specify { expect(response.body).to match("inclusions") }
				specify { expect(response.body).to match("pack_id") }
				specify { expect(response.body).to match("question_id") }
				specify { expect(response.body).to match("packs") }
				specify { expect(response.body).to match("#{pack.title}") }
			end
		end


		describe "accessing questions_asked action" do
			let(:category) { FactoryGirl.create(:category) }
			let (:other_user) { FactoryGirl.create(:user) }

			let(:q1) { FactoryGirl.create(:question, user: user, category: category, title: "test 1", info: "info 1") }
			let(:q2) { FactoryGirl.create(:question, user: user, category: category, title: "test 2", info: "info 2") }
			let(:q3) { FactoryGirl.create(:question, user: other_user, category: category, title: "test 3", info: "info 3") }

			let(:ch1) { FactoryGirl.create(:choice, question: q1, label: "choice 1", description: "desc 1") }
			let(:ch2) { FactoryGirl.create(:choice, question: q1, label: "choice 2", description: "desc 2") }
			let(:ch3) { FactoryGirl.create(:choice, question: q2, label: "choice 3", description: "desc 3") }
			let(:ch4) { FactoryGirl.create(:choice, question: q2, label: "choice 4", description: "desc 4") }
			let(:ch5) { FactoryGirl.create(:choice, question: q3, label: "choice 5", description: "desc 5") }
			let(:ch6) { FactoryGirl.create(:choice, question: q3, label: "choice 6", description: "desc 6") }

			before do
				category.save
				other_user.save
				q1.save
				q2.save
				q3.save
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
					post "api/questions/questions_asked", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/questions/questions_asked", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/questions/questions_asked", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with proper authorization" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/questions_asked", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('title') }
				specify { expect(response.body).to match('info') }
				specify { expect(response.body).to match('image_url') }
				specify { expect(response.body).to match('question_type') }
				specify { expect(response.body).to match('created_at') }
				specify { expect(response.body).to match("min_value") }
				specify { expect(response.body).to match("max_value") }
				specify { expect(response.body).to match("interval") }
				specify { expect(response.body).to match("units") }
				specify { expect(response.body).to match("category") }
				specify { expect(response.body).to match('user') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).not_to match('user_id') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).to match("#{q1.title}") }
				specify { expect(response.body).to match("#{q1.info}") }
				specify { expect(response.body).to match("#{q2.title}") }
				specify { expect(response.body).to match("#{q2.info}") }
				specify { expect(response.body).not_to match("#{q3.title}") }
				specify { expect(response.body).not_to match("#{q3.info}") }
				specify { expect(response.body).to match("#{user.name}") }
				specify { expect(response.body).to match("choices") }
				specify { expect(response.body).to match("#{ch1.label}") }
				specify { expect(response.body).to match("#{ch1.description}") }
				specify { expect(response.body).to match("#{ch2.label}") }
				specify { expect(response.body).to match("#{ch2.description}") }
				specify { expect(response.body).to match("#{ch3.label}") }
				specify { expect(response.body).to match("#{ch3.description}") }
				specify { expect(response.body).to match("#{ch4.label}") }
				specify { expect(response.body).to match("#{ch4.description}") }
				specify { expect(response.body).not_to match("#{ch5.label}") }
				specify { expect(response.body).not_to match("#{ch5.description}") }
				specify { expect(response.body).not_to match("#{ch6.label}") }
				specify { expect(response.body).not_to match("#{ch6.description}") }
			end
		end

		describe "accessing questions_answered action" do
			let(:category) { FactoryGirl.create(:category) }
			let (:other_user) { FactoryGirl.create(:user) }

			let(:q1) { FactoryGirl.create(:question, user: other_user, category: category, title: "test 1", info: "info 1") }
			let(:q2) { FactoryGirl.create(:question, user: other_user, category: category, title: "test 2", info: "info 2") }
			let(:q3) { FactoryGirl.create(:question, user: other_user, category: category, title: "test 3", info: "info 3") }

			let(:ch1) { FactoryGirl.create(:choice, question: q1, label: "choice 1", description: "desc 1") }
			let(:ch2) { FactoryGirl.create(:choice, question: q1, label: "choice 2", description: "desc 2") }
			let(:ch3) { FactoryGirl.create(:choice, question: q2, label: "choice 3", description: "desc 3") }
			let(:ch4) { FactoryGirl.create(:choice, question: q2, label: "choice 4", description: "desc 4") }
			let(:ch5) { FactoryGirl.create(:choice, question: q3, label: "choice 5", description: "desc 5") }
			let(:ch6) { FactoryGirl.create(:choice, question: q3, label: "choice 6", description: "desc 6") }

			let(:ans1) { FactoryGirl.create(:answer, question: q1, user: user) }
			let(:ans2) { FactoryGirl.create(:answer, question: q2, user: user) }
			let(:ans3) { FactoryGirl.create(:answer, question: q3, user: other_user) }

			before do
				category.save
				other_user.save
				q1.save
				q2.save
				q3.save
				ch1.save
				ch2.save
				ch3.save
				ch4.save
				ch5.save
				ch6.save
				ans1.save
				ans2.save
				ans3.save
			end

			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/questions/questions_answered", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/questions/questions_answered", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/questions/questions_answered", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with proper authorization" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/questions_answered", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('title') }
				specify { expect(response.body).to match('info') }
				specify { expect(response.body).to match('image_url') }
				specify { expect(response.body).to match('question_type') }
				specify { expect(response.body).to match('created_at') }
				specify { expect(response.body).to match("min_value") }
				specify { expect(response.body).to match("max_value") }
				specify { expect(response.body).to match("interval") }
				specify { expect(response.body).to match("units") }
				specify { expect(response.body).to match("category") }
				specify { expect(response.body).to match('user') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).not_to match('user_id') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).to match("#{q1.title}") }
				specify { expect(response.body).to match("#{q1.info}") }
				specify { expect(response.body).to match("#{q2.title}") }
				specify { expect(response.body).to match("#{q2.info}") }
				specify { expect(response.body).not_to match("#{q3.title}") }
				specify { expect(response.body).not_to match("#{q3.info}") }
				specify { expect(response.body).to match("#{other_user.name}") }
				specify { expect(response.body).to match("choices") }
				specify { expect(response.body).to match("#{ch1.label}") }
				specify { expect(response.body).to match("#{ch1.description}") }
				specify { expect(response.body).to match("#{ch2.label}") }
				specify { expect(response.body).to match("#{ch2.description}") }
				specify { expect(response.body).to match("#{ch3.label}") }
				specify { expect(response.body).to match("#{ch3.description}") }
				specify { expect(response.body).to match("#{ch4.label}") }
				specify { expect(response.body).to match("#{ch4.description}") }
				specify { expect(response.body).not_to match("#{ch5.label}") }
				specify { expect(response.body).not_to match("#{ch5.description}") }
				specify { expect(response.body).not_to match("#{ch6.label}") }
				specify { expect(response.body).not_to match("#{ch6.description}") }
			end
		end

		describe "accessing ask_question_type_1 action" do
			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/questions/ask_question_type_1", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/ask_question_type_1", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/questions/ask_question_type_1", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/questions/ask_question_type_1", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with valid question creation" do
				before do
					params = { question: { title: 'test question title', question_type: 1, category_id: 1, hidden: 1 }, choice1: { label: 'choice label 1', image_url: 'http://example.com/image1.png' }, choice2: { label: 'choice label 2', image_url: 'http://example.com/image2.png' }, choice3: { label: 'choice label 3', image_url: 'http://example.com/image3.png' }, choice4: { label: 'choice label 4' }, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/ask_question_type_1", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('question') }	
				specify { expect(response.body).to match('id') }	
				specify { expect(response.body).to match('title') }	
				specify { expect(response.body).to match('info') }	
				specify { expect(response.body).to match('image_url') }	
				specify { expect(response.body).to match('question_type') }	
				specify { expect(response.body).to match('created_at') }	
				specify { expect(response.body).to match('updated_at') }	
				specify { expect(response.body).to match('min_value') }	
				specify { expect(response.body).to match('max_value') }	
				specify { expect(response.body).to match('interval') }	
				specify { expect(response.body).to match('units') }	
				specify { expect(response.body).to match('hidden') }	
				specify { expect(response.body).to match('choices') }	
				specify { expect(response.body).to match('label') }	
				specify { expect(response.body).to match('description') }	
				specify { expect(response.body).to match('user') }	
				specify { expect(response.body).to match('name') }	
				specify { expect(response.body).to match('username') }	
				specify { expect(response.body).not_to match('user_id') }	
			end
		end

		describe "accessing ask_question_type_2 action" do
			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/questions/ask_question_type_2", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/ask_question_type_2", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/questions/ask_question_type_2", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/questions/ask_question_type_2", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with valid question creation" do
				before do
					params = { question: { title: 'test question title', question_type: 2, category_id: 1, min_value: 0, max_value: 100, interval: 2, units: 'hr', hidden: 1 }, choice1: { label: 'choice label 1', image_url: 'http://example.com/image1.png' }, choice2: { label: 'choice label 2' }, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/ask_question_type_2", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('question') }	
				specify { expect(response.body).to match('id') }	
				specify { expect(response.body).to match('title') }	
				specify { expect(response.body).to match('info') }	
				specify { expect(response.body).to match('image_url') }	
				specify { expect(response.body).to match('question_type') }	
				specify { expect(response.body).to match('created_at') }	
				specify { expect(response.body).to match('updated_at') }	
				specify { expect(response.body).to match('min_value') }	
				specify { expect(response.body).to match('max_value') }	
				specify { expect(response.body).to match('interval') }	
				specify { expect(response.body).to match('units') }	
				specify { expect(response.body).to match('hidden') }	
				specify { expect(response.body).to match('choices') }	
				specify { expect(response.body).to match('label') }	
				specify { expect(response.body).to match('description') }	
				specify { expect(response.body).to match('user') }	
				specify { expect(response.body).to match('name') }	
				specify { expect(response.body).to match('username') }	
				specify { expect(response.body).not_to match('user_id') }
			end
		end

		describe "accessing ask_question_type_3 action" do
			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/questions/ask_question_type_3", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/ask_question_type_3", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/questions/ask_question_type_3", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/questions/ask_question_type_3", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with valid question creation" do
				before do
					params = { question: { title: 'test question title', question_type: 3, category_id: 1, hidden: 1 }, choice1: { label: 'choice label 1', image_url: 'http://example.com/image1.png' }, choice2: { label: 'choice label 2', image_url: 'http://example.com/image2.png' }, choice3: { label: 'choice label 3', image_url: 'http://example.com/image3.png' }, choice4: { label: 'choice label 4' }, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/ask_question_type_3", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('question') }	
				specify { expect(response.body).to match('id') }	
				specify { expect(response.body).to match('title') }	
				specify { expect(response.body).to match('info') }	
				specify { expect(response.body).to match('image_url') }	
				specify { expect(response.body).to match('question_type') }	
				specify { expect(response.body).to match('created_at') }	
				specify { expect(response.body).to match('updated_at') }	
				specify { expect(response.body).to match('min_value') }	
				specify { expect(response.body).to match('max_value') }	
				specify { expect(response.body).to match('interval') }	
				specify { expect(response.body).to match('units') }	
				specify { expect(response.body).to match('hidden') }	
				specify { expect(response.body).to match('choices') }	
				specify { expect(response.body).to match('label') }	
				specify { expect(response.body).to match('description') }	
				specify { expect(response.body).to match('user') }	
				specify { expect(response.body).to match('name') }	
				specify { expect(response.body).to match('username') }	
				specify { expect(response.body).not_to match('user_id') }	
			end
		end

		describe "accessing ask_question_type_4 action" do
			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/questions/ask_question_type_4", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/ask_question_type_4", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/questions/ask_question_type_4", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/questions/ask_question_type_4", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with valid question creation" do
				before do
					params = { question: { title: 'test question title', question_type: 4, category_id: 1, hidden: 1 }, choice1: { label: 'choice label 1', image_url: 'http://example.com/image1.png' }, choice2: { label: 'choice label 2', image_url: 'http://example.com/image2.png' }, choice3: { label: 'choice label 3', image_url: 'http://example.com/image3.png' }, choice4: { label: 'choice label 4' }, choice5: { label: 'choice label 5' }, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/ask_question_type_4", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('question') }	
				specify { expect(response.body).to match('id') }	
				specify { expect(response.body).to match('title') }	
				specify { expect(response.body).to match('info') }	
				specify { expect(response.body).to match('image_url') }	
				specify { expect(response.body).to match('question_type') }	
				specify { expect(response.body).to match('created_at') }	
				specify { expect(response.body).to match('updated_at') }	
				specify { expect(response.body).to match('min_value') }	
				specify { expect(response.body).to match('max_value') }	
				specify { expect(response.body).to match('interval') }	
				specify { expect(response.body).to match('units') }	
				specify { expect(response.body).to match('hidden') }	
				specify { expect(response.body).to match('choices') }	
				specify { expect(response.body).to match('label') }	
				specify { expect(response.body).to match('description') }	
				specify { expect(response.body).to match('user') }	
				specify { expect(response.body).to match('name') }	
				specify { expect(response.body).to match('username') }	
				specify { expect(response.body).not_to match('user_id') }	
			end
		end

		describe "accessing ask_question_type_5 action" do
			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/questions/ask_question_type_5", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/ask_question_type_5", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/questions/ask_question_type_5", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/questions/ask_question_type_5", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with valid question creation" do
				before do
					params = { question: { title: 'test question title', question_type: 4, category_id: 1, hidden: 1 }, choice1: { label: 'choice label 1', image_url: 'http://example.com/image1.png' }, choice2: { label: 'choice label 2', image_url: 'http://example.com/image2.png' }, choice3: { label: 'choice label 3', image_url: 'http://example.com/image3.png' }, choice4: { label: 'choice label 4' }, choice5: { label: 'choice label 5' }, choice6: { label: 'choice label 6' }, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/ask_question_type_5", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('question') }	
				specify { expect(response.body).to match('id') }	
				specify { expect(response.body).to match('title') }	
				specify { expect(response.body).to match('info') }	
				specify { expect(response.body).to match('image_url') }	
				specify { expect(response.body).to match('question_type') }	
				specify { expect(response.body).to match('created_at') }	
				specify { expect(response.body).to match('updated_at') }	
				specify { expect(response.body).to match('min_value') }	
				specify { expect(response.body).to match('max_value') }	
				specify { expect(response.body).to match('interval') }	
				specify { expect(response.body).to match('units') }	
				specify { expect(response.body).to match('hidden') }	
				specify { expect(response.body).to match('choices') }	
				specify { expect(response.body).to match('label') }	
				specify { expect(response.body).to match('description') }	
				specify { expect(response.body).to match('user') }	
				specify { expect(response.body).to match('name') }	
				specify { expect(response.body).to match('username') }	
				specify { expect(response.body).not_to match('user_id') }	
			end
		end

		describe "accessing share_question action" do
			let(:category) { FactoryGirl.create(:category) }
			let(:q1) { FactoryGirl.create(:question, user: user, category: category, title: "test 1", info: "info 1") }

			let(:ch1) { FactoryGirl.create(:choice, question: q1, label: "choice 1", description: "desc 1") }
			let(:ch2) { FactoryGirl.create(:choice, question: q1, label: "choice 2", description: "desc 2") }

			let(:other_user) { FactoryGirl.create(:user) }

			before do
				category.save
				q1.save
				ch1.save
				ch2.save
				other_user.save
			end

			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/questions/share_question", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/share_question", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/questions/share_question", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/questions/share_question", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with valid sharing creation" do
				before do
					params = { sharing: { question_id: q1.id, receiver_id: other_user.id}, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/share_question", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('sharing') }	
				specify { expect(response.body).to match('id') }	
				specify { expect(response.body).to match('sender_id') }	
				specify { expect(response.body).to match('receiver_id') }	
				specify { expect(response.body).to match('question_id') }	
				specify { expect(response.body).to match('created_at') }	
				specify { expect(response.body).to match('updated_at') }	
				specify { expect(response.body).to match("#{user.id}") }	
				specify { expect(response.body).to match("#{other_user.id}") }
				specify { expect(response.body).to match("#{q1.id}") }
				specify { expect(response.body).to match("question") }
				specify { expect(response.body).to match("title") }
				specify { expect(response.body).to match("info") }
				specify { expect(response.body).to match("image_url") }
				specify { expect(response.body).to match("question_type") }
				specify { expect(response.body).to match("category") }
				specify { expect(response.body).to match("choices") }
				specify { expect(response.body).to match("#{category.id}") }
				specify { expect(response.body).to match("#{category.name}") }
				specify { expect(response.body).to match("#{ch1.id}") }
				specify { expect(response.body).to match("#{ch1.label}") }
				specify { expect(response.body).to match("#{ch2.id}") }
				specify { expect(response.body).to match("#{ch2.label}") }
				specify { expect(response.body).to match("#{user.name}") }
				specify { expect(response.body).to match("#{user.username}") }
			end
		end

		describe "accessing shared_with_me action" do
			let(:another_user1) { FactoryGirl.create(:user) }
			let(:another_user2) { FactoryGirl.create(:user) }
			let(:other_user) { FactoryGirl.create(:user) }

			let(:q1) { FactoryGirl.create(:question, user: another_user1, title: "test 1") }
			let(:q2) { FactoryGirl.create(:question, user: another_user1, title: "test 2") }
			let(:q3) { FactoryGirl.create(:question, user: another_user1, title: "test 3") }

			let(:sharing1) { another_user1.sharings.build(receiver_id: user.id, question_id: q1.id) }
			let(:sharing2) { another_user2.sharings.build(receiver_id: user.id, question_id: q2.id) }

			before do
				another_user1.save
				another_user2.save
				other_user.save

				q1.save
				q2.save
				q3.save

				sharing1.save
				sharing2.save
			end

			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/questions/shared_with_me", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/questions/shared_with_me", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/questions/shared_with_me", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with proper authorization" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/questions/shared_with_me", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('sharings') }	
				specify { expect(response.body).to match('senders') }	
				specify { expect(response.body).to match('id') }	
				specify { expect(response.body).to match('sender_id') }	
				specify { expect(response.body).to match('receiver_id') }	
				specify { expect(response.body).to match('question_id') }	
				specify { expect(response.body).to match('created_at') }	
				specify { expect(response.body).to match('updated_at') }
				specify { expect(response.body).to match("#{another_user1.id}") }
				specify { expect(response.body).to match("#{another_user2.id}") }
				specify { expect(response.body).to match("#{another_user1.name}") }
				specify { expect(response.body).to match("#{another_user2.name}") }
				specify { expect(response.body).to match("#{another_user1.username}") }
				specify { expect(response.body).to match("#{another_user2.username}") }
				specify { expect(response.body).to match("#{q1.id}") }
				specify { expect(response.body).to match("#{q2.id}") }
				specify { expect(response.body).to match("#{q1.title}") }
				specify { expect(response.body).to match("#{q2.title}") }
				specify { expect(response.body).to match("question") }
				specify { expect(response.body).to match("title") }
				specify { expect(response.body).to match("info") }
				specify { expect(response.body).to match("image_url") }
				specify { expect(response.body).to match("question_type") }
				specify { expect(response.body).to match("category") }
				specify { expect(response.body).to match("choices") }
				specify { expect(response.body).not_to match("#{other_user.id}") }
				specify { expect(response.body).not_to match("#{other_user.name}") }
				specify { expect(response.body).not_to match("#{other_user.username}") }
				specify { expect(response.body).not_to match("#{q3.id}") }
				specify { expect(response.body).not_to match("#{q3.title}") }
				specify { expect(response.body).to match("questions") }
			end
		end

	end

end