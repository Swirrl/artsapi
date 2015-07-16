class ExportsWorker

  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options :retry => 3, :dead => false

  def perform(export_type, current_user_id)

    logger.debug "> [Sidekiq]: exporting #{export_type}, triggered by #{User.current_user.email}"

    case export_type
    when 'person_list'
      content = Exports.assemble_person_list_csv
    when 'person_dump'
      content = Exports.dump_people_as_csv
    when 'person_matrix'
      content = Exports.assemble_person_matrix_csv
    end

    Exports.create_tempfile_and_upload!(content, export_type)

  end
end