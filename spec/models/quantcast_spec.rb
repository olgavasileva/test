require 'rails_helper'

describe Quantcast do

  describe :signature do
    let(:apikey) {'2fvmer3qbk7f3jnqneg58bu2'}
    let(:secret) {'qvxkmw57pec7'}
    let(:timestamp) {'1200603038'}

    let(:signature) {'65a08176826fa4621116997e1dd775fa'}

    before do
      allow(Figaro).to receive_message_chain(:env, "QUANTCAST_API_KEY").and_return(apikey)
      allow(Figaro).to receive_message_chain(:env, "QUANTCAST_SHARED_SECRET").and_return(secret)
      allow(Time).to receive_message_chain(:now, :utc, :to_i, :to_s).and_return(timestamp)
    end

    it {expect(Quantcast.new(1).signature).to eq signature}
  end

end
