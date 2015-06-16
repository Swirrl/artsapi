class ExportsController < ApplicationController

  before_filter :authenticate_user!

  # a list of all people with some key fields
  def person_export_csv
    # TODO! Exports.assemble_person_list_csv
  end

  # weighted connections in a matrix
  def person_matrix_csv
    # TODO! Exports.assemble_person_matrix_csv
  end


end