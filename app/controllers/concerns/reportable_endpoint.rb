module ReportableEndpoint
  def respond(relation)
    respond_to do |format|
      format.html
      format.csv do
        headers['Content-disposition'] = generate_disposition relation.model
        headers['Content-type'] = 'text/csv'
      end
    end
  end

  private
  def generate_disposition(model)
    time = DateTime.now.strftime("%Y%m%d%H%M")
    "attachment; filename=\"#{model}_#{time}.csv\""
  end
end
