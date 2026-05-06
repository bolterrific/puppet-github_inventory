require 'pry'
require 'spec_helper'
require 'bolt_spec/plans'

describe 'github_inventory::count' do
  include BoltSpec::Plans  # Include the BoltSpec library functions

  def modulepath
    [File.expand_path('../fixtures/modules', __dir__)]
  end

  def inventory_data
    YAML.load_file(File.expand_path('spec/fixtures/inventory.yaml'))
  end

  # Configure Puppet and Bolt before running any tests
  # rubocop:disable RSpec/BeforeAfterAll
  before(:all) do
    BoltSpec::Plans.init
  end
  # rubocop:enable RSpec/BeforeAfterAll

  context 'when "github_repos" inventory group contains 2 targets' do
    subject(:plan_result) { run_plan('github_inventory::count', params) }

    let(:targets) { 'github_repos' }
    let(:expected_count) { inventory.get_targets(targets).size }

    context 'with default parameteres' do
      let(:params) { {} }

      before(:each) do
        expect_out_message.with_params("Target count: #{expected_count}")
      end

      it 'counts expected number of targets using out::message' do
        expect(plan_result.ok?).to be(true)
      end

      it('returns nothing') { expect(plan_result.value).to be_nil }
    end

    context 'with display_result => false, return_result => true' do
      let(:params) do
        {
          'display_result' => false,
          'return_result'  => true,
        }
      end

      before(:each) { allow_out_message.not_be_called }

      it 'outputs nothing via out::message' do
        expect(plan_result.ok?).to be(true)
      end

      it 'returns the correct number of targets' do
        expect(plan_result.ok?).to be(true)
        expect(plan_result.value).to eql({ 'target_count' => expected_count })
      end
    end
  end
end
