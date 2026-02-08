require "rails_helper"

RSpec.describe ScoreCalculator do
    it "calculate return work/density/total" do
      run = double("DailyCourseRun", odo_start_km: 0, odo_end_km: 0)

      stops = double("StopsRelation", count: 0, sum: 0)

      association = double("StopsAssociation")
      allow(run).to receive(:daily_course_run_stops).and_return(association)
      allow(association).to receive_message_chain(:where, :not).and_return(stops)

      result = described_class.new(run).calculate

      expect(result.keys).to eq %i[work density total]
    end
end
