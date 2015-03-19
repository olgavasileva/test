require 'rails_helper'

RSpec.describe 'views/api/embeddable_unit.jbuilder' do

  let(:unit) { FactoryGirl.create(:embeddable_unit) }
  before { assign(:unit, unit) }
  before { render template: 'api/embeddable_unit' }

  let(:json) { JSON.parse(rendered) }
  subject { json }

  it { is_expected.to have_json_key(:embeddable_unit) }
end
