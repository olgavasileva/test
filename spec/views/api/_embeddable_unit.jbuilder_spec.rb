require 'rails_helper'

RSpec.describe 'views/api/_embeddable_unit.jbuilder' do
  before(:all) { @unit = FactoryGirl.create(:embeddable_unit) }
  after(:all) { @unit.destroy! }
  let(:unit) { @unit }

  before { render partial: 'api/embeddable_unit', locals: {unit: unit} }

  let(:json) { JSON.parse(rendered) }
  subject { json }

  it { is_expected.to have_json_key(:uuid).eq(unit.uuid) }
  it { is_expected.to have_json_key(:width).eq(unit.width) }
  it { is_expected.to have_json_key(:height).eq(unit.height) }
  it { is_expected.to have_json_key(:thank_you_markdown).eq(unit.thank_you_markdown) }
  it { is_expected.to have_json_key(:thank_you_html).eq(unit.thank_you_html) }
end
