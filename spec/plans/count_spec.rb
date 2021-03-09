require 'pry'
require 'spec_helper'
require 'bolt_spec/plans'

describe 'github_inventory::count' do
  include BoltSpec::Plans  # Include the BoltSpec library functions

  def inventory_data
    YAML.load_file(File.expand_path('spec/fixtures/inventory.yaml'))
  end

  context 'when "github_repos" inventory group contains 2 targets' do
    let(:targets){ 'github_repos' }
    let(:expected_count){ inventory.get_targets(targets).size }
    subject(:plan_result){ run_plan('github_inventory::count', params ) }

    context 'with default parameteres' do
      let(:params){ {} }

      before(:each){
        expect_out_message.with_params("Target count: #{expected_count}")
      }

      it 'counts expected number of targets using out::message' do
        expect(plan_result.ok?).to be(true)
      end

      it( 'returns nothing' ){ expect(plan_result.value).to be_nil }
    end

    context 'with display_result => false, return_result => true' do
      let(:params){{
        'display_result' => false,
        'return_result'  => true,
      }}

      before(:each){ allow_out_message.not_be_called }

      it 'outputs nothing via out::message' do
        expect(plan_result.ok?).to be(true)
      end

      it 'returns the correct number of targets' do
        expect(plan_result.ok?).to be(true)
        expect(plan_result.value).to eql( { 'target_count' => expected_count } )
      end
    end
  end

end


