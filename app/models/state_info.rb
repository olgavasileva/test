class StateInfo
  def initialize abbr
    @abbr = abbr
  end

  def region
    info = @abbr && lookup[@abbr.to_sym]

    if info
      info[:region]
    else
      'Unclassified'
    end
  end

  def lookup
    @looup ||= {
                AK: {name: 'Alaska', region: 'West'},
                AL: {name: 'Alabama', region: 'South'},
                AR: {name: 'Arkansas', region: 'South'},
                AS: {name: 'American Samoa', region: 'West'},
                AZ: {name: 'Arizona', region: 'West'},
                CA: {name: 'California', region: 'West'},
                CO: {name: 'Colorado', region: 'West'},
                CT: {name: 'Connecticut', region: 'Northeast'},
                DC: {name: 'District of Columbia', region: 'South'},
                DE: {name: 'Delaware', region: 'South'},
                FL: {name: 'Florida', region: 'South'},
                GA: {name: 'Georgia', region: 'South'},
                HI: {name: 'Hawaii', region: 'West'},
                IA: {name: 'Iowa', region: 'Midwest'},
                ID: {name: 'Idaho', region: 'West'},
                IL: {name: 'Illinois', region: 'Midwest'},
                IN: {name: 'Indiana', region: 'Midwest'},
                KS: {name: 'Kansas', region: 'Midwest'},
                KY: {name: 'Kentucky', region: 'South'},
                LA: {name: 'Louisiana', region: 'South'},
                MA: {name: 'Massachusetts', region: 'Northeast'},
                MD: {name: 'Maryland', region: 'South'},
                ME: {name: 'Maine', region: 'Northeast'},
                MI: {name: 'Michigan', region: 'Midwest'},
                MN: {name: 'Minnesota', region: 'Midwest'},
                MO: {name: 'Missouri', region: 'Midwest'},
                MP: {name: 'Northern Islands', region: 'West'},
                MS: {name: 'Mississippi', region: 'South'},
                MT: {name: 'Montana', region: 'West'},
                NC: {name: 'North Carolina', region: 'South'},
                ND: {name: 'North Dakota', region: 'Midwest'},
                NE: {name: 'Nebraska', region: 'Midwest'},
                NH: {name: 'New Hampshire', region: 'Northeast'},
                NJ: {name: 'New Jersey', region: 'Northeast'},
                NM: {name: 'New Mexico', region: 'West'},
                NV: {name: 'Nevada', region: 'West'},
                NY: {name: 'New York', region: 'Northeast'},
                OH: {name: 'Ohio', region: 'Midwest'},
                OK: {name: 'Oklahoma', region: 'South'},
                OR: {name: 'Oregon', region: 'West'},
                PA: {name: 'Pennsylvania', region: 'Northeast'},
                PR: {name: 'Puerto Rico', region: 'South'},
                RI: {name: 'Rhode Island', region: 'Northeast'},
                SC: {name: 'South Carolina', region: 'South'},
                SD: {name: 'South Dakota', region: 'Midwest'},
                TN: {name: 'Tennessee', region: 'South'},
                TX: {name: 'Texas', region: 'South'},
                UT: {name: 'Utah', region: 'West'},
                VA: {name: 'Virginia', region: 'South'},
                VI: {name: 'Virgin Islands', region: 'South'},
                VT: {name: 'Vermont', region: 'Northeast'},
                WA: {name: 'Washington', region: 'West'},
                WI: {name: 'Wisconsin', region: 'Midwest'},
                WV: {name: 'West Virginia', region: 'South'},
                WY: {name: 'Wyoming', region: 'West'}
              }
  end
end