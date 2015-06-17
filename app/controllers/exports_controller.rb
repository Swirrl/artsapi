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

  # dump all people with as many fields as possible
  def person_dump_csv
    # TODO! Exports.dump_people_as_csv
  end

end