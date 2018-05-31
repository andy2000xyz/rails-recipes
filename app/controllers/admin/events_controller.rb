class Admin::EventsController < AdminController
  before_action :require_editor!

  def index
    @events = Event.rank(:row_order).all
  end

  def show
    @event = Event.find_by_friendly_id!(params[:id])

    colors = ['rgba(255, 99, 132, 0.2)',
              'rgba(54, 162, 235, 0.2)',
              'rgba(255, 206, 86, 0.2)',
              'rgba(75, 192, 192, 0.2)',
              'rgba(153, 102, 255, 0.2)',
              'rgba(255, 159, 64, 0.2)'
              ]

    ticket_names = @event.tickets.map { |t| t.name }

    status_colors = { "confirmed" => "#FF6384",
                        "pending" => "#36A2EB"}

    @data1 = {
        labels: ticket_names,
        datasets: Registration::STATUS.map do |s|
          {
            label: I18n.t(s, :scope => "registration.status"),
            data: @event.tickets.map{ |t| t.registrations.by_status(s).count },
            backgroundColor: status_colors[s],
            borderWidth: 1
          }
        end
    }

    @data2 = {
        labels: ticket_names,
        datasets: [{
            label: '# of Amount',
            data:  @event.tickets.map{ |t| t.registrations.by_status("confirmed").count * t.price },
            backgroundColor: colors,
            borderWidth: 1
        }]
    }

    if @event.registrations.any?
      dates = (@event.registrations.order("id ASC").first.created_at.to_date..Date.today).to_a

      @data3 = {
        labels: dates,
        datasets: Registration::STATUS.map do |s|
          {
            :label => I18n.t(s, :scope => "registration.status"),
            :data => dates.map{ |d|
              @event.registrations.by_status(s).where( "created_at >= ? AND created_at <= ?", d.beginning_of_day, d.end_of_day).count
            },
            borderColor: status_colors[s]
          }
        end
      }
    end

  end

  def new
    @event = Event.new
    @event.tickets.build
    @event.attachments.build
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to admin_events_path
    else
      render "new"
    end
  end

  def edit
    @event = Event.find_by_friendly_id!(params[:id])
    @event.tickets.build if @event.tickets.empty?
    @event.attachments.build if @event.attachments.empty?
  end

  def update
    @event = Event.find_by_friendly_id!(params[:id])

    if @event.update(event_params)
      redirect_to admin_events_path
    else
      render "edit"
    end
  end

  def destroy
    @event = Event.find_by_friendly_id!(params[:id])
    @event.destroy

    redirect_to admin_events_path
  end

  def bulk_update
    total = 0
    Array(params[:ids]).each do |event_id|
      event = Event.find(event_id)

      if params[:commit] == I18n.t(:bulk_update)
        event.status = params[:event_status]
        if event.save
          total = 1
        end
      elsif params[:commit] == I18n.t(:bulk_delete)
        event.destroy
        total = 1
      end
    end

    flash[:alert] = "成功完成 #{total} 笔"
    redirect_to admin_events_path
  end

  def reorder
    @event = Event.find_by_friendly_id!(params[:id])
    @event.row_order_position = params[:position]
    @event.save!

    respond_to do |format|
      format.html { redirect_to admin_events_path }
      format.json { render :json => { :message => "ok" }}
    end
  end

  protected

  def event_params
    params.require(:event).permit(:name, :logo, :remove_logo, :remove_images, :description, :friendly_id, :status, :category_id, :images => [], :tickets_attributes => [:id, :name, :description, :price, :_destroy], :attachments_attributes => [:id, :attachment, :description, :_destroy])
  end

end
# 这里 @event.tickets.build 两次，等会表单中就有两笔空的 Ticket 可以编辑。Strong Parameters 的部分，新增了 tickets_attributes 数组包含要修改的 ticket 属性，并且额外多了一个 :id 和 :_destroy 是为了配合 accepts_nested_attributes_for 可以编辑和删除。

# Pro Tip 小技巧：这里 ihower 老师改用了 I18n 来显示按钮字串，这倒不是因为一定要支援多语言，而是因为文案可能会改。如果你按钮写死 <%= submit_tag '批次修改' 的话，那么在 controller 中也需要写成 if params[:commit] == '批次修改'。将来那一天要改字，就要记得两个地方都要改到。但是如果用 I18n 来处理，就之后只要记得改翻译档一个地方就好了。这个原则就叫做 DRY: Don't repeat yourself，这是一个写好程序的基本原则。
