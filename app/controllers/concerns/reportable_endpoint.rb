module ReportableEndpoint
  def filter(model)
    query, show_all = params[:q], params[:all]
    results = model.search(query.nil? ? '' : query)
    show_all ? results : results.limit(50)
  end

  def respond(relation)
    respond_to do |format|
      format.html
      format.csv do
        headers['Content-disposition'] = generate_disposition relation
        headers['Content-type'] ||= 'text/csv'
      end
    end
  end

  private
  def generate_disposition(relation)
    query, time = params[:q], DateTime.now.strftime("%Y%m%d%H%M")
    if query.blank?
      filename = "#{relation.model}_#{time}.csv"
    else
      # Substring the query so there's no overflow in the filename
      filename = "#{relation.model}_#{query[0..25]}_#{time}.csv"
    end
    "attachment; filename=\"#{filename}\""
  end
end
