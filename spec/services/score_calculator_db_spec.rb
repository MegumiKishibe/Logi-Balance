require "rails_helper"

RSpec.describe ScoreCalculator do
  it "increase density score when distance per stop is high" do
    employee = Employee.create!(
      employee_no: "T#{SecureRandom.hex(3)}",
      last_name_ja: "山本",
      first_name_ja: "航",
      last_name_en: "Yamamoto",
      first_name_en: "Wataru",
      hired_on: Date.current,
      password: "password",
      password_confirmation: "password"
    )

    vehicle_type = VehicleType.create!(
      name: "2t"
    )

    delivery_route = DeliveryRoute.create!(
      name: "Test Route",
      vehicle_type: vehicle_type
    )

    common_attrs = {
      employee: employee,
      delivery_route: delivery_route,
      service_date: Date.current,
      started_at: Time.current
    }

    run0 = DailyCourseRun.create!(common_attrs.merge(odo_start_km: 0, odo_end_km: 0))
    run100 = DailyCourseRun.create!(common_attrs.merge(odo_start_km: 0, odo_end_km: 100))

    destination = Destination.create!(
      name: "Test Destination",
      address: "Test Address"
    )

    10.times do
      DailyCourseRunStop.create!(
        daily_course_run: run0,
        destination: destination,
        packages_count: 0,
        pieces_count: 0,
        completed_at: Time.current
      )

      DailyCourseRunStop.create!(
        daily_course_run: run100,
        destination: destination,
        packages_count: 0,
        pieces_count: 0,
        completed_at: Time.current
      )
    end

    density0 = ScoreCalculator.new(run0).calculate[:density]
    density100 = ScoreCalculator.new(run100).calculate[:density]

    expect(density100).to be > density0
  end
end
