# frozen_string_literal: true

RSpec.configure do |c|
  c.before do
    stub_const('ImageOptim::Config::GLOBAL_PATH', File::NULL)
    stub_const('ImageOptim::Config::LOCAL_PATH', File::NULL)
  end

  c.order = :random
end
