module People
  module Associations
    module GroupedBy
      class OppositionController < ApplicationController
        before_action :data_check, :build_request

        ROUTE_MAP = {
          index:   proc { |params| Parliament::Utils::Helpers::ParliamentHelper.parliament_request.person_associations_grouped_by_opposition.set_url_params({ person_id: params[:person_id] }) },
        }.freeze

        def index
          @person, @seat_incumbencies, @opposition_incumbencies = Parliament::Utils::Helpers::FilterHelper.filter(@request, 'Person', 'SeatIncumbency', 'OppositionIncumbency')

          @person = @person.first

          # Only seat incumbencies, not committee roles are being grouped
          incumbencies = Parliament::Utils::Helpers::RoleGroupingHelper.group(@seat_incumbencies, :constituency, :graph_id)

          @sorted_incumbencies = Parliament::NTriple::Utils.sort_by({
            list:             @person.incumbencies,
            parameters:       [:start_date],
            prepend_rejected: false
          })

          Parliament::Utils::Helpers::HistoryHelper.reset
          Parliament::Utils::Helpers::HistoryHelper.add(@opposition_incumbencies.to_a)
          @history = Parliament::Utils::Helpers::HistoryHelper.history
        end
      end
    end
  end
end
