class ExportsController < ApplicationController

  before_filter :authenticate_user!

  # a list of all people with some key fields
  def person_export_csv
    begin
      export_file_async(:person_list)
      render nothing: true, status: 202
    rescue
      render nothing: true, status: 500
    end
  end

  # weighted connections in a matrix
  def person_matrix_csv
    begin
      export_file_async(:person_matrix)
      render nothing: true, status: 202
    rescue
      render nothing: true, status: 500
    end
  end

  # dump all people with as many fields as possible
  def person_dump_csv
    begin
      export_file_async(:person_dump)
      render nothing: true, status: 202
    rescue
      render nothing: true, status: 500
    end
  end

  private

  def export_file_async(type)
    export_type = type.to_s

    current_user_id = User.current_user.id.to_s
    job_id = ::ExportsWorker.perform_in(10.seconds, export_type, current_user_id)

    User.add_job_for_current_user(job_id)

    job_id
  end

end