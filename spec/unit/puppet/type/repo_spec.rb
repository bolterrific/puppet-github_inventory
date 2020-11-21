# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/repo'

RSpec.describe 'the repo type' do
  it 'loads' do
    expect(Puppet::Type.type(:repo)).not_to be_nil
  end
end
