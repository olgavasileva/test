class Quantcast
  attr_reader :question, :choice

  def initialize question, choice = nil
    @question = question
    @choice = choice
  end

  def use_sample_data= bool
    @use_sample_data = bool
  end

  def use_sample_data?
    !!@use_sample_data
  end

  def info id
    info = data[:demographics].find{|d| d[:id] == id}
    largest = info[:buckets].sort_by{|b| b[:index]}.last if info
    info.merge(largest_bucket: largest) if info
  end

  def gender_info
    info "GENDER"
  end

  def age_info
    info "AGE"
  end

  def maleage_info
    info 'MALEAGE'
  end

  def femaleage_info
    info 'FEMALEAGE'
  end

  def children_info
    info 'CHILDREN'
  end

  def income_info
    info 'INCOME'
  end

  def education_info
    info 'EDUCATION'
  end

  def ethnicity_info
    info 'ETHNICITY'
  end

  def signature
    md5 = Digest::MD5.new
    md5 << api_key
    md5 << Figaro.env.QUANTCAST_SHARED_SECRET
    md5 << Time.now.utc.to_i.to_s
    md5.hexdigest
  end

  private

    def url
      File.join Figaro.env.QUANTCAST_BASE_URL, "networks/#{p_code}/segments/#{segment}/demographics"
    end

    def p_code
      Figaro.env.QUANTCAST_P_CODE
    end

    def segment
      @choice ? "#{@question.id}.#{@choice.id}" : @question.id
    end

    def api_key
      Figaro.env.QUANTCAST_API_KEY
    end

    def params
      { country: "US", platform: 'all', api_key: api_key, sig: signature }
    end

    def response
      if use_sample_data?
        OpenStruct.new body: sample_json_data
      else
        Faraday.get url, params
      end
    end

    def data
      @data ||= JSON.parse response.body, {symbolize_names: true}
    end

    def sample_json_data
      <<-END
          {
              "country": {
                  "code": "US",
                  "id": "US",
                  "name": "United States"
              },

              "demographics": [
                  {
                      "buckets": [
                          {
                              "index": 55,
                              "name": "Male",
                              "percent": 0.26822730898857117
                          },
                          {
                              "index": 143,
                              "name": "Female",
                              "percent": 0.7317727208137512
                          }
                      ],
                      "id": "GENDER",
                      "name": "Gender"
                  },
                  {
                      "buckets": [
                          {
                              "index": 27,
                              "name": "< 18",
                              "percent": 0.04899810999631882
                          },
                          {
                              "index": 107,
                              "name": "18-24",
                              "percent": 0.13299041986465454
                          },
                          {
                              "index": 149,
                              "name": "25-34",
                              "percent": 0.25696510076522827
                          },
                          {
                              "index": 112,
                              "name": "35-44",
                              "percent": 0.2150430679321289
                          },
                          {
                              "index": 120,
                              "name": "45-54",
                              "percent": 0.20722565054893494
                          },
                          {
                              "index": 91,
                              "name": "55-64",
                              "percent": 0.09127848595380783
                          },
                          {
                              "index": 86,
                              "name": "65+",
                              "percent": 0.047499194741249084
                          }
                      ],
                      "id": "AGE",
                      "name": "Age"
                  },
                  {
                      "buckets": [
                          {
                              "index": 14,
                              "name": "Male < 18",
                              "percent": 0.01279696449637413
                          },
                          {
                              "index": 50,
                              "name": "Male 18-24",
                              "percent": 0.03250908479094505
                          },
                          {
                              "index": 68,
                              "name": "Male 25-34",
                              "percent": 0.06046846881508827
                          },
                          {
                              "index": 60,
                              "name": "Male 35-44",
                              "percent": 0.05879722535610199
                          },
                          {
                              "index": 67,
                              "name": "Male 45-54",
                              "percent": 0.0578799769282341
                          },
                          {
                              "index": 59,
                              "name": "Male 55-64",
                              "percent": 0.029282033443450928
                          },
                          {
                              "index": 69,
                              "name": "Male 65+",
                              "percent": 0.016485659405589104
                          }
                      ],
                      "id": "MALEAGE",
                      "name": "Age for Males"
                  },
                  {
                      "buckets": [
                          {
                              "index": 41,
                              "name": "Female < 18",
                              "percent": 0.03620114177465439
                          },
                          {
                              "index": 168,
                              "name": "Female 18-24",
                              "percent": 0.10048133134841919
                          },
                          {
                              "index": 236,
                              "name": "Female 25-34",
                              "percent": 0.1964966207742691
                          },
                          {
                              "index": 165,
                              "name": "Female 35-44",
                              "percent": 0.15624584257602692
                          },
                          {
                              "index": 173,
                              "name": "Female 45-54",
                              "percent": 0.14934568107128143
                          },
                          {
                              "index": 121,
                              "name": "Female 55-64",
                              "percent": 0.0619964525103569
                          },
                          {
                              "index": 98,
                              "name": "Female 65+",
                              "percent": 0.03101353533565998
                          }
                      ],
                      "id": "FEMALEAGE",
                      "name": "Age for Females"
                  },
                  {
                      "buckets": [
                          {
                              "index": 129,
                              "name": "No Kids ",
                              "percent": 0.6508865356445312
                          },
                          {
                              "index": 71,
                              "name": "Has Kids ",
                              "percent": 0.34911346435546875
                          }
                      ],
                      "id": "CHILDREN",
                      "name": "Children in Household"
                  },
                  {
                      "buckets": [
                          {
                              "index": 96,
                              "name": "$0-50k",
                              "percent": 0.4860217571258545
                          },
                          {
                              "index": 102,
                              "name": "$50-100k",
                              "percent": 0.2973894476890564
                          },
                          {
                              "index": 117,
                              "name": "$100-150k",
                              "percent": 0.14187024533748627
                          },
                          {
                              "index": 89,
                              "name": "$150k+",
                              "percent": 0.07471854984760284
                          }
                      ],
                      "id": "INCOME",
                      "name": "Household Income"
                  },
                  {
                      "buckets": [
                          {
                              "index": 73,
                              "name": "No College",
                              "percent": 0.3260171711444855
                          },
                          {
                              "index": 121,
                              "name": "College",
                              "percent": 0.4927719235420227
                          },
                          {
                              "index": 126,
                              "name": "Grad School",
                              "percent": 0.18121090531349182
                          }
                      ],
                      "id": "EDUCATION",
                      "name": "Education Level"
                  },
                  {
                      "buckets": [
                          {
                              "index": 103,
                              "name": "Caucasian",
                              "percent": 0.7807833552360535
                          },
                          {
                              "index": 96,
                              "name": "African American",
                              "percent": 0.08745797723531723
                          },
                          {
                              "index": 81,
                              "name": "Asian",
                              "percent": 0.03431972861289978
                          },
                          {
                              "index": 88,
                              "name": "Hispanic",
                              "percent": 0.0832706093788147
                          },
                          {
                              "index": 101,
                              "name": "Other",
                              "percent": 0.014168291352689266
                          }
                      ],
                      "id": "ETHNICITY",
                      "name": "Ethnicity"
                  }
              ],

              "freshness": {
                  "next_expected_update": "2013-03-29T01:00:59Z",
                  "updated": "2013-03-24T22:09:08Z"
              },

              "name": "foo.com",
              "p-code": "p-7e79989ggfx46",
              "quantified": true
          }
      END
    end
end