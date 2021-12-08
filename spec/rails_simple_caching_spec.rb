# frozen_string_literal: true

RSpec.describe RailsSimpleCaching do
  it "has a version number" do
    expect(RailsSimpleCaching::VERSION).not_to be nil
  end

  it "works in a dummy Rails environment" do
    expect(Rails.application).to be_truthy
  end
end
