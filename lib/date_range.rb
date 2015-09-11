class DateRange

  PROJECT_START_DATE = Date.parse('Jun 8, 2014')

  attr_accessor :start_date, :end_date
  def initialize(start_date, end_date = Date.today)
    @start_date, @end_date = start_date, end_date
  end
end