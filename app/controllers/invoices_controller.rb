class InvoicesController < ApplicationController
  print_action_for :insurance_recipe, :tray => :plain
  print_action_for :patient_letter, :tray => :invoice

  def insurance_recipe
    @invoice = Invoice.find(params[:id])
    @patient = @invoice.patient

    respond_to do |format|
      format.html {}
      format.pdf { render_pdf }
    end
  end

  def patient_letter
    @invoice = Invoice.find(params[:id])
    @patient = @invoice.patient

    respond_to do |format|
      format.html {}
      format.pdf { render_pdf }
    end
  end

  # CRUD actions
  def show
    @invoice = Invoice.find(params[:id])
    @patient = @invoice.patient
  end

  def new
    @invoice = Invoice.new
    @invoice.date = Date.today
    
    @tiers = Tiers.new
    @tiers.patient_id = params[:patient_id]

    @law = Law.new

    @treatment = Treatment.new
  end

  def new_inline
    new
    render :action => 'new', :layout => false
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    
    # Tiers
    @tiers = TiersGarant.new(params[:tiers])
    @tiers.biller = @current_doctor
    @tiers.provider = @current_doctor

    @tiers.save
    @invoice.tiers = @tiers

    # Law, TODO
    @law = Object.const_get(params[:law][:name]).new
    @law.insured_id = @tiers.patient.insurance_nr

    @law.save
    @invoice.law = @law
    
    # Treatment
    @treatment = Treatment.new(params[:treatment])
    # TODO make selectable
    @treatment.canton ||= @tiers.provider.praxis.address.region
    @invoice.treatment = @treatment

    # Services
    @invoice.service_records = @tiers.patient.service_records
    
    # Saving
    if @invoice.save
      flash[:notice] = 'Erfolgreich erstellt.'
      redirect_to :controller => 'invoices', :action => 'insurance_recipe', :id => @invoice
    else
      render :action => 'new'
    end
  end
end
