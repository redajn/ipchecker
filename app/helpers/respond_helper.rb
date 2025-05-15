module RespondHelper
  STATUS_MAP = {
    not_found: 404,
    already_exists: 409,
    already_state: 409,
    validation: 422,
    db_error: 500
  }.freeze

  def respond(result)
    if result.success?
      result.value!
    else
      response.status = STATUS_MAP.fetch(result.failure[:code], 500)
      result.failure
    end
  end
end
